#!/bin/bash

CHROMEPROFILE_DIR="./ChromeProfile"
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
NC=$(tput sgr0)

# OS erkennen
if grep -qi "arch" /etc/os-release; then
    OS="arch"
elif grep -qi "ubuntu" /etc/os-release || grep -qi "debian" /etc/os-release; then
    OS="ubuntu"
else
    echo "${RED}Nicht unterstütztes System. Nur Arch und Ubuntu/Debian werden unterstützt.${NC}"
    exit 1
fi

install_arch() {
    echo -e "${YELLOW}Pakete werden installiert für Arch Linux...${NC}"
    if ! pacman -Q dotnet-runtime-9.0 &>/dev/null; then
        sudo pacman -S --noconfirm dotnet-runtime-9.0 aspnet-runtime-9.0
    else
        echo "${GREEN}.NET Runtime 9.0 ist bereits installiert.${NC}"
    fi
    if ! pacman -Q chromedriver &>/dev/null; then
        echo "${YELLOW}chromedriver wird installiert...${NC}"
        yay -S --noconfirm chromedriver
    else
        echo "${GREEN}chromedriver ist bereits installiert.${NC}"
    fi
    echo "${GREEN}Arch-Installation fertig.${NC}"
}

install_ubuntu() {
    echo -e "${YELLOW}Pakete werden installiert für Ubuntu/Debian...${NC}"

    # Microsoft .NET Repo hinzufügen, wenn noch nicht vorhanden
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb

    sudo apt-get update
    sudo apt-get install -y apt-transport-https

    # dotnet SDK 9 installieren
    if ! dotnet --list-sdks 2>/dev/null | grep -q "9."; then
        sudo apt-get update
        sudo apt-get install -y dotnet-sdk-9.0
    else
        echo "${GREEN}.NET SDK 9 bereits installiert.${NC}"
    fi

    # chromedriver installieren
    if ! command -v chromedriver &>/dev/null; then
        sudo apt-get install -y chromium-chromedriver
    else
        echo "${GREEN}chromedriver ist bereits installiert.${NC}"
    fi

    echo "${GREEN}Ubuntu/Debian-Installation fertig.${NC}"
}

if [ "$OS" == "arch" ]; then
    install_arch
else
    install_ubuntu
fi

echo
echo "${YELLOW}Abhängigkeiten vollständig. Starte nun dotnet build + run...${NC}"

# Prüfen, ob .csproj im aktuellen Verzeichnis
CSPROJ_FILE=$(find . -maxdepth 1 -name "*.csproj" | head -n 1)
if [ ! -f "$CSPROJ_FILE" ]; then
    echo "${RED}Keine .csproj-Datei im aktuellen Verzeichnis gefunden! Bitte gehe in das Projektverzeichnis.${NC}"
    exit 1
fi

dotnet build
if [ ! -d "$CHROMEPROFILE_DIR" ] || [ -z "$(ls -A "$CHROMEPROFILE_DIR")" ]; then
    echo
    echo "${YELLOW}==== WICHTIGER HINWEIS VOR DEM ERSTEN START ====${NC}"
    echo
    echo "${RED}Beim ersten Start wird Chrome geöffnet.${NC}"
    echo "${RED}Bitte mache folgendes im Chrome-Fenster:${NC}"
    echo "${YELLOW}- Lehne das Privatsphäre/Cookie-Banner ab (Button suchen und klicken)${NC}"
    echo "${YELLOW}- Klicke oben rechts auf das Standort-Symbol und wähle deine Region aus${NC}"
    echo "${YELLOW}- Schließe dann Chrome${NC}"
    echo
    echo "${GREEN}Erst danach kannst du das Programm erneut starten, ab dann läuft alles automatisch im 'Headless'-Modus!${NC}"
    echo
    read -p "Drücke [ENTER], um Chrome zu starten ..."
    echo
fi

dotnet run
