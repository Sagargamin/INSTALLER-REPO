#!/usr/bin/env bash
# ==========================================
#    🤖 AFKBOT MAKER (Auto-Retry)
# ==========================================

# Stop script on error
set -e

# --- COLORS ---
G=$'\033[32m'
C=$'\033[36m'
Y=$'\033[33m'
R=$'\033[31m'
N=$'\033[0m'

clear
echo "${C}=========================================${N}"
echo "${G}    ADVANCED MINECRAFT BOT MAKER 🚀     ${N}"
echo "${C}=========================================${N}"
echo ""

# --- STEP 1: ASK FOR DETAILS (With Loop) ---

# 1. SERVER IP
while true; do
    echo "${Y}[?] Enter Server IP Address:${N}"
    read -p "👉 IP: " SERVER_IP
    if [[ -n "$SERVER_IP" ]]; then
        break
    else
        echo "${R}❌ Error: IP Address cannot be empty! Try again.${N}"
        echo ""
    fi
done

# 2. SERVER PORT
echo ""
echo "${Y}[?] Enter Server Port (Default: 25565):${N}"
read -p "👉 Port: " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-25565}

# 3. BOT NAME
while true; do
    echo ""
    echo "${Y}[?] Enter Bot Name:${N}"
    read -p "👉 Name: " BOT_NAME
    if [[ -n "$BOT_NAME" ]]; then
        break
    else
        echo "${R}❌ Error: Bot Name cannot be empty! Try again.${N}"
    fi
done

# --- STEP 2: CHECK DEPENDENCIES ---
echo ""
echo "${C}⚙️  Checking dependencies...${N}"

# Check if Node is installed
if ! command -v node &> /dev/null; then
    echo "${R}❌ Error: Node.js is not installed. Please install Node.js first.${N}"
    exit 1
fi

if [ ! -d "node_modules" ]; then
    echo "${Y}📦 Installing Mineflayer...${N}"
    npm init -y > /dev/null 2>&1
    npm install mineflayer > /dev/null 2>&1
else
    echo "${G}✅ Dependencies found.${N}"
fi

# --- STEP 3: GENERATE app.js ---
echo ""
echo "${C}📝 Writing custom bot code...${N}"

cat <<JS > app.js
const mineflayer = require("mineflayer");

// =================== CONFIG ===================
const config = {
  host: "$SERVER_IP",
  port: $SERVER_PORT,
  username: "$BOT_NAME", 
  version: false, // auto-detect version

  jumpInterval: 3000, // jump every 4s
  runInterval: 1000, // change random direction every 2s
  breakInterval: 6000, // attempt block break every 6s
  breakScanRadius: 4, // max block search distance
  breakOnly: ["dirt", "grass_block", "stone"], // safe blocks

  rejoinInterval: 30000, // leave + rejoin every 30s
};
// ===============================================

let bot;

function createBot() {
  bot = mineflayer.createBot({
    host: config.host,
    port: config.port,
    username: config.username,
    version: config.version,
  });

  bot.on("login", () => {
    console.log(
      \`[bot] spawned as \${bot.username} on \${config.host}:\${config.port}\`
    );
    console.log(\`[bot] AFK behaviors started\`);
    startAFK();
  });

  bot.on("end", () => {
    console.log("[bot] disconnected, waiting to rejoin...");
  });

  bot.on("kicked", (reason) => console.log("[bot] kicked:", reason));
  bot.on("error", (err) => console.log("[bot] error:", err));
}

// Main AFK loop
function startAFK() {
  // Jump loop
  const jumpLoop = setInterval(() => {
    if (!bot || !bot.entity) return;
    bot.setControlState("jump", true);
    setTimeout(() => bot.setControlState("jump", false), 200);
  }, config.jumpInterval);

  // Random movement
  const moveLoop = setInterval(() => {
    if (!bot || !bot.entity) return;
    const directions = ["forward", "back", "left", "right"];
    directions.forEach((d) => bot.setControlState(d, false)); // reset
    const dir = directions[Math.floor(Math.random() * directions.length)];
    bot.setControlState(dir, true);
  }, config.runInterval);

  // Block breaking loop
  const breakLoop = setInterval(() => {
    if (!bot || !bot.entity) return;
    tryBreakBlock();
  }, config.breakInterval);

  // Leave + rejoin cycle
  setTimeout(() => {
    console.log("[bot] Leaving server to rejoin...");
    clearInterval(jumpLoop);
    clearInterval(moveLoop);
    clearInterval(breakLoop);
    bot.quit();
    setTimeout(() => {
      console.log("[bot] Rejoining server...");
      createBot();
    }, 2000); // wait 2s before reconnect
  }, config.rejoinInterval);
}

// Block breaking function
function tryBreakBlock() {
  const block = bot.findBlock({
    matching: (b) => {
      if (!b || !b.position) return false;
      if (b.type === 0) return false; // air
      if (!config.breakOnly.includes(b.name)) return false;
      const dist = bot.entity.position.distanceTo(b.position);
      return dist <= config.breakScanRadius;
    },
    maxDistance: config.breakScanRadius,
  });

  if (!block) {
    // console.log("[bot] no block found nearby to break");
    return;
  }

  console.log(\`[bot] breaking block: \${block.name} at \${block.position}\`);
  bot.dig(block).catch((err) => console.log("[bot] dig error:", err.message));
}

// Start first bot
createBot();
JS

# --- STEP 4: SUCCESS & AUTO START ---
echo ""
echo "${G}==============================================${N}"
echo "${G}    ✅ BOT CONFIG SAVED & GENERATED! ${N}"
echo "${G}==============================================${N}"
echo "Server: $SERVER_IP : $SERVER_PORT"
echo "Bot:    $BOT_NAME"
echo ""

# New Feature: Ask to start immediately
while true; do
    read -p "${Y}[?] Do you want to start the bot now? (y/n): ${N}" yn
    case $yn in
        [Yy]* ) 
            echo "${C}🚀 Starting bot... (Press Ctrl+C to stop)${N}"
            echo ""
            node app.js
            break;;
        [Nn]* ) 
            echo ""
            echo "You can start the bot later using: ${C}node app.js${N}"
            exit;;
        * ) echo "Please answer yes (y) or no (n).";;
    esac
done
