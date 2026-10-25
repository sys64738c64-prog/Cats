import pyautogui #test
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
import threading
from inputimeout import inputimeout, TimeoutOccurred
from pathlib import Path

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
    MASTER_FOLDER = r"Y:\Cats\KM\Namen_Master"
    SCAN_ROOT = r"Y:\Cats\KM\scan"
SEARCH_FOLDER = os.path.join(SCAN_ROOT, "now")  # Aktuelles Verzeichnis
MAX_SCAN_FOLDERS = 400  # Maximale Anzahl der gespeicherten Scan-Ordner
THRESHOLD = 0.9  # Ähnlichkeits-Schwellwert für Bildvergleich

# ===== LOGGING =====
# log_file = "cats_status.log"
log_file = str(Path(__file__).resolve().parent / "cats_status.log")
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

pause_event = threading.Event()
pause_event.set()
pause_toggle_lock = threading.Lock()
last_pause_toggle = 0.0

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
    "GB1.OL": (-1472, 530), # GB1.OL Koordinaten, X=Zwischen (21) und Balken, Y=Mitte des Balken
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

screenshot_regions = {
    "Name ohne Fahrzeug": {"left": -1780, "top": 320, "width": 450, "height": 70},
    "Name mit Fahrzeug": {"left": -1300, "top": 320, "width": 450, "height": 450},
    "GB1 Plätze": {"left": -1269, "top": 470, "width": 40, "height": 40},
    "GB2 Plätze": {"left": -1350, "top": 690, "width": 40, "height": 40},
    "GB3 Plätze": {"left": -991, "top": 822, "width": 40, "height": 40},
    "GB4 Plätze": {"left": -587, "top": 838, "width": 40, "height": 40},
    "GB5 Plätze": {"left": -286, "top": 695, "width": 40, "height": 40},
    "GB6 Plätze": {"left": -308, "top": 445, "width": 40, "height": 40},
    "GB1 Balken": {"left": -1465, "top": 528, "width": 230, "height": 1},
    "GB2 Balken": {"left": -1546, "top": 748, "width": 230, "height": 1},
    "GB3 Balken": {"left": -1188, "top": 880, "width": 230, "height": 1},
    "GB4 Balken": {"left": -783, "top": 895, "width": 230, "height": 1},
    "GB5 Balken": {"left": -483, "top": 755, "width": 230, "height": 1},
    "GB6 Balken": {"left": -507, "top": 504, "width": 230, "height": 1}
}


def check_escape():
    check_pause()
    if keyboard.is_pressed('esc'):
        logger.info("ESC-Taste gedrückt. Beende Programm...")
        exit()

def toggle_pause():
    global last_pause_toggle
    with pause_toggle_lock:
        now = time.monotonic()
        if now - last_pause_toggle < 0.3:
            logger.debug("Doppeltes PAUSE-Signal ignoriert.")
            return
        last_pause_toggle = now

    if pause_event.is_set():
        pause_event.clear()
        logger.warning("PAUSE gedrückt - Programm pausiert. Erneut PAUSE drücken zum Fortsetzen.")
    else:
        pause_event.set()
        logger.info("PAUSE erneut gedrückt - Programm wird fortgesetzt.")

def check_pause():
    while not pause_event.wait(timeout=0.1):
        pass

def pause_aware_sleep(duration):
    remaining = duration
    while remaining > 0:
        check_pause()
        sleep_started = time.monotonic()
        time.sleep(min(remaining, 0.1))
        if pause_event.is_set():
            remaining -= time.monotonic() - sleep_started

def log_action(action, x, y):
    logger.info(f"{action.ljust(15)} | X={x:4} Y={y:4}")

def rgb_to_hex(rgb):
    return '#{:02X}{:02X}{:02X}'.format(*rgb)

def get_pixel_color(x, y):
    check_pause()
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
    pause_aware_sleep(wait_time)

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
        check_pause()
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
        screenshot = sct.grab(screenshot_regions["Name ohne Fahrzeug"])
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
        check_pause()
        color1 = get_pixel_color(*pixel1)
        hex_color1 = rgb_to_hex(color1)
        if hex_color1 == farbe1.upper():
            logger.info(f"Pixel1: Erfolg nach {versuch1} Versuchen, Farbe: {hex_color1}")
            break
        else:
            logger.info(f"Pixel 1: Versuch {versuch1}, Farbe: {hex_color1}, warte auf Farbe: {farbe1}")
            pause_aware_sleep(0.5)
    else:
        logger.error("Pixel1: Nach 30 Versuchen keine passende Farbe erkannt. Beende.")
        exit()

    if doit == 1:
        for versuch2 in range(1, 31):
            check_pause()
            color2 = get_pixel_color(*pixel2)
            hex_color2 = rgb_to_hex(color2)
            if hex_color2 == farbe2.upper():
                logger.info(f"Pixel2: Erfolg nach {versuch2} Versuchen, Farbe ist:{hex_color2}, soll:{farbe2}")
                break
            else:
                logger.info(f"Pixel2: Versuch {versuch2}, Farbe ist:{hex_color2}, soll:{farbe2} klicke auf {mausklickpos} ...")
                pyautogui.click(*mausklickpos)
                pause_aware_sleep(0.5)
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
        check_pause()
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
   
    if all_gray:
        print("alles Grau, FEHLER")
        return()
        exit()
        
    # Firebase Upload nur wenn nicht alle grau
    for gb_name, gb_data in gb_colors.items():
        check_pause()
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
    pause_aware_sleep(2)
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
            check_pause()
            pyautogui.click(*positions["Back"])
            pause_aware_sleep(1)
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
                pause_aware_sleep(1)
            
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
        check_pause()
        # time.sleep(0.5)
        if check_slot_active(*coords):
            capture_slot(slot_name, gb_num, *coords, search_folder)  # Hier erfolgen die 2 Klicks + Screenshot
            if slot_name == "Slot12":   # Erweiterte Slots scannen wenn Slot12 erfolgreich war
                logger.info("Slot12 erfolgreich - führe Drag-Operation aus")
                # Drag von (-1313, 540) zu (-130, 540)
                while True:
                    check_pause()
                    pyautogui.moveTo(-1313, 540)
                    # time.sleep(1)
                    pyautogui.drag(1200, 0, duration=3, button='left')
                    pause_aware_sleep(1)

                    color1 = get_pixel_color(*positions["Solt03-Blau"])
                    hex_color1 = rgb_to_hex(color1)
                    if hex_color1 == "#A9CAFA":
                        logger.info("Farbe erkannt - Drag-Operation beendet")
                        pause_aware_sleep(1)
                        break  # Verlässt die while-Schleife
        else:
            logger.info(f"kein Fahrzeug mehr auf ->{coords}")
            break

    logger.info("pass")
    while True:
        check_pause()
        if falsche_farbe_count < 5:
            pyautogui.click(*positions["Back"])
        pause_aware_sleep(2)
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
                    pause_aware_sleep(2)
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
        check_pause()
        process_gb(gb_num, search_folder)
        pause_aware_sleep(1)
    
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
            check_pause()
            if vehicle['data'].get("status", 0) == 0 and vehicle['data'].get("Gebäude") == current_gb:
                ref.child(f"Fahrzeug {vehicle['num']}").update({"status": 1})
                logger.info(f"Status aktualisiert: {master_name} Fz {vehicle['num']} (bereits in {current_gb})")
                return True  # Fertig, keine weiteren Prüfungen!
        
        # 3. Suche nach Fahrzeugen nach Priorität
        prioritaets_gebaeude = ["", "gekillt", "gekillt-GB1", "gekillt-GB2", "gekillt-GB3", "gekillt-GB4", "gekillt-GB5", "gekillt-GB6", "GB1", "GB2", "GB3", "GB4", "GB5", "GB6", "Res", "Rep"]
        for gebaeude in prioritaets_gebaeude:
            check_pause()
            for vehicle in vehicles:
                check_pause()
                current_gebaeude = vehicle['data'].get("Gebäude", "")
                # Prüfe sowohl exakte Übereinstimmung als auch gekillt-GBx Varianten
                if (vehicle['data'].get("status", 0) == 0 and 
                    (current_gebaeude == gebaeude or 
                     (gebaeude.startswith("GB") and current_gebaeude == f"gekillt-{gebaeude}"))):
                    
                    #time.sleep(1) # nur bei Discord Uploads nötig
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
        check_pause()
        for vehicle_num in ['1', '2', '3']:
            check_pause()
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
                    pause_aware_sleep(1) # nur bei Discord Uploads nötig
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
            check_pause()
            update_data = {}
            for fz_num in ['1', '2', '3']:
                check_pause()
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
    check_pause()
    logger.info("\n=== Bildverarbeitung und Firebase-Upload ===")
    firebase_initialized = initialize_firebase()
    
    # Status nur einmal zurücksetzen
    if firebase_initialized:
        reset_all_status()

    # Masterbilder laden
    masters = {}
    for master_name in os.listdir(master_folder):
        check_pause()
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
            check_pause()
            gb = search_name.split('-')[0]
            gb_slots[gb].append(search_name)
        
        # Verarbeite zuerst die wichtigsten Gebäude
        for gb in sorted(gb_slots.keys(), key=lambda x: get_priority(x)):
            check_pause()
            for search_name in gb_slots[gb]:
                check_pause()
                search_path = os.path.join(search_folder, search_name)
                search_img = safe_imread(search_path)
                
                if search_img is None:
                    writer.writerow([search_name, "LOAD_ERROR", "0.00"])
                    continue
                    
                best_match, best_score = None, 0
                for master_name, master_img in masters.items():
                    check_pause()
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
                        check_pause()
                        if upload_to_firebase(search_name, best_match):
                            break
    
    # Finale Bereinigung
    if firebase_initialized:
        cleanup_zero_status_entries()
    
    logger.info("\n✔ Bildverarbeitung abgeschlossen")


def get_timestamp_scan_folders():
    timestamp_folders = []
    for folder_name in os.listdir(SCAN_ROOT):
        folder_path = os.path.join(SCAN_ROOT, folder_name)
        if not os.path.isdir(folder_path):
            continue
        suffix = folder_name[15:]
        if suffix and (not suffix.startswith("_") or not suffix[1:].isdigit()):
            continue
        try:
            datetime.strptime(folder_name[:15], "%Y%m%d_%H%M%S")
        except ValueError:
            continue
        timestamp_folders.append(folder_path)
    return sorted(timestamp_folders)

def new_timestamp_scan_path():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    folder_path = os.path.join(SCAN_ROOT, timestamp)
    suffix = 1
    while os.path.exists(folder_path):
        folder_path = os.path.join(SCAN_ROOT, f"{timestamp}_{suffix}")
        suffix += 1
    return folder_path

def prune_timestamp_scan_folders(current_folder):
    timestamp_folders = get_timestamp_scan_folders()
    while len(timestamp_folders) > MAX_SCAN_FOLDERS:
        check_pause()
        oldest = timestamp_folders.pop(0)
        if os.path.normcase(oldest) == os.path.normcase(current_folder):
            timestamp_folders.append(oldest)
            continue
        shutil.rmtree(oldest)
        logger.info(f"Alter Ordner gelöscht: {os.path.basename(oldest)}")

def prepare_scan_folder(create_new):
    """Wählt für diesen Lauf einen Scan-Ordner mit Zeitstempel."""
    os.makedirs(SCAN_ROOT, exist_ok=True)

    legacy_folder = os.path.join(SCAN_ROOT, "now")
    archived_folder = None
    if os.path.exists(legacy_folder):
        if not os.path.isdir(legacy_folder):
            raise NotADirectoryError(f"Scan-Pfad ist kein Ordner: {legacy_folder}")
        if os.listdir(legacy_folder):
            archived_folder = new_timestamp_scan_path()
            os.rename(legacy_folder, archived_folder)
            logger.info(f"Vorhandene Scans archiviert: {os.path.basename(archived_folder)}")
        else:
            os.rmdir(legacy_folder)

    if create_new:
        current_folder = new_timestamp_scan_path()
        os.makedirs(current_folder)
        logger.info(f"Neuer Scan-Ordner: {os.path.basename(current_folder)}")
    elif archived_folder:
        current_folder = archived_folder
    else:
        timestamp_folders = get_timestamp_scan_folders()
        if timestamp_folders:
            current_folder = timestamp_folders[-1]
            logger.info(f"Verwende vorhandenen Scan-Ordner: {os.path.basename(current_folder)}")
        else:
            current_folder = new_timestamp_scan_path()
            os.makedirs(current_folder)
            logger.info(f"Neuer leerer Scan-Ordner: {os.path.basename(current_folder)}")

    prune_timestamp_scan_folders(current_folder)
    return current_folder

def main():
    check_pause()
    start_time = time.time()
    # Firebase zuerst initialisieren
    if not initialize_firebase():
        logger.error("Firebase konnte nicht initialisiert werden. Fortsetzung ohne Firebase...")
    
    # GB-Farben einmal am Anfang prüfen
    check_gb_colors()
    
    # Stelle sicher, dass der zeitgestempelte Scan-Ordner existiert
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
    keyboard.add_hotkey('pause', toggle_pause, trigger_on_release=True)

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

    SEARCH_FOLDER = prepare_scan_folder(create_new=move_screenshots)

    if move_screenshots:
        logger.info("Screenshots werden im neuen zeitgestempelten Ordner gespeichert.")
    else:
        logger.info("Keine neuen Screenshots; verarbeite den zeitgestempelten Ordner.")
        # Bildverarbeitung direkt ausführen ohne neue Screenshots
        if initialize_firebase():
            run_image_processing(MASTER_FOLDER, SEARCH_FOLDER)
        exit()  # Programm beenden ohne neue Screenshots zu machen

    # Normale Ausführung mit neuen Screenshots
    main()