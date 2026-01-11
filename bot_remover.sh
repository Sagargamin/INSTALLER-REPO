#!/usr/bin/env bash
# ==========================================
#   🗑️ REMOVER GUI TOOL
# ==========================================

set -u

# --- COLORS ---
C=$'\033[36m'  # Cyan
G=$'\033[32m'  # Green
R=$'\033[31m'  # Red
B=$'\033[34m'  # Blue
Y=$'\033[33m'  # Yellow
W=$'\033[97m'  # White
N=$'\033[0m'   # Reset

# --- HEADER ---
header() {
    clear
    echo -e "${R}=========================================${N}"
    echo -e "${Y}        🗑️  REMOVER GUI TOOL           ${N}"
    echo -e "${R}=========================================${N}"
    echo ""
}

# --- PAUSE ---
pause() {
    echo ""
    read -p "${W}Press [Enter] to return...${N}" dummy
}

# --- MAIN LOOP ---
while true; do
    header
    echo -e "${C} 1) ${W}Remove BotFile ${R}(Delete app.js)${N}"
    echo -e "${C} 2) ${W}Remove AutoRestarter ${R}(Delete Service)${N}"
    echo -e "${C} 3) ${G}Exit to Main Menu${N}"
    echo ""
    echo -e "${R}=========================================${N}"
    read -p "${Y}👉 Select an option [1-3]: ${N}" choice

    case $choice in
        1)
            echo ""
            echo -e "${Y}🗑️  Deleting app.js...${N}"
            if [ -f "app.js" ]; then
                rm -f app.js
                echo -e "${G}✔ app.js has been deleted successfully!${N}"
            else
                echo -e "${R}❌ File app.js not found!${N}"
            fi
            pause
            ;;
        2)
            echo ""
            echo -e "${Y}🛑 Stopping Bot Service...${N}"
            systemctl stop mybot || echo -e "${R}⚠️ Service was not running.${N}"
            systemctl disable mybot || true
            
            echo -e "${Y}🗑️  Removing Service File...${N}"
            if [ -f "/etc/systemd/system/mybot.service" ]; then
                rm -f /etc/systemd/system/mybot.service
                systemctl daemon-reload
                echo -e "${G}✔ AutoRestarter removed successfully!${N}"
            else
                echo -e "${R}❌ Service file not found!${N}"
            fi
            pause
            ;;
        3)
            echo ""
            echo -e "${G}👋 Exiting Remover GUI...${N}"
            curl -fsSL https://raw.githubusercontent.com/Sagargamin/INSTALLER-REPO/refs/heads/main/main_menu.sh | sed 's/\r$//' | bash
            ;;
        *)
            echo ""
            echo -e "${R}❌ Invalid Option!${N}"
            sleep 1
            ;;
    esac
done
EOF
