import pyautogui
import mss
import mss.tools
import time
from datetime import datetime
import keyboard
import cv2
import numpy as np
import os
import csv
import firebase_admin
from firebase_admin import credentials, db
from firebase_admin.exceptions import FirebaseError
import logging
from logging.handlers import RotatingFileHandler
import sys
import shutil  # Für Folder-Operationen
from inputimeout import inputimeout, TimeoutOccurred


# ===== KONFIGURATION =====
mode = sys.argv[1] if len(sys.argv) > 1 else "KILLEMALL"
# mode = sys.argv[1]
if mode == "RKM1":
    MASTER_FOLDER = r"y:\RKM1\Namen_Master"
    SCAN_ROOT = r"y:\RKM1\scan"
if mode == "RKM2":
    MASTER_FOLDER = r"y:\RKM2\Namen_Master"
    SCAN_ROOT = r"y:\RKM2\scan"
if mode == "KILLEMALL":
    MASTER_FOLDER = r"y:\KeM\Namen_Master"
    SCAN_ROOT = r"y:\KeM\scan"
SEARCH_FOLDER = os.path.join(SCAN_ROOT, "now")  # Aktuelles Verzeichnis
MAX_SCAN_FOLDERS = 400  # Maximale Anzahl der gespeicherten Scan-Ordner
THRESHOLD = 0.9  # Ähnlichkeits-Schwellwert für Bildvergleich

# ===== LOGGING =====
log_file = "cats_status_log.log"
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(lineno)d | %(funcName)s | %(message)s",
    handlers=[
        RotatingFileHandler(
            log_file, 
            maxBytes=5*1024*1024,
            backupCount=2,
            encoding='utf-8'
        ),
        logging.StreamHandler(stream=sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Windows-Konsolen-Konfiguration
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
        sys.stderr.reconfigure(encoding='utf-8', errors='replace')
    except AttributeError:
        import io
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

# ===== SCREENSHOT AUTOMATISIERUNG =====
positions = {
    "GB1": (-1472, 530), # GB1 Koordinaten, X=Zwischen (21) und Balken, Y=Mitte des Balken
    "GB2": (-1558, 750),
    "GB3": (-1197, 886),
    "GB4": (-794, 897),
    "GB5": (-490, 758),
    "GB6": (-518, 507),
    "GB": (-1264, 350),
    "Verteidigen": (-1270, 370), # wenn #FFFFFF dann Verteidigen nicht verfügbar, sonst #82ABEB
    "Back": (-1760, 960),
    "KDSA": (-1844, 333), #blauer Balken links
    "KDSB": (-160, 160), #oben rechts rote Fläche mitte oberhalb Pokal
    "KDS": (-274,  88),  #Button oben rechts 3Men
    "Solt03-Blau": (-140, 780),
    "Slots": {
        "Slot01": (-444, 499),
        "Slot02": (-444, 731),
        "Slot03": (-444, 965),
        "Slot04": (-728, 499),
        "Slot05": (-730, 731),
        "Slot06": (-723, 965),
        "Slot07": (-1032, 499),
        "Slot08": (-1022, 731),
        "Slot09": (-1018, 963),
        "Slot10": (-1289, 500),
        "Slot11": (-1284, 733),
        "Slot12": (-1275, 967),
        "Slot13": (-630, 499),
        "Slot14": (-630, 731),
        "Slot15": (-630, 965),
        "Slot16": (-930, 499),
        "Slot17": (-930, 731),
        "Slot18": (-930, 965),
        "Slot19": (-1230, 499),
        "Slot20": (-1230, 731),
        "Slot21": (-1230, 963)
    },
    "GB_Color": {
        "GB1_Color": (-1520, 474),
        "GB2_Color": (-1620, 696),
        "GB3_Color": (-1252, 826),
        "GB4_Color": (-848, 842),
        "GB5_Color": (-548, 701),
        "GB6_Color": (-557, 450)
    }
}

monitor = {
    "left": -1780,
    "top": 320,
    "width": 450,
    "height": 450 #70 or 450
}

def check_escape():
    if keyboard.is_pressed('esc'):
        logger.info("ESC-Taste gedrückt. Beende Programm...")
        exit()

def log_action(action, x, y):
    logger.info(f"{action.ljust(15)} | X={x:4} Y={y:4}")

def rgb_to_hex(rgb):
    return '#{:02X}{:02X}{:02X}'.format(*rgb)

def get_pixel_color(x, y):
    original_pos = pyautogui.position()
        
    with mss.mss() as sct:
        monitor = {"left": x, "top": y, "width": 1, "height": 1}
        screenshot = sct.grab(monitor)
        color = screenshot.pixel(0, 0)
    return color
    
def click_and_wait(x, y, wait_time=1, action_name=""):
    """
    Führt einen Klick an den Koordinaten (x, y) aus und wartet anschließend eine definierte Zeit.
    Optional wird die Aktion im Log dokumentiert.
    Bricht ab, falls die ESC-Taste gedrückt wird.
    
    Args:
        x (int): X-Koordinate für den Klick.
        y (int): Y-Koordinate für den Klick.
        wait_time (float): Wartezeit nach dem Klick in Sekunden.
        action_name (str): Optionaler Name der Aktion für das Logging.
    """
    check_escape()
    pyautogui.click(x=x, y=y)
    if action_name:
        log_action(action_name, x, y)
    time.sleep(wait_time)

def capture_slot(slot_name, slot_num, x, y, search_folder):
    """
    Klickt auf einen Slot und prüft, ob er aktiv ist (Farbwert).
    Wiederholt den Klick bis die aktive Farbe erkannt wird oder ein Timeout erreicht ist.
    Anschließend wird ein Screenshot des Slots gespeichert.
    
    Args:
        slot_name (str): Name des Slots (z.B. 'Slot01').
        slot_num (int): Gebäudenummer (z.B. 1 für GB1).
        x (int): X-Koordinate des Slots.
        y (int): Y-Koordinate des Slots.
        search_folder (str): Zielordner für den Screenshot.
    """
    check_escape()
    # Erster Klick auf den Slot
    pyautogui.click(x=x, y=y)
    log_action(f"Klicke Slot {slot_name}", x, y)
    
    max_versuche = 30  # Maximale Anzahl der Versuche
    versuche = 0
    while versuche < max_versuche:
        color = get_pixel_color(x, y+41)
        hex_color = '#{:02x}{:02x}{:02x}'.format(color[0], color[1], color[2]).upper()
        # Aktuellen Versuch mit Farbwert ausgeben
        logger.info(f"Versuch {versuche+1}/{max_versuche} | Koordinaten: ({x},{y+41}) | Farbe: {hex_color}")
        # Prüfe, ob die aktive Farbe erkannt wurde
        if hex_color.startswith('#A'): # z.B. '#A9CAFA'
            logger.info(f"Erfolg - Aktive Farbe erkannt: {hex_color}")
            erkannt = True
            break
        pyautogui.click(x=x, y=y)
        versuche += 1
    if versuche >= max_versuche:
        logger.warning("Timeout - Aktive Slot-Farbe nicht erkannt!")
    # Screenshot aufnehmen und speichern
    with mss.mss() as sct:
        screenshot = sct.grab(monitor)
        output_filename = f"{search_folder}/GB{slot_num}-{slot_name}.png"
        mss.tools.to_png(screenshot.rgb, screenshot.size, output=output_filename)
        logger.info(f"Screenshot gespeichert: {output_filename}")

    # pixel_maus_klick_pixel(positions["KDSA"], "#8CB1F0", positions["KDSB"], "#9E2523", positions["Back"])

def pixel_maus_klick_pixel(pixel1, farbe1, doit, mausklickpos, pixel2, farbe2):
    """
    Prüft bis zu 30x, ob Pixel1 die gewünschte Farbe1 hat. Falls nicht, wartet und versucht erneut.
    Bei Erfolg prüft bis zu 30x, ob Pixel2 die gewünschte Farbe2 hat. Falls nicht, wird auf mausklickpos geklickt und erneut geprüft.
    Bei Misserfolg nach 30 Versuchen wird das Programm beendet.
    Wenn doit == 1, wird Pixel2 geprüft und ggf. geklickt.
    Wenn doit == 0, wird nur Pixel1 geprüft.
    """
    for versuch1 in range(1, 31):
        color1 = get_pixel_color(*pixel1)
        hex_color1 = rgb_to_hex(color1)
        if hex_color1 == farbe1.upper():
            logger.info(f"Pixel1: Erfolg nach {versuch1} Versuchen, Farbe: {hex_color1}")
            break
        else:
            logger.info(f"Pixel 1: Versuch {versuch1}, Farbe: {hex_color1}, warte auf Farbe: {farbe1}")
            time.sleep(0.5)
    else:
        logger.error("Pixel1: Nach 30 Versuchen keine passende Farbe erkannt. Beende.")
        exit()

    if doit == 1:
        for versuch2 in range(1, 31):
            color2 = get_pixel_color(*pixel2)
            hex_color2 = rgb_to_hex(color2)
            if hex_color2 == farbe2.upper():
                logger.info(f"Pixel2: Erfolg nach {versuch2} Versuchen, Farbe ist:{hex_color2}, soll:{farbe2}")
                break
            else:
                logger.info(f"Pixel2: Versuch {versuch2}, Farbe ist:{hex_color2}, soll:{farbe2} klicke auf {mausklickpos} ...")
                pyautogui.click(*mausklickpos)
                time.sleep(0.5)
        else:
            logger.error("Pixel2: Nach 30 Versuchen keine passende Farbe erkannt. Beende.")
            exit()
    else: 
        logger.info("doit == 0, nur Pixel1 geprüft, kein Klick auf Pixel2")
        
def check_slot_active(x, y):
    """Prüft nur, ob der Slot aktiv ist (ohne Klicks)"""
    color = get_pixel_color(x, y)
    hex_color = '#{:02x}{:02x}{:02x}'.format(color[0], color[1], color[2]).upper()
    logger.info(f"{x, y} Farbe {hex_color} prüfen ob aktiv...")
    return hex_color in ['#72B000', '#000000', '#7AB000']

def check_verteidigen_available():
    # time.sleep(0.1)
    color = get_pixel_color(*positions["Verteidigen"])
    hex_color = '#{:02x}{:02x}{:02x}'.format(color[0], color[1], color[2]).upper()
    return hex_color != '#FFFFFF'

def check_gb_colors(): 
    """
    Prüft die Farben aller GB-Positionen (Blau, Rot oder Grau) und speichert in Firebase
    python Cats_Fz_Status_v4.6.py --colors
    '#EB4C47' '#4179D9' '#5E6A83' 
    """
    # Firebase initialisieren
    initialize_firebase()
    gb_colors = {}
    all_gray = True
    
    for gb_name, coords in positions["GB_Color"].items():
        color = get_pixel_color(*coords)
        hex_color = '#{:02x}{:02x}{:02x}'.format(color[0], color[1], color[2]).upper()
        
        # Farbe kategorisieren
        if hex_color == '#4179D9':
            color_name = "Blau"
            all_gray = False
        elif hex_color == '#EB4C47':
            color_name = "Rot"
            all_gray = False
        else:
            color_name = "Grau"
        
        gb_colors[gb_name] = {
            "hex": hex_color,
            "rgb": color,
            "farbe": color_name
        }
        
        logger.info(f"{gb_name}: {color_name} ({hex_color})")
    
    # Prüfe ob alle GBs grau sind
    # if all_gray:
    #    print("Falsches Bild")
    #    exit()
        
    # Firebase Upload nur wenn nicht alle grau
    for gb_name, gb_data in gb_colors.items():
        try:
            # Firebase initialisieren falls noch nicht geschehen
            if not firebase_admin._apps:
                initialize_firebase()
            
            gb_number = gb_name.replace("_Color", "")  # GB1_Color -> GB1
            ref = db.reference(f"Gebaeude/{gb_number}")
            ref.update({
                "farbe": gb_data["farbe"],
                "hex_color": gb_data["hex"],
                "timestamp": datetime.now().isoformat()
            })
            logger.info(f"✓ {gb_number} Farbe in Firebase gespeichert: {gb_data['farbe']}")
        except Exception as e:
            logger.error(f"✗ Firebase Fehler für {gb_name}: {str(e)}")
    
    return gb_colors

def process_gb(gb_num, search_folder):
    gb_key = f"GB{gb_num}"
    falsche_farbe_count = 0

    # Gebäude anklicken
    time.sleep(2)
    logger.info("pass")
    pixel_maus_klick_pixel(positions[f"GB{gb_num}"], "#FFFFFF", 1, positions[f"GB{gb_num}"], positions["GB"], "#82ABEB")
    logger.info("pass")
    # time.sleep(1)
    # Timestamp des Gebäudes aktualisieren
    update_gb_timestamp(gb_num)
        
    # Prüfen ob Verteidigen verfügbar ist
    if not check_verteidigen_available():
        logger.info(f"Verteidigen nicht verfügbar für GB{gb_num}, überspringe...")
        while True:
            pyautogui.click(*positions["Back"])
            time.sleep(1)
            logger.info("pass")
            color1 = get_pixel_color(*positions["KDSA"])
            color2 = get_pixel_color(*positions["KDSB"])
            hex_color1 = rgb_to_hex(color1)
            hex_color2 = rgb_to_hex(color2)
            if hex_color1 == "#8CB1F0" and hex_color2 == "#9E2523":
                logger.info(f"{gb_key}: Erfolgreiche Zurück")
                break
            else:
                logger.warning(f"{gb_key}: Falsche Farbe versuche erneut...")
                pyautogui.click(-273,90)
                time.sleep(1)
            
        # pyautogui.click(*positions["Back"])
        logger.info("Verteidigen verfügbar NEIN")
        return True
    
    logger.info("Verteidigen verfügbar JA")
        
    # pyautogui.click(*positions["Verteidigen"])
    logger.info("pass")
    pixel_maus_klick_pixel(positions["Verteidigen"], "#82ABEB", 1, positions["Verteidigen"], (-240,310), "#A9CAFA")
    logger.info("pass")
    pixel_maus_klick_pixel((-240,310), "#A9CAFA", 1, positions["Verteidigen"], (-240,310), "#A9CAFA")
    logger.info("pass")
        
    for slot_name, coords in positions["Slots"].items():
        # time.sleep(0.5)
        if check_slot_active(*coords):
            capture_slot(slot_name, gb_num, *coords, search_folder)  # Hier erfolgen die 2 Klicks + Screenshot
            if slot_name == "Slot12":   # Erweiterte Slots scannen wenn Slot12 erfolgreich war
                logger.info("Slot12 erfolgreich - führe Drag-Operation aus")
                # Drag von (-1313, 540) zu (-130, 540)
                while True:
                    pyautogui.moveTo(-1313, 540)
                    # time.sleep(1)
                    pyautogui.drag(1200, 0, duration=3, button='left')
                    time.sleep(1)

                    color1 = get_pixel_color(*positions["Solt03-Blau"])
                    hex_color1 = rgb_to_hex(color1)
                    if hex_color1 == "#A9CAFA":
                        logger.info("Farbe erkannt - Drag-Operation beendet")
                        time.sleep(1)
                        break  # Verlässt die while-Schleife
        else:
            logger.info(f"kein Fahrzeug mehr auf ->{coords}")
            break

    logger.info("pass")
    while True:
        if falsche_farbe_count < 5:
            pyautogui.click(*positions["Back"])
        time.sleep(2)
        logger.info("pass")
        color1 = get_pixel_color(*positions["KDSA"])
        color2 = get_pixel_color(*positions["KDSB"])
        hex_color1 = rgb_to_hex(color1)
        hex_color2 = rgb_to_hex(color2)
        if hex_color1 == "#8CB1F0" and hex_color2 == "#9E2523":
                logger.info(f"{gb_key}: Erfolgreiche Zurück")
                break
        else:
                falsche_farbe_count += 1
                logger.warning(f"{gb_key}: Falsche Farbe versuche erneut...")
                if falsche_farbe_count > 5:
                    pyautogui.click(*positions["KDS"])
                    time.sleep(2)
                    logger.warning(f"{gb_key}: Falsche Farbe > 5")
                if falsche_farbe_count >= 8:
                    falsche_farbe_count = 0
                    logger.warning(f"{gb_key}: Falsche Farbe > 8")
    
    logger.info("pass")
    return True 

def run_screenshot_automation(search_folder):
    logger.info("\n=== Screenshot-Automatisierung ===")
    
    # Abfrage welche Gebäude bearbeitet werden sollen
    gb_numbers = ("123456")
    
    for gb_num in gb_numbers:
        process_gb(gb_num, search_folder)
        time.sleep(1)
    
    logger.info("Screenshot-Automatisierung abgeschlossen!")

# ===== BILDVERARBEITUNG & FIREBASE =====
def safe_imread(filepath):
    img = cv2.imread(filepath, cv2.IMREAD_GRAYSCALE)
    if img is not None:
        return img
    
    try:
        with open(filepath, 'rb') as f:
            bytes = bytearray(f.read())
            img = cv2.imdecode(np.asarray(bytes, dtype=np.uint8), cv2.IMREAD_GRAYSCALE)
            return img
    except Exception as e:
        logger.error(f"Kritischer Fehler beim Laden von {filepath}: {str(e)}")
        return None


def initialize_firebase():
    try:
        # Prüfen ob bereits initialisiert
        if firebase_admin._apps:
            logger.info("Firebase bereits initialisiert")
            return True
            
        # cred = credentials.Certificate("serviceAccountKey.json")
        
        # Database URL je nach Modus
        if mode == "RKM1":
            cred = credentials.Certificate("serviceAccountKeyRKM1.json")
            db_url = 'https://rkm1-2d4b3-default-rtdb.europe-west1.firebasedatabase.app/'
        if mode == "RKM2":
            cred = credentials.Certificate("serviceAccountKeyRKM2.json")
            db_url = 'https://rkm2-2fc92-default-rtdb.europe-west1.firebasedatabase.app/'
        if mode == "KILLEMALL":
            cred = credentials.Certificate("serviceAccountKeyKILLeMALL.json")
            db_url = 'https://killemall-15063-default-rtdb.europe-west1.firebasedatabase.app/'
            
        firebase_admin.initialize_app(cred, {'databaseURL': db_url})
        logger.info("✓ Firebase erfolgreich initialisiert")
        return True
    except Exception as e:
        logger.error(f"✗ Firebase Initialisierung fehlgeschlagen: {str(e)}")
        return False

def get_priority(geb_value):
    priority_order = {
        '': 0,
        'GB1': 1,
        'GB2': 2,
        'GB3': 3,
        'GB4': 4,
        'GB5': 5,
        'GB6': 6,
        'Rep': 7,
        'Res': 8,
        'gekillt': 9
    }
    return priority_order.get(geb_value, 1)

def upload_to_firebase(search_name, master_name):
    try:
        master_name = master_name.upper()
        current_gb = search_name.split('-')[0]
        ref = db.reference(f"Spieler/{master_name}")
        now = datetime.now().isoformat()
        
        # 1. Alle Fahrzeuge des Spielers abrufen
        vehicles = [
            {'num': '1', 'data': ref.child("Fahrzeug 1").get() or {}},
            {'num': '2', 'data': ref.child("Fahrzeug 2").get() or {}},
            {'num': '3', 'data': ref.child("Fahrzeug 3").get() or {}}
        ]

        # 2. Suche Fahrzeuge mit Status 0 und im Ziel-GB 
        for vehicle in vehicles:
            if vehicle['data'].get("status", 0) == 0 and vehicle['data'].get("Gebäude") == current_gb:
                ref.child(f"Fahrzeug {vehicle['num']}").update({"status": 1})
                logger.info(f"Status aktualisiert: {master_name} Fz {vehicle['num']} (bereits in {current_gb})")
                return True  # Fertig, keine weiteren Prüfungen!
        
        # 3. Suche nach Fahrzeugen nach Priorität
        prioritaets_gebaeude = ["", "gekillt", "gekillt-GB1", "gekillt-GB2", "gekillt-GB3", "gekillt-GB4", "gekillt-GB5", "gekillt-GB6", "GB1", "GB2", "GB3", "GB4", "GB5", "GB6", "Res", "Rep"]
        for gebaeude in prioritaets_gebaeude:
            for vehicle in vehicles:
                current_gebaeude = vehicle['data'].get("Gebäude", "")
                # Prüfe sowohl exakte Übereinstimmung als auch gekillt-GBx Varianten
                if (vehicle['data'].get("status", 0) == 0 and 
                    (current_gebaeude == gebaeude or 
                     (gebaeude.startswith("GB") and current_gebaeude == f"gekillt-{gebaeude}"))):
                    
                    time.sleep(1) # nur bei Discord Uploads nötig
                    update_data = {
                        "Gebäude": current_gb,
                        "originalGB": current_gb,
                        "status": 1,
                        "timestamp": now
                    }
                    
                    ref.child(f"Fahrzeug {vehicle['num']}").update(update_data)
                    
                    log_msg = f"Zugewiesen {master_name} Fz {vehicle['num']}: "
                    if current_gebaeude == "":
                        log_msg += f"leer → {current_gb}"
                    else:
                        log_msg += f"{current_gebaeude} → {current_gb}"
                    
                    logger.info(log_msg)
                    return True  # Beende die Funktion nach erfolgreicher Aktualisierung
            # Diese Zeile sollte nur ausgeführt werden, wenn ein Fahrzeug gefunden wurde
            # logger.info(f"Status aktualisiert: {master_name} Fz {vehicle['num']} ({vehicle['data'].get('Gebäude')}→{current_gb})")
                       
    except Exception as e:
        logger.error(f"Fehler bei {master_name}: {str(e)}")
        return False
    
def cleanup_zero_status_entries():
    """Setzt verbliebene Status-0 Einträge:
       - Mit GB: 'gekillt' (mit aktuellem Timestamp + 2h)
       - Ohne GB: 'leer'
       - Rep/Res/gekillt: unverändert"""
    players_ref = db.reference("Spieler")
    
    for player_id, player_data in (players_ref.get() or {}).items():
        for vehicle_num in ['1', '2', '3']:
            vehicle_key = f"Fahrzeug {vehicle_num}"
            vehicle_data = player_data.get(vehicle_key, {})
            
            if vehicle_data.get("status", 0) == 0:
                current_geb = vehicle_data.get("Gebäude", "")
                
                # Ignoriere Rep, Res und bereits gekillte Einträge
                if current_geb in ["Rep", "Res", "gekillt"] or current_geb.startswith("gekillt"):
                    logger.info(f"Ignoriert: {player_id} {vehicle_key} → {current_geb} (bleibt unverändert)")
                    continue
                
                update_data = {
                    "status": 0
                }
                
                if current_geb.startswith("GB"):
                    time.sleep(1) # nur bei Discord Uploads nötig
                    # Setze gekillt-GBx statt nur gekillt
                    update_data["Gebäude"] = f"gekillt-{current_geb}"
                    # Setze Timestamp auf aktuelle Zeit (ab jetzt 2h Countdown)
                    update_data["timestamp"] = datetime.now().isoformat()
                    logger.info(f"Bereinigt: {player_id} {vehicle_key} → {update_data['Gebäude']} (2h Countdown gestartet)")
                else:
                    update_data["Gebäude"] = ""
                    update_data["timestamp"] = datetime.now().isoformat()
                    logger.info(f"Bereinigt: {player_id} {vehicle_key} → leer")
                
                players_ref.child(f"{player_id}/{vehicle_key}").update(update_data)

def reset_all_status():
    """Setzt alle status-Werte auf 0 (nur einmal am Anfang)"""
    logger.info("Starte globalen Status-Reset...")
    success_count = 0
    
    try:
        spieler_ref = db.reference('Spieler')
        all_players = spieler_ref.get() or {}
        
        for spieler_name, spieler_data in all_players.items():
            update_data = {}
            for fz_num in ['1', '2', '3']:
                fz_key = f'Fahrzeug {fz_num}'
                if fz_key in spieler_data:
                    update_data[f'{fz_key}/status'] = 0
            
            if update_data:
                spieler_ref.child(spieler_name).update(update_data)
                success_count += 1
                logger.info(f"✓ {spieler_name.ljust(10)}: Status auf 0 gesetzt")
        
        logger.info(f"Reset abgeschlossen: {success_count} erfolgreich")
        
    except Exception as e:
        logger.critical(f"Globaler Reset-Fehler: {str(e)}")

def update_gb_timestamp(gb_num):
    try:
        ref = db.reference(f"Gebaeude/GB{gb_num}")
        now = datetime.now().isoformat()
        
        # Bestehende Daten abrufen
        existing_data = ref.get() or {}
        
        # Nur Timestamp aktualisieren, Farbe beibehalten
        if isinstance(existing_data, dict):
            existing_data["timestamp"] = now
            ref.set(existing_data)
        else:
            # Falls nur String vorhanden, neues Objekt erstellen
            ref.set({"timestamp": now})
            
        logger.info(f"Timestamp für GB{gb_num} aktualisiert: {now}")
    except Exception as e:
        logger.error(f"Fehler beim Speichern des GB{gb_num}-Timestamps: {str(e)}")

def run_image_processing(master_folder, search_folder, output_csv="zuordnung_ergebnisse.csv", threshold=0.8):
    logger.info("\n=== Bildverarbeitung und Firebase-Upload ===")
    firebase_initialized = initialize_firebase()
    
    # Status nur einmal zurücksetzen
    if firebase_initialized:
        reset_all_status()

    # Masterbilder laden
    masters = {}
    for master_name in os.listdir(master_folder):
        if master_name.lower().endswith(".png"):
            master_path = os.path.join(master_folder, master_name)
            master_img = safe_imread(master_path)
            if master_img is not None:
                masters[master_name[:-4]] = master_img
                logger.info(f"✓ {master_name} erfolgreich geladen")

    # Screenshots nach Priorität sortieren
    sorted_screenshots = sorted(
        [f for f in os.listdir(search_folder) if f.startswith("GB") and f.endswith(".png")],
        key=lambda x: get_priority(x.split('-')[0])
    )

    # Bildverarbeitung durchführen
    with open(output_csv, mode='w', newline='', encoding='utf-8-sig') as file:
        writer = csv.writer(file)
        writer.writerow(["Suchbild", "Masterbild"])
        
        # Gruppiere Screenshots nach GB und Slot
        from collections import defaultdict
        gb_slots = defaultdict(list)
        
        for search_name in sorted_screenshots:
            gb = search_name.split('-')[0]
            gb_slots[gb].append(search_name)
        
        # Verarbeite zuerst die wichtigsten Gebäude
        for gb in sorted(gb_slots.keys(), key=lambda x: get_priority(x)):
            for search_name in gb_slots[gb]:
                search_path = os.path.join(search_folder, search_name)
                search_img = safe_imread(search_path)
                
                if search_img is None:
                    writer.writerow([search_name, "LOAD_ERROR", "0.00"])
                    continue
                    
                best_match, best_score = None, 0
                for master_name, master_img in masters.items():
                    try:
                        if master_img.shape != search_img.shape:
                            master_img = cv2.resize(master_img, (search_img.shape[1], search_img.shape[0]))
                        score = cv2.matchTemplate(search_img, master_img, cv2.TM_CCORR_NORMED).max()
                        if score > best_score and score > threshold:
                            best_score, best_match = score, master_name
                    except Exception as e:
                        logger.warning(f"Vergleichsfehler {master_name}-{search_name}: {str(e)}")
                        continue
                        
                result = [search_name, best_match or "NO_MATCH", f"{best_score:.2f}"]
                writer.writerow(result)
                logger.info(" | ".join(result))
                
                if firebase_initialized and best_match:
                    # Versuche bis zu 3x für wichtige Gebäude
                    # break # zeile löschen Leo
                    max_attempts = 3 if gb.startswith("GB") else 1
                    for attempt in range(max_attempts):
                        if upload_to_firebase(search_name, best_match):
                            break
    
    # Finale Bereinigung
    if firebase_initialized:
        cleanup_zero_status_entries()
    
    logger.info("\n✔ Bildverarbeitung abgeschlossen")


def rotate_scan_folders():
    """Verschiebt den Inhalt von 'now' in ein neues Timestamp-Verzeichnis und löscht alte"""
    try:
        # Prüfe ob 'now' existiert und nicht leer ist
        if not os.path.exists(SEARCH_FOLDER) or not os.listdir(SEARCH_FOLDER):
            return
            
        # Erstelle das root-Verzeichnis falls nicht existent
        os.makedirs(SCAN_ROOT, exist_ok=True)
        
        # Erstelle Timestamp für neuen Ordner
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        new_folder = os.path.join(SCAN_ROOT, timestamp)
        
        # Verschiebe den Inhalt von 'now' in das neue Verzeichnis
        os.rename(SEARCH_FOLDER, new_folder)
        logger.info(f"Inhalt von 'now' verschoben nach: {timestamp}")
        
        # Erstelle 'now' Verzeichnis neu
        os.makedirs(SEARCH_FOLDER, exist_ok=True)
        
        # Liste aller Timestamp-Ordner, sortiert nach Name (älteste zuerst)
        all_folders = sorted([
            f for f in os.listdir(SCAN_ROOT) 
            if f != "now" and os.path.isdir(os.path.join(SCAN_ROOT, f))
        ])
        
        # Lösche älteste Ordner wenn Maximum überschritten
        while len(all_folders) >= MAX_SCAN_FOLDERS:
            oldest = all_folders.pop(0)
            try:
                shutil.rmtree(os.path.join(SCAN_ROOT, oldest))
                logger.info(f"Alter Ordner gelöscht: {oldest}")
            except Exception as e:
                logger.error(f"Fehler beim Löschen von {oldest}: {str(e)}")
                
    except Exception as e:
        logger.error(f"Fehler beim Rotieren der Scan-Ordner: {str(e)}")

def main():
    start_time = time.time()
    # Firebase zuerst initialisieren
    if not initialize_firebase():
        logger.error("Firebase konnte nicht initialisiert werden. Fortsetzung ohne Firebase...")
    
    # GB-Farben einmal am Anfang prüfen
    check_gb_colors()
    
    # Stelle sicher, dass das now-Verzeichnis existiert
    os.makedirs(SEARCH_FOLDER, exist_ok=True)
    
    run_screenshot_automation(SEARCH_FOLDER)
    
    # Bildverarbeitung durchführen
    run_image_processing(MASTER_FOLDER, SEARCH_FOLDER)
    
    # Zeitmessung
    total_time = time.time() - start_time
    logger.info(f"Skript abgeschlossen in {total_time:.2f} Sekunden ({total_time/60:.1f} Minuten)")
    

if __name__ == "__main__":
    # Nur GB-Farben testen
    if len(sys.argv) > 1 and sys.argv[1] == "--colors":
        logger.info("=== GB-Farben Test ===")
        check_gb_colors()
        exit()

    # DEL-Taste Listener (Hotkey zum sofortigen Beenden)
    keyboard.add_hotkey('del', lambda: (logger.info("DEL gedrückt - Beende sofort!"), os._exit(1)))

    # Default-Wert: True (Ja)
    # default_move = False
    default_move = True
    logger.info("\n === Start ===")

    try:
        user_input = inputimeout(prompt=f"Screenshots verschieben? (j/n) [Standard: {'j' if default_move else 'n'}]: ", timeout=3)
        move_screenshots = user_input.lower().strip() == 'j' if user_input.strip() else default_move
    except TimeoutOccurred:
        move_screenshots = default_move
        logger.info(f"Timeout - Standard-Option wird verwendet: {'Screenshots werden verschoben' if default_move else 'Screenshots werden nicht verschoben'}")

    if move_screenshots:
        rotate_scan_folders()
        logger.info("Screenshots wurden archiviert.")
    else:
        logger.info("Screenshots werden nicht verschoben, keine neuen Screenshots werden erstellt.")
        # Bildverarbeitung direkt ausführen ohne neue Screenshots
        if initialize_firebase():
            run_image_processing(MASTER_FOLDER, SEARCH_FOLDER)
        exit()  # Programm beenden ohne neue Screenshots zu machen

    # Normale Ausführung mit neuen Screenshots
    main()