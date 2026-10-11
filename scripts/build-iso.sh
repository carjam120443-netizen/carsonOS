#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="$ROOT/profile"
OUT="$ROOT/out"
WORK="${CARSONOS_WORK_DIR:-/tmp/carsonos-archiso-work}"

if [[ $EUID -ne 0 ]]; then
  echo "Run this script with sudo from an Arch Linux build environment." >&2
  echo "Example: sudo ./scripts/build-iso.sh" >&2
  exit 1
fi
if ! command -v mkarchiso >/dev/null 2>&1; then
  echo "mkarchiso is missing. Install archiso with: pacman -S --needed archiso" >&2
  exit 1
fi
mkdir -p "$OUT"
mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
printf '\nBuild finished. Check ISO output in: %s\n' "$OUT"
