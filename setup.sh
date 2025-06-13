#!/bin/bash

CHROMEPROFILE_DIR="./ChromeProfile"
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
NC=$(tput sgr0)

# Aktuelle .NET Version anpassen
DOTNET_VERSION="9.0.203"
DOWNLOAD_URL="https://download.visualstudio.microsoft.com/download/pr/f7993e2e-3374-4841-870a-593ba4135393/759f7b6a919b4578e296a58a0e070319/dotnet-sdk-9.0.203-linux-x64.tar.gz"
INSTALL_DIR="$HOME/dotnet"

echo -e "${YELLOW}Manuelle .NET SDK Installation nach Microsoft-Vorgabe...${NC}"

# Entferne alte Installation zur Sicherheit
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Download & Entpacken
wget -O /tmp/dotnet.tar.gz "$DOWNLOAD_URL"
tar -xzf /tmp/dotnet.tar.gz -C "$INSTALL_DIR"
rm /tmp/dotnet.tar.gz

# Stelle sicher, dass Installationsverzeichnis vor dotnet im PATH steht
export DOTNET_ROOT="$INSTALL_DIR"
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    export PATH="$INSTALL_DIR:$PATH"
    # Optional ins Profil eintragen für spätere Sessions
    grep -qF 'export DOTNET_ROOT' ~/.bashrc || echo "export DOTNET_ROOT=\"$INSTALL_DIR\"" >> ~/.bashrc
    grep -qF 'export PATH="$HOME/dotnet:$PATH"' ~/.bashrc || echo "export PATH=\"$HOME/dotnet:\$PATH\"" >> ~/.bashrc
fi

echo -e "${GREEN}dotnet version: $($INSTALL_DIR/dotnet --version)${NC}"

# chromedriver installieren, falls nötig
if ! command -v chromedriver &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y chromium-chromedriver
else
    echo "${GREEN}chromedriver ist bereits installiert.${NC}"
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
