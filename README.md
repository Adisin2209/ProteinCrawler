# ProteinCrawler - Marktguru Scraper

![C#](https://img.shields.io/badge/c%23-%23239120.svg?style=for-the-badge&logo=c-sharp&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![Selenium](https://img.shields.io/badge/Selenium-43B02A?style=for-the-badge&logo=selenium&logoColor=white)

Dieses Projekt ist ein Web Scraper für `marktguru.de`. Die Dokumentation ist auf Deutsch und Englisch verfügbar.
This project is a web scraper for `marktguru.de`. Documentation is available in German and English.

---

## 🇩🇪 Deutsch

### 📝 Beschreibung

ProteinCrawler ist eine Konsolenanwendung, die mit C# und Selenium entwickelt wurde, um Produktinformationen von der Angebots-Webseite `marktguru.de` zu extrahieren.

Das Skript kann:
-   Nach einem bestimmten Produkt suchen (z.B. "Eis").
-   Den Cookie-Einwilligungs-Banner automatisch umgehen (nach einer einmaligen Einrichtung).
-   Ein portables Chrome-Profil verwenden, um Einstellungen zu speichern.
-   Alle gefundenen Produkte mit Name, Preis, Marke und Händler in der Konsole ausgeben.
-   Dynamisch erkennen, ob eine Ersteinrichtung nötig ist und den Browser entsprechend sichtbar oder im Hintergrund (headless) starten.

### ⚠️ Rechtlicher Hinweis (Disclaimer)

Dieses Skript dient ausschließlich zu Bildungs- und Demonstrationszwecken. Die Nutzung erfolgt auf eigene Gefahr.

-   **Respektieren Sie die Nutzungsbedingungen:** Bitte prüfen und respektieren Sie die Nutzungsbedingungen und die `robots.txt`-Datei der Webseite `marktguru.de`.
-   **Keine Haftung:** Der Entwickler dieses Skripts übernimmt keine Haftung für dessen Nutzung oder daraus entstehende Konsequenzen. Sie sind für die Einhaltung der rechtlichen Rahmenbedingungen selbst verantwortlich.
-   **Keine Verbindung:** Dieses Projekt steht in keinerlei Verbindung zu marktguru.de oder dessen Betreibern.
-   **Änderungen der Webseite:** Web-Scraper sind anfällig für Änderungen an der Struktur der Ziel-Webseite. Das Skript kann ohne Vorwarnung aufhören zu funktionieren, wenn `marktguru.de` aktualisiert wird.

### 🚀 Benutzung

Das Projekt enthält Setup-Skripte, die die Ausführung und Installation von Abhängigkeiten vereinfachen.

**Voraussetzungen:**
-   [.NET SDK](https://dotnet.microsoft.com/download) (Version 8.0 oder neuer)
-   [Google Chrome](https://www.google.com/chrome/)

**Anleitung:**

1.  **Repository klonen:** `git clone https://github.com/Adisin2209/ProteinCrawler.git`
2.  **In den Projektordner navigieren:** `cd ProteinCrawler`
3.  **Setup-Skript ausführen:**
    -   **Windows:** Führe `setup.bat` per Doppelklick aus.
    -   **macOS/Linux:** Führe im Terminal `bash setup.sh` aus. (Eventuell musst du es zuerst mit `chmod +x setup.sh` ausführbar machen).

**Einmalige Ersteinrichtung:**

Beim allerersten Start führt dich das Setup-Skript durch die Installation der Voraussetzungen. Danach:
1.  Öffnet sich ein Chrome-Fenster. Warte, bis der Cookie-Banner erscheint.
2.  Klicke im Banner manuell auf **"Alle ablehnen"**.
3.  Schließe das Browser-Fenster. Das Programm beendet sich.

**Fertig!** Die Entscheidung wurde im `ChromeProfile`-Ordner gespeichert.

**Normale Nutzung:**

Führe einfach erneut das `setup.bat`- oder `setup.sh`-Skript aus. Das Programm startet jetzt schnell und unsichtbar im Hintergrund (headless) und gibt die Ergebnisse in der Konsole aus.

---

## 🇬🇧 English

### 📝 Description

ProteinCrawler is a console application developed with C# and Selenium to scrape product information from the deals website `marktguru.de`.

The script can:
-   Search for a specific product (e.g., "Eis" which is German for ice cream).
-   Handle the cookie consent banner automatically (after a one-time setup).
-   Use a portable Chrome profile to store settings.
-   Output all found products with their name, price, brand, and retailer to the console.
-   Dynamically detect if a first-time setup is needed and launch the browser visibly or in the background (headless) accordingly.

### ⚠️ Legal Disclaimer

This script is for educational and demonstrational purposes only. Use it at your own risk.

-   **Respect the Terms of Service:** Please review and respect the Terms of Service and the `robots.txt` file of the target website (`marktguru.de`).
-   **No Liability:** The developer of this script assumes no liability for its use or any resulting consequences. You are solely responsible for complying with all applicable laws.
-   **No Affiliation:** This project is not affiliated with, authorized, or endorsed by marktguru.de or its operators.
-   **Website Changes:** Web scrapers are fragile and can break when the target website's structure is updated. This script may stop working without warning if `marktguru.de` is changed.

### 🚀 Usage

The project includes setup scripts to simplify execution and dependency installation.

**Prerequisites:**
-   [.NET SDK](https://dotnet.microsoft.com/download) (Version 8.0 or newer)
-   [Google Chrome](https://www.google.com/chrome/)

**Instructions:**

1.  **Clone the repository:** `git clone https://github.com/Adisin2209/ProteinCrawler.git`
2.  **Navigate into the project folder:** `cd ProteinCrawler`
3.  **Run the setup script:**
    -   **On Windows:** Double-click and run `setup.bat`.
    -   **On macOS/Linux:** Open a terminal and run `bash setup.sh`. (You might need to make it executable first with `chmod +x setup.sh`).

**One-Time First-Time Setup:**

On the very first run, the setup script will guide you through installing the prerequisites. Afterwards:
1.  A Chrome browser window will open automatically. Wait for the cookie banner to appear.
2.  Manually click on the **"Alle ablehnen"** (Deny all) button in the banner.
3.  Close the browser window. The program will terminate.

**Done!** Your choice has been saved in the `ChromeProfile` folder.

**Normal Usage:**

Simply run the `setup.bat` or `setup.sh` script again. The program will now start quickly and invisibly in the background (headless) and output the scraped data directly to your console.