#!/bin/bash

# Clear screen and show banner
clear
echo "======================================="
echo "   _   _                   _           "
echo "  | \\ | | _____      _____| | ___  ___ "
echo "  |  \\| |/ _ \\ \\ /\\ / / _ \\ |/ _ \\/ __|"
echo "  | |\\  |  __/\\ V  V /  __/ |  __/\\__ \\"
echo "  |_| \\_|\\___| \\_/\\_/ \\___|_|\\___||___/"
echo
echo "       N O W H E R E   2   R U N"
echo "---------------------------------------"
echo "       "Stealth Bash Port Scanner"
echo "   Coded by: Akali35 – Solo Project 2025"
echo "======================================="

# Random hacker quotes
QUOTES=(
  "\"Silence is loud when ports speak.\""
  "\"No port is safe when the shadows scan.\""
  "\"Invisible packets. Visible results.\""
  "\"Stealth isn't optional. It's protocol.\""
  "\"You can't hide from what you can't see coming.\""
  "\"Every closed door is just a delayed response.\""
  "\"My SYN is your weakness.\""
  "\"This isn't scanning. It's recon warfare.\""
  "\"No firewall survives curiosity forever.\""
  "\"Your perimeter? Already observed.\""
)
RANDOM_QUOTE=${QUOTES[$RANDOM % ${#QUOTES[@]}]}
echo
echo "💬 $RANDOM_QUOTE"
echo

# Check dependencies
for cmd in hping3 nc timeout awk; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo "[!] Error: '$cmd' is required but not installed."
        exit 1
    fi
done

# Default options
DELAY=0.1
STEALTH=false
VERBOSE=false

# Option parsing
while getopts "d:sv" opt; do
    case $opt in
        d) DELAY=$OPTARG ;;
        s) STEALTH=true ;;
        v) VERBOSE=true ;;
        *) ;;
    esac
done
shift $((OPTIND -1))

# Args
TARGET=$1
START_PORT=$2
END_PORT=$3

if [[ -z $TARGET || -z $START_PORT || -z $END_PORT ]]; then
    echo "Usage: $0 [-d delay] [-s] [-v] <ip> <port_start> <port_end>"
    echo "  -d delay      Delay between scans (e.g. 0.2 for 200ms)"
    echo "  -s            Super-stealth mode (random ports + random delays)"
    echo "  -v            Verbose mode (show each port being scanned)"
    exit 1
fi

# Setup
FORMAT_IP=$(echo $TARGET | tr '.' '_')
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="nowhere2run_${FORMAT_IP}_${TIMESTAMP}.log"

echo "[+] Stealth scan on $TARGET ($START_PORT-$END_PORT)"
echo "[+] Delay: $DELAY sec"
$STEALTH && echo "[+] Super-stealth mode activated"
$VERBOSE && echo "[+] Verbose mode ON"

PORTS=$(seq $START_PORT $END_PORT)
$STEALTH && PORTS=$(echo "$PORTS" | shuf)

MAX_PARALLEL=20
SEMAPHORE="/tmp/nowhere2run.sem.$$"
mkfifo "$SEMAPHORE"
exec 3<> "$SEMAPHORE"
rm "$SEMAPHORE"
for ((i=0;i<MAX_PARALLEL;i++)); do echo >&3; done

# Scan function
scan_port() {
    local ip=$1
    local port=$2

    $VERBOSE && echo "[*] Scanning port $port..."

    timeout 2 hping3 -S -p $port -c 1 $ip 2>/dev/null | grep -q "flags=SA"
    if [[ $? -eq 0 ]]; then
        echo "Port $port : OPEN" | tee -a "$LOG_FILE"
    else
        timeout 2 hping3 -S -p $port -c 1 $ip 2>/dev/null | grep -q "flags=RA"
        if [[ $? -eq 0 ]]; then
            echo "Port $port : CLOSED" >> "$LOG_FILE"
        else
            echo "Port $port : FILTERED/NO RESPONSE" >> "$LOG_FILE"
        fi
    fi
}

# Scan loop
for port in $PORTS; do
    read -u 3
    {
        $STEALTH && sleep $(awk -v min=$DELAY 'BEGIN { srand(); print min + rand() * min }')
        scan_port "$TARGET" "$port"
        echo >&3
    } &
done

wait
exec 3>&-

echo
echo "Scan complete. Results saved in $LOG_FILE"
echo "→ Target probed. No place left to hide."
