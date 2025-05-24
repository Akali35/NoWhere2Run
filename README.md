# NoWhere2Run

> _Because open ports can't hide forever..._

**NoWhere2Run** is a stealthy and customizable port scanner written in pure Bash.  
It uses `hping3`, `nc`, and other native tools to detect open, closed, and filtered ports with precision and discretion.

Built solo by **Akali35** – efficient and unapologetically bash-powered.

---

## Features

- SYN scan with stealth flags (via `hping3`)
- Adjustable delay between scans (`-d`)
- Super-stealth mode with randomized scan order and dynamic delays
- Verbose mode for live scan tracking
- Logfile auto-creation with timestamps
- Detection of filtered ports (RST/ACK logic)
- Simple, lightweight, and portable
- ASCII banner and signature included

---

## Usage

```bash
./nowhere2run.sh [-d delay] [-s] [-v] <ip> <port_start> <port_end>
Basic scan on ports 20 to 80:

./nowhere2run.sh 192.168.1.10 20 80

Custom delay (200ms):

./nowhere2run.sh -d 0.2 192.168.1.10 20 80

Super-stealth mode (randomized ports and delay):

./nowhere2run.sh -s 192.168.1.10 20 80

Verbose mode (display current scanned ports):

./nowhere2run.sh -v 192.168.1.10 20 80

Output
Results are saved automatically in the current directory:

nowhere2run_<IP>_<YYYYMMDD_HHMMSS>.log

Dependencies
Make sure you have the following tools installed:

hping3
netcat
awk
timeout
bc for delay handling

Author
Akali35
Bash enthusiast. Cybersecurity learner. 

