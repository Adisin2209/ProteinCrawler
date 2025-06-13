#!/bin/bash

CHROMEPROFILE_DIR="./ChromeProfile"
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
NC=$(tput sgr0)

# .NET SDK 9.0 Download-URL ggf. prüfen/aktualisieren (x64)
DOTNET_VERSION="9.0.203"
DOTNET_URL="https://download.visualstudio.microsoft.com/download/pr/f7993e2e-3374-4841-870a-593ba4135393/759f7b6a919b4578e296a58a0e070319/dotnet-sdk-9.0.203-linux-x64.tar.gz"
INSTALL_DIR="$HOME/dotnet"

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
    echo -e "${YELLOW}Manuelle .NET SDK 9 Installation nach Microsoft-Vorgabe...${NC}"
    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
    wget -O /tmp/dotnet.tar.gz "$DOTNET_URL"
    tar -xzf /tmp/dotnet.tar.gz -C "$INSTALL_DIR"
    rm /tmp/dotnet.tar.gz

    # Umgebungsvariablen temporär setzen
    export DOTNET_ROOT="$INSTALL_DIR"
    if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
        export PATH="$INSTALL_DIR:$PATH"
    fi

    # In die .bashrc/profil eintragen, wenn noch nicht vorhanden
    if ! grep -qF 'export DOTNET_ROOT' ~/.bashrc; then
        echo "export DOTNET_ROOT=\"$INSTALL_DIR\"" >> ~/.bashrc
    fi
    if ! grep -qF 'export PATH="$HOME/dotnet:$PATH"' ~/.bashrc; then
        echo "export PATH=\"\$HOME/dotnet:\$PATH\"" >> ~/.bashrc
    fi

    # Testen
    "$INSTALL_DIR/dotnet" --info || { echo "${RED}.NET wurde nicht korrekt installiert!${NC}"; exit 1; }

    # chromedriver installieren
    if ! command -v chromedriver &>/dev/null; then
        sudo apt-get update
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

"$INSTALL_DIR/dotnet" build
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
"$INSTALL_DIR/dotnet" run

# Hinweis für den Benutzer
echo
echo "${YELLOW}Falls 'dotnet' bei neuen Terminals nicht gefunden wird, bitte ein neues Terminal öffnen, damit \$PATH-Änderungen aus ~/.bashrc greifen.${NC}"
