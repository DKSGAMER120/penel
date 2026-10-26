
#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================"
echo "   Pterodactyl Panel Installer Launcher"
echo "========================================"

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run this script as root."
    echo "Command: sudo bash install-panel.sh"
    exit 1
fi

if [[ ! -r /etc/os-release ]]; then
    echo "ERROR: Cannot detect operating system."
    exit 1
fi

. /etc/os-release

if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "24.04" ]]; then
    echo "ERROR: This launcher is intended for Ubuntu 24.04."
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    apt-get update
    apt-get install -y curl ca-certificates
fi

echo
echo "WARNING:"
echo "- This downloads a third-party installer."
echo "- It will request administrator privileges."
echo "- Review the installer source before proceeding."
echo "- Choose Panel ONLY in the installer menu."
echo "- Do NOT choose Wings or Both yet."
echo
read -r -p "Continue? Type YES: " confirm

if [[ "$confirm" != "YES" ]]; then
    echo "Cancelled."
    exit 0
fi

installer_url="https://pterodactyl-installer.se"
tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

curl --fail --location --silent --show-error \
    "$installer_url" -o "$tmp_file"

echo
echo "Installer downloaded."
echo "Review its source before running it."
echo "Official documentation: https://docs.pterodactyl.io/"
echo "Community installer: https://github.com/pterodactyl-installer/pterodactyl-installer"
echo
read -r -p "Run the downloaded installer? Type RUN: " run_confirm

if [[ "$run_confirm" != "RUN" ]]; then
    echo "Cancelled. Downloaded file will be removed."
    exit 0
fi

bash "$tmp_file"
