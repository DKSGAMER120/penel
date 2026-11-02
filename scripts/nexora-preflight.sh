#!/usr/bin/env bash
# NEXORA Pterodactyl host preflight.
# Read-only: this script does not install packages, change firewall rules,
# create users, modify files, or start/stop services.
set -u

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; RESET='\033[0m'
PASS=0; WARN=0; FAIL=0

ok(){ printf "${GREEN}[PASS]${RESET} %s\n" "$1"; PASS=$((PASS+1)); }
warn(){ printf "${YELLOW}[CHECK]${RESET} %s\n" "$1"; WARN=$((WARN+1)); }
fail(){ printf "${RED}[MISSING]${RESET} %s\n" "$1"; FAIL=$((FAIL+1)); }

printf '\n==============================================\n'
printf '       NEXORA PTERODACTYL HOST PREFLIGHT\n'
printf '==============================================\n'
printf 'Read-only checks only. No system changes will be made.\n\n'

if [ -r /etc/os-release ]; then
  . /etc/os-release
  if [ "${ID:-}" = ubuntu ] && [ "${VERSION_ID:-}" = "24.04" ]; then
    ok "Ubuntu 24.04 detected"
  else
    warn "Detected ${PRETTY_NAME:-unknown}; project target is Ubuntu 24.04"
  fi
else
  fail "Cannot identify Linux distribution"
fi

if [ "$(id -u)" -eq 0 ]; then ok "Running with root privileges"
else warn "Not root; use sudo when performing the reviewed installation later"
fi

ARCH="$(uname -m 2>/dev/null || echo unknown)"
case "$ARCH" in
  x86_64|aarch64) ok "Supported common architecture: $ARCH" ;;
  *) warn "Architecture is $ARCH; verify compatibility before deployment" ;;
esac

for cmd in curl tar unzip; do
  if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd is installed"; else fail "$cmd is missing"; fi
done

if command -v docker >/dev/null 2>&1; then
  ok "Docker CLI is installed"
  if docker info >/dev/null 2>&1; then ok "Docker daemon is reachable"
  else warn "Docker daemon is not reachable for this user"; fi
else
  fail "Docker CLI is not installed"
fi

if command -v php >/dev/null 2>&1; then
  PHPV="$(php -r 'echo PHP_VERSION;' 2>/dev/null || true)"
  ok "PHP detected: ${PHPV:-version unavailable} (verify required extensions and supported version)"
else
  warn "PHP is not installed yet"
fi

if command -v mariadb >/dev/null 2>&1 || command -v mysql >/dev/null 2>&1; then
  ok "MariaDB/MySQL client detected"
else
  warn "MariaDB/MySQL client not detected"
fi

if command -v free >/dev/null 2>&1; then
  free -h | awk '/^Mem:/ {printf "Memory: %s total, %s available\n",$2,$7}'
else
  warn "Cannot read memory summary (free command unavailable)"
fi

df -hP . | awk 'NR==2 {printf "Filesystem for current directory: %s total, %s available\n",$2,$4}'

if command -v ss >/dev/null 2>&1; then
  printf '\nListening TCP ports (review against your planned firewall):\n'
  ss -ltn 2>/dev/null | sed -n '1,12p'
else
  warn "ss command unavailable; cannot list listening ports"
fi

printf '\n==============================================\n'
printf 'Summary: %s passed, %s need review, %s missing\n' "$PASS" "$WARN" "$FAIL"
printf 'This check does not install or configure Pterodactyl.\n'
printf 'Do not migrate your live Minecraft server until Panel, Wings, backups, and restore tests pass.\n'
printf '==============================================\n'
