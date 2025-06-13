#!/bin/bash

# Farben für schöne Ausgabe
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

# Funktion für Arch Linux
install_arch() {
    echo -e "${YELLOW}Pakete werden installiert für Arch Linux...${NC}"

    # .NET Runtime 9.0 prüfen und nur installieren wenn nötig
    if ! pacman -Q dotnet-runtime-9.0 &>/dev/null; then
        sudo pacman -S --noconfirm dotnet-runtime-9.0 aspnet-runtime-9.0
    else
        echo "${GREEN}.NET Runtime 9.0 ist bereits installiert.${NC}"
    fi

    # chromedriver prüfen
    if ! pacman -Q chromedriver &>/dev/null; then
        echo "${YELLOW}chromedriver wird installiert...${NC}"
        yay -S --noconfirm chromedriver
    else
        echo "${GREEN}chromedriver ist bereits installiert.${NC}"
    fi

    echo "${GREEN}Arch-Installation fertig.${NC}"
}

# Funktion für Ubuntu/Debian
install_ubuntu() {
    echo -e "${YELLOW}Pakete werden installiert für Ubuntu/Debian...${NC}"

    # .NET 9 installieren falls nicht vorhanden
    if ! dotnet --list-sdks | grep -q "9."; then
        echo "${YELLOW}.NET SDK 9 wird installiert...${NC}"
        wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        rm packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y apt-transport-https dotnet-sdk-9.0
    else
        echo "${GREEN}.NET SDK 9 bereits installiert.${NC}"
    fi

    # chromedriver prüfen
    if ! which chromedriver &>/dev/null; then
        echo "${YELLOW}chromedriver wird installiert...${NC}"
        sudo apt-get install -y chromium-chromedriver
    else
        echo "${GREEN}chromedriver ist bereits installiert.${NC}"
    fi

    echo "${GREEN}Ubuntu/Debian-Installation fertig.${NC}"
}

# Installer aufrufen
if [ "$OS" == "arch" ]; then
    install_arch
else
    install_ubuntu
fi

# Build & Run
echo
echo "${YELLOW}Abhängigkeiten vollständig. Starte nun dotnet build + run...${NC}"
dotnet build
dotnet run
