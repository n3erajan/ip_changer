#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
    echo "Run this installer with sudo: sudo ./install.sh" >&2
    exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
    echo "This installer supports Debian and Ubuntu (apt-get) only." >&2
    exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

echo "Installing Tor and ip-changer dependencies..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    tor \
    nftables \
    python3 \
    python3-requests \
    python3-socks \
    python3-stem

# Catch Python/package compatibility problems before replacing the command.
python3 "${SCRIPT_DIR}/ip_changer.py" --help >/dev/null
install -m 0755 "${SCRIPT_DIR}/ip_changer.py" /usr/local/bin/ip-changer

echo
echo "ip-changer installed successfully."
echo "Start it with:  sudo ip-changer start"
echo "Stop it with:   Ctrl+C"
echo "Emergency fix:  sudo ip-changer restore"
