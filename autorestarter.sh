#!/usr/bin/env bash
# ==========================================
#    Auto-Restarter Installer 🚀
#    Sets up Systemd for Node.js Bot
# ==========================================

set -euo pipefail

# --- ANSI COLORS ---
G=$'\033[32m'  # Green
B=$'\033[34m'  # Blue
R=$'\033[31m'  # Red
C=$'\033[36m'  # Cyan
W=$'\033[97m'  # White
N=$'\033[0m'   # Reset

# --- CONFIGURATION ---
BOT_FILE="/root/app.js"    # Your bot file path
SERVICE_NAME="mybot"       # Name of the background service

# --- UTILS ---
typewriter() {
  local text="$1"
  local delay="${2:-0.005}"
  for ((i=0; i<${#text}; i++)); do
    printf "%s" "${text:i:1}"
    sleep "$delay"
  done
  printf "\n"
}

spinner() {
  local pid=$!
  local delay=0.1
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# --- ROOT CHECK ---
if [[ "$EUID" -ne 0 ]]; then
  printf "%b\n" "${R}❌ Error: Please run with sudo or as root${N}"
  exit 1
fi

# --- MAIN SCRIPT ---
clear
printf "%b\n" "${B}=========================================${N}"
printf "%b\n" "${C}    🤖  NODE.JS BOT AUTO-RESTARTER       ${N}"
printf "%b\n" "${B}=========================================${N}"
echo ""

# 1. FIND NODE PATH
typewriter "${W}🔍 Locating Node.js installation...${N}"
NODE_PATH=$(which node)

if [[ -z "$NODE_PATH" ]]; then
    printf "%b\n" "${R}❌ Error: Node.js not found! Install it first.${N}"
    exit 1
fi
printf "%b\n" "${G}✔ Found Node at: $NODE_PATH${N}"
sleep 0.5

# 2. CHECK BOT FILE
typewriter "${W}🔍 Checking for bot file...${N}"
if [[ ! -f "$BOT_FILE" ]]; then
    printf "%b\n" "${R}❌ Error: File $BOT_FILE does not exist!${N}"
    exit 1
fi
printf "%b\n" "${G}✔ Found Bot file at: $BOT_FILE${N}"
sleep 0.5

# 3. CREATE SERVICE FILE
typewriter "${W}⚙️  Generating Systemd Service file...${N}"
(
cat <<EOF > /etc/systemd/system/${SERVICE_NAME}.service
[Unit]
Description=NodeJS Minecraft Bot
After=network.target

[Service]
User=root
WorkingDirectory=$(dirname $BOT_FILE)
ExecStart=$NODE_PATH $BOT_FILE
Restart=always
RestartSec=10
# Removed obsolete syslog lines
SyslogIdentifier=$SERVICE_NAME

[Install]
WantedBy=multi-user.target
EOF
) & spinner

printf "%b\n" "${G}✔ Service file created at /etc/systemd/system/${SERVICE_NAME}.service${N}"

# 4. ENABLE & START
echo ""
typewriter "${W}🚀 Activating auto-restart sequences...${N}"

(
  systemctl daemon-reload
  systemctl enable $SERVICE_NAME
  systemctl start $SERVICE_NAME
) & spinner

printf "%b\n" "${G}✔ Bot Started & Auto-Restart Enabled!${N}"

# 5. FINAL STATUS
echo ""
printf "%b\n" "${B}=========================================${N}"
typewriter "${G}    ✅ INSTALLATION COMPLETE! ${N}"
printf "%b\n" "${B}=========================================${N}"
echo ""
echo "commands to manage your bot:"
echo "  • Logs:   journalctl -u $SERVICE_NAME -f"
echo "  • Stop:   systemctl stop $SERVICE_NAME"
echo "  • Start:  systemctl start $SERVICE_NAME"
echo ""
