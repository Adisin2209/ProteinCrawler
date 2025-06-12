#!/bin/bash

# Farben für eine schönere Ausgabe definieren
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
NC=$(tput sgr0) # No Color

# Funktion, um zu prüfen, ob der Benutzer Root/sudo-Rechte hat
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "${RED}Fehler: Bitte führe dieses Skript mit sudo-Rechten aus, da Pakete installiert werden müssen.${NC}"
        echo "Beispiel: sudo bash setup.sh"
        exit 1
    fi
}

# Funktion zur Installation von .NET unter Ubuntu/Debian
install_dotnet_ubuntu() {
    if ! command -v dotnet &> /dev/null; then
        echo "${YELLOW}.NET SDK wird installiert...${NC}"
        # Befehle laut offizieller Microsoft-Anleitung
        apt-get update
        apt-get install -y wget
        wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        dpkg -i packages-microsoft-prod.deb
        rm packages-microsoft-prod.deb
        apt-get update
        apt-get install -y apt-transport-https 
        apt-get install -y dotnet-sdk-8.0
        echo "${GREEN}.NET SDK erfolgreich installiert.${NC}"
    else
        echo "${GREEN}.NET SDK ist bereits installiert.${NC}"
    fi
}

# Funktion zur Installation von Google Chrome unter Ubuntu/Debian
install_chrome_ubuntu() {
    if ! command -v google-chrome-stable &> /dev/null; then
        echo "${YELLOW}Google Chrome wird installiert...${NC}"
        apt-get install -y wget
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
        sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
        apt-get update
        apt-get install -y google-chrome-stable
        echo "${GREEN}Google Chrome erfolgreich installiert.${NC}"
    else
        echo "${GREEN}Google Chrome ist bereits installiert.${NC}"
    fi
}

# Funktion zur Installation von .NET unter Arch Linux
install_dotnet_arch() {
    if ! command -v dotnet &> /dev/null; then
        echo "${YELLOW}.NET SDK wird installiert...${NC}"
        pacman -Syu --noconfirm dotnet-sdk
        echo "${GREEN}.NET SDK erfolgreich installiert.${NC}"
    else
        echo "${GREEN}.NET SDK ist bereits installiert.${NC}"
    fi
}

# Funktion zur PRÜFUNG von Google Chrome unter Arch Linux
check_chrome_arch() {
    if ! command -v google-chrome &> /dev/null; then
        echo "${RED}Google Chrome nicht gefunden.${NC}"
        echo "${YELLOW}Auf Arch Linux wird Chrome typischerweise aus dem AUR (Arch User Repository) installiert.${NC}"
        echo "Bitte installiere es manuell, z.B. mit einem AUR-Helper wie 'yay' oder 'paru':"
        echo "Beispiel: yay -S google-chrome"
        exit 1
    else
        echo "${GREEN}Google Chrome ist bereits installiert.${NC}"
    fi
}


# --- Hauptlogik des Skripts ---

echo "Willkommen zum Setup für den Marktguru Scraper."
echo "Dieses Skript prüft und installiert benötigte Software."
echo

# Auswahlmenü für die Distribution
echo "Bitte wähle deine Linux-Distribution:"
echo "  1) Ubuntu, Debian, Mint (apt-basiert)"
echo "  2) Arch Linux, Manjaro (pacman-basiert)"
read -p "Auswahl [1-2]: " choice

case $choice in
    1)
        echo -e "\n${GREEN}Ubuntu/Debian-basiertes System ausgewählt.${NC}"
        check_sudo
        install_dotnet_ubuntu
        install_chrome_ubuntu
        ;;
    2)
        echo -e "\n${GREEN}Arch-basiertes System ausgewählt.${NC}"
        check_sudo
        install_dotnet_arch
        check_chrome_arch
        ;;
    *)
        echo "${RED}Ungültige Auswahl. Skript wird beendet.${NC}"
        exit 1
        ;;
esac

echo
echo "================================================================="
echo "Alle Voraussetzungen erfüllt. Das C#-Programm kann jetzt gestartet werden."
echo "Bitte führe nun das Programm aus (ggf. in einem neuen Terminal ohne sudo):"
echo "dotnet run --verbosity quiet"
echo "================================================================="