#!/usr/bin/env bash
# ==========================================
#   DEPENDENCY INSTALLER
# ==========================================

set -e  # Stop script on error

# --- COLORS ---
G=$'\033[32m'
C=$'\033[36m'
N=$'\033[0m'

echo ""
echo "${C}➜ Updating System Lists...${N}"
apt update -y

# 1. PREPARE NODEJS (Version 22)
echo ""
echo "${C}➜ Adding Node.js v22 Source...${N}"
apt install -y curl
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

# 2. INSTALL NODEJS
echo ""
echo "${C}➜ Running: apt install nodejs...${N}"
apt install -y nodejs

# 3. INSTALL NPM (Added per your request)
echo ""
echo "${C}➜ Running: apt install npm...${N}"
apt install -y npm
apt install -y build-essential git

# 4. INSTALL MINEFLAYER
# Note: Mineflayer must be installed via 'npm', not 'apt'
echo ""
echo "${C}➜ Running: npm install mineflayer...${N}"
cd /root
if [ ! -f "package.json" ]; then
    npm init -y
fi
npm install mineflayer

echo ""
echo "${G}✅ All Dependencies Installed Successfully!${N}"
echo "   - Node.js $(node -v)"
echo "   - NPM $(npm -v)"
echo "   - Mineflayer Installed"
echo ""
