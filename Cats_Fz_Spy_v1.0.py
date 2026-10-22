import pyautogui  # type: ignore
pyautogui.FAILSAFE = False
pyautogui.PAUSE = 0.1
import mss
import mss.tools
import time
from datetime import datetime
import keyboard  # type: ignore
import os
import logging
from logging.handlers import RotatingFileHandler
import sys
import shutil  # Für Folder-Operationen
import ctypes

# ===== KONFIGURATION =====
SCAN_ROOT = os.getenv('SCAN_ROOT', r"Y:\Cats\Spy")
SEARCH_FOLDER = os.path.join(SCAN_ROOT, datetime.now().strftime("%Y%m%d_%H%M%S"))  # Timestamp Verzeichnis
MAX_SCAN_FOLDERS = 400  # Maximale Anzahl der gespeicherten Scan-Ordner

# Screenshot-Flag
gangname_screenshot_taken = False

# ===== LOGGING =====
log_file = "cats_spy.log"
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
    "Angreifen01": (-720, 360), # wenn #FF635F dann Angreifen verfügbar
    "Angreifen02": (-1540, 40), # wenn #FF605A dann Angreifen verfügbar
    "Spy_on_01": (-1135, 498), # wenn Energiebalken
    "Spy_on_02": (-1000, 450), # wenn #FF615B dann Spy is on x -30
    "Back": (-1760, 960),
    "KDSA": (-1844, 333), #blauer Balken links
    "KDSB": (-160, 160),
    "Solt03-Blau": (-140, 780),
    "Slots": {
        "Slot01": (-1130, 500),
        "Slot02": (-1130, 732),
        "Slot03": (-1130, 964),
        "Slot04": (-830, 500),
        "Slot05": (-830, 732),
        "Slot06": (-830, 964),
        "Slot07": (-530, 500),
        "Slot08": (-530, 732),
        "Slot09": (-530, 964),
        "Slot10": (-230, 500),
        "Slot11": (-230, 732),
        "Slot12": (-230, 964),
        "Slot13": (-940, 500),
        "Slot14": (-940, 732),
        "Slot15": (-940, 964),
        "Slot16": (-640, 500),
        "Slot17": (-640, 732),
        "Slot18": (-640, 964),
        "Slot19": (-350, 500),
        "Slot20": (-350, 732),
        "Slot21": (-350, 964)
    },
   }
monitor = {
    "left": -1747,
    "top": 328,
    "width": 400,
    "height": 400
}

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
    # Erster Klick auf den Slot
    pyautogui.click(x=x, y=y)
    time.sleep(1)
    log_action(f"Klicke Slot {slot_name}", x, y)
    
    max_versuche = 3  # Maximale Anzahl der Versuche
    versuche = 0
    while versuche < max_versuche:
        color = get_pixel_color(x-30, y-190)
        hex_color = '#{:02x}{:02x}{:02x}'.format(color[0], color[1], color[2]).upper()
        # Aktuellen Versuch mit Farbwert ausgeben
        logger.info(f"Versuch {versuche+1}/{max_versuche} | Koordinaten: ({slot_name}) | Farbe: {hex_color}")
        # Prüfe, ob die aktive Farbe erkannt wurde
        if hex_color == "#FF615B":
            logger.info(f"Erfolg - Aktive Farbe erkannt: {hex_color}")
            break
        pyautogui.click(x=x, y=y)
        time.sleep(1)
        versuche += 1
    else:
        logger.warning("Timeout - Aktive Slot-Farbe nicht erkannt!")
        raise Exception("Slot-Timeout")
    
    # Prüfe, ob der Slot ein Bot ist
    color = get_pixel_color(-1567, 350)
    hex_color = '#{:02x}{:02x}{:02x}'.format(color[0], color[1], color[2]).upper()
    if hex_color == "#144D79":
        logger.info(f"Slot {slot_name} ist Bot - überspringe Screenshot.")
    else:
        # Screenshot nur erstellen wenn kein Bot
        # Screenshot aufnehmen und speichern
        with mss.mss() as sct:
            screenshot = sct.grab(monitor)
            output_filename = f"{search_folder}/GB{slot_num}-{slot_name}.png"
            mss.tools.to_png(screenshot.rgb, screenshot.size, output=output_filename)
            logger.info(f"Screenshot gespeichert: {output_filename}")

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
            logger.info(f"Pixel1: Versuch {versuch1}, Farbe: {hex_color1}, warte ...")
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
    return hex_color in ['#72B000', '#000000']

def Check_spy_is_on():
    """Prüft, ob Spy is on"""
    global gangname_screenshot_taken
    color1 = get_pixel_color(*positions["Spy_on_01"])
    hex_color1 = rgb_to_hex(color1)
    if hex_color1 == "#72B000" or hex_color1 == "#000000":
        logger.info(hex_color1)
        logger.info("Spy is ON")
        
        # Screenshot nur einmal machen
        if not gangname_screenshot_taken:
            gangname_monitor = {"left": -937, "top": 117, "width": 420, "height": 55}
            with mss.mss() as sct:
                screenshot = sct.grab(gangname_monitor)
                output_filename = f"{SEARCH_FOLDER}/GB0-Gangname.png"
                mss.tools.to_png(screenshot.rgb, screenshot.size, output=output_filename)
                logger.info(f"Gangname Screenshot gespeichert: {output_filename}")
            gangname_screenshot_taken = True
        
        return True
    else:
        logger.info(hex_color1)
        logger.info("Spy is OFF")
        return False

def process_gb(gb_num, search_folder):
    gb_key = f"GB{gb_num}"
    logger.info(f"Verarbeite {gb_key}")

    # Gebäude x klicken
    logger.info("pass")
    pixel_maus_klick_pixel(positions[f"GB{gb_num}"], "#FFFFFF", 1, positions[f"GB{gb_num}"], positions["GB"], "#82ABEB")
    logger.info("pass")

    # Angreifen klicken
    logger.info("pass")
    pixel_maus_klick_pixel(positions["Angreifen01"], "#FF635F", 1, positions["Angreifen01"], positions["Angreifen02"], "#FF605A")
    logger.info("pass")
    
    # Prüfen ob Spy is on
    if not Check_spy_is_on():
        logger.info(f"Gebäude {gb_num}, ist nicht gespäht")
            
        while True:
            # time.sleep(1)
            # pyautogui.click(*positions["Back"])
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
                pyautogui.click(*positions["Back"])
                time.sleep(1)
           
        return True
    
    logger.info("spähen aktiv")
            
    for slot_name, coords in positions["Slots"].items():
        try:
            logger.info(f"Prüfe {slot_name} auf Aktivität...")
            pyautogui.click(*coords)  # Klick auf jeden Slot
            time.sleep(1)
            capture_slot(slot_name, gb_num, *coords, search_folder)  # Hier erfolgen die 2 Klicks + Screenshot
        except Exception:
            logger.info("Slot-Fehler - springe zu nächstem GB")
            break
        if slot_name == "Slot12":   # Erweiterte Slots scannen wenn Slot12 erfolgreich war
            logger.info("Slot12 erfolgreich - führe Drag-Operation aus")
            # Drag von (-1313, 540) zu (-130, 540)
            for i in range(3):
                pyautogui.moveTo(-100, 800)
                time.sleep(1)
                pyautogui.drag(-1600, 0, duration=2, button='left')
    
    logger.info("pass")
    while True:
        pyautogui.click(*positions["Back"])
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
    
    logger.info("pass")
    return True 

def run_screenshot_automation(search_folder):
    logger.info("\n=== Screenshot-Automatisierung ===")
    
    # Abfrage welche Gebäude bearbeitet werden sollen
    # gb_numbers = ("123456")
    gb_numbers = input("Gebäudenummer eingeben: ")

    if gb_numbers == "":
        gb_numbers = ("123456")


    for gb_num in gb_numbers:
        process_gb(gb_num, search_folder)
        time.sleep(1)
    
    logger.info("Screenshot-Automatisierung abgeschlossen!")

def cleanup_old_folders():
    """Löscht alte Timestamp-Ordner wenn Maximum überschritten"""
    try:
        # Erstelle das root-Verzeichnis falls nicht existent
        os.makedirs(SCAN_ROOT, exist_ok=True)
        
        # Liste aller Timestamp-Ordner, sortiert nach Name (älteste zuerst)
        all_folders = sorted([
            f for f in os.listdir(SCAN_ROOT) 
            if os.path.isdir(os.path.join(SCAN_ROOT, f))
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
        logger.error(f"Fehler beim Bereinigen alter Ordner: {str(e)}")

def main():
    start_time = time.time()
        
    # Stelle sicher, dass das now-Verzeichnis existiert
    os.makedirs(SEARCH_FOLDER, exist_ok=True)
    
    run_screenshot_automation(SEARCH_FOLDER)
    
    # Zeitmessung
    total_time = time.time() - start_time
    logger.info(f"Skript abgeschlossen in {total_time:.2f} Sekunden ({total_time/60:.1f} Minuten)")

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

if __name__ == "__main__":
    if not is_admin():
        ctypes.windll.shell32.ShellExecuteW(
            None,
            "runas",
            sys.executable,
            " ".join(sys.argv),
            None,
            1
        )
        sys.exit()        
    # DEL-Taste Listener
    keyboard.add_hotkey('del', lambda: (logger.info("DEL gedrückt - Beende sofort!"), os._exit(1)))
        
    logger.info("\n === Start ===")
    
    cleanup_old_folders()
    logger.info(f"Verwende Ordner: {os.path.basename(SEARCH_FOLDER)}")
    
    main()