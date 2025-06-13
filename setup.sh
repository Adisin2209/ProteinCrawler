#!/bin/bash

# Farben für die Ausgabe
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
NC=$(tput sgr0)

echo "Willkommen zum Setup für den ProteinCrawler."

# --- OS-Erkennung (bleibt gleich) ---
if grep -qi "arch" /etc/os-release; then
    OS="arch"
elif grep -qi "ubuntu" /etc/os-release || grep -qi "debian" /etc/os-release; then
    OS="ubuntu"
else
    echo "${RED}Nicht unterstütztes Betriebssystem. Nur Arch und Ubuntu/Debian werden unterstützt.${NC}"
    exit 1
fi

# --- Funktion für Ubuntu/Debian (STARK VEREINFACHT) ---
install_ubuntu() {
    echo -e "\n${YELLOW}Installiere Abhängigkeiten für Ubuntu/Debian...${NC}"

    # Prüfe .NET SDK
    if ! command -v dotnet &> /dev/null; then
        echo "${YELLOW}.NET 9 SDK wird installiert...${NC}"
        # Offizieller Weg, um Microsofts Paket-Repository hinzuzufügen
        wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        rm packages-microsoft-prod.deb

        sudo apt-get update
        sudo apt-get install -y dotnet-sdk-9.0
    else
        echo "${GREEN}.NET SDK ist bereits installiert.${NC}"
    fi

    # Prüfe ChromeDriver
    if ! command -v chromedriver &>/dev/null; then
        echo "${YELLOW}ChromeDriver wird installiert...${NC}"
        sudo apt-get update
        sudo apt-get install -y chromium-chromedriver
    else
        echo "${GREEN}ChromeDriver ist bereits installiert.${NC}"
    fi
    echo "${GREEN}Ubuntu/Debian-Setup fertig.${NC}"
}

# --- Funktion für Arch Linux (leicht vereinfacht) ---
install_arch() {
    echo -e "\n${YELLOW}Installiere Abhängigkeiten für Arch Linux...${NC}"

    # Prüfe .NET SDK
    if ! pacman -Q dotnet-sdk &>/dev/null; then
        sudo pacman -Syu --noconfirm dotnet-sdk
    else
        echo "${GREEN}.NET SDK ist bereits installiert.${NC}"
    fi

    # Prüfe ChromeDriver (via yay/AUR ist ein guter Ansatz)
    if ! command -v chromedriver &> /dev/null; then
        if command -v yay &> /dev/null; then
            echo "${YELLOW}Installiere chromedriver mit yay...${NC}"
            yay -S --noconfirm chromedriver
        else
            echo "${RED}AUR-Helper 'yay' nicht gefunden. Bitte installiere 'chromedriver' manuell.${NC}"
            exit 1
        fi
    else
        echo "${GREEN}ChromeDriver ist bereits installiert.${NC}"
    fi
    echo "${GREEN}Arch-Setup fertig.${NC}"
}


# --- Hauptlogik ---
# Führe die passende Installationsfunktion aus
if [ "$OS" == "arch" ]; then
    install_arch
else
    install_ubuntu
fi

echo
echo "${YELLOW}Abhängigkeiten vollständig. Starte nun dotnet build + run...${NC}"

# Wir rufen 'dotnet' direkt auf, ohne Pfad!
# Das System findet jetzt die korrekte, per 'apt' installierte Version.
dotnet build

# Hinweis für den ersten Start (bleibt gleich)
CHROMEPROFILE_DIR="./ChromeProfile"
if [ ! -d "$CHROMEPROFILE_DIR" ] || [ -z "$(ls -A "$CHROMEPROFILE_DIR")" ]; then
    echo
    echo "${YELLOW}==== WICHTIGER HINWEIS VOR DEM ERSTEN START ====${NC}"
    echo "${RED}Beim ersten Start wird Chrome geöffnet. Bitte lehne den Cookie-Banner ab und schließe Chrome danach.${NC}"
    read -p "Drücke [ENTER], um den Scraper zu starten ..."
fi

# Starte die Anwendung
dotnet run
