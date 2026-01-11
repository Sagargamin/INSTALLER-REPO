#!/usr/bin/env bash
set -e

# --- COLORS ---
G=$'\033[32m'
C=$'\033[36m'
N=$'\033[0m'

echo ""
echo "${C}➜ Updating System Lists...${N}"
apt update -y

# 1. PREPARE NODEJS
echo ""
echo "${C}➜ Adding Node.js v22 Source...${N}"
apt install -y curl
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

# 2. INSTALL NODEJS & NPM
echo ""
echo "${C}➜ Installing Nodejs & NPM...${N}"
apt install -y nodejs
apt install -y npm
apt install -y build-essential git

# 3. INSTALL MINEFLAYER
echo ""
echo "${C}➜ Installing Mineflayer...${N}"
cd /root
if [ ! -f "package.json" ]; then
    npm init -y
fi
npm install mineflayer

echo ""
echo "${G}✅ All Dependencies Installed Successfully!${N}"
EOF
