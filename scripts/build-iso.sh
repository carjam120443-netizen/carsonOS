#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="$ROOT/profile"
OUT="$ROOT/out"
WORK="${CARSONOS_WORK_DIR:-/tmp/carsonos-archiso-work}"

if [[ $EUID -ne 0 ]]; then
  echo "Run this script with sudo from an Arch Linux build environment." >&2
  echo "Example: sudo bash scripts/build-iso.sh" >&2
  exit 1
fi
if ! command -v mkarchiso >/dev/null 2>&1; then
  echo "mkarchiso is missing. Install archiso with: pacman -S --needed archiso" >&2
  exit 1
fi
if [[ ! -f "$PROFILE/profiledef.sh" || ! -f "$PROFILE/packages.x86_64" ]]; then
  echo "The CarsonOS archiso profile is incomplete." >&2
  exit 1
fi
mkdir -p "$OUT"

# Build yay outside the target live filesystem. The target root has an overlay
# package cache, so installing the Go toolchain inside customize_airootfs.sh can
# fail with an alpm cachedir mount-point / free-space error.
YAY_BUILD_USER="carsonos-yay-${BASHPID}"
YAY_BUILD_DIR=""
YAY_STAGE_PACKAGE="$PROFILE/airootfs/root/yay.pkg.tar.zst"

cleanup_yay_build() {
  if id "$YAY_BUILD_USER" >/dev/null 2>&1; then
    userdel -r "$YAY_BUILD_USER" >/dev/null 2>&1 || true
  fi
  if [[ -n "$YAY_BUILD_DIR" && -d "$YAY_BUILD_DIR" ]]; then
    rm -rf "$YAY_BUILD_DIR"
  fi
  rm -f "$YAY_STAGE_PACKAGE"
}
trap cleanup_yay_build EXIT
rm -f "$YAY_STAGE_PACKAGE"

# These dependencies are installed only in the disposable/building system.
pacman -S --needed --noconfirm base-devel go git

YAY_BUILD_DIR="$(mktemp -d /tmp/carsonos-yay-build.XXXXXX)"
chmod 0755 "$YAY_BUILD_DIR"
useradd --create-home --shell /bin/bash "$YAY_BUILD_USER"
install -d -m 0755 -o "$YAY_BUILD_USER" -g "$YAY_BUILD_USER" "$YAY_BUILD_DIR/src"
runuser -u "$YAY_BUILD_USER" -- git clone --depth 1 https://aur.archlinux.org/yay.git "$YAY_BUILD_DIR/src/yay"
runuser -u "$YAY_BUILD_USER" -- bash -c "cd \"$YAY_BUILD_DIR/src/yay\" && makepkg --noconfirm"

YAY_PACKAGE="$(find "$YAY_BUILD_DIR/src/yay" -maxdepth 1 -type f -name "yay-[0-9]*-*.pkg.tar.zst" -print -quit)"
if [[ -z "$YAY_PACKAGE" ]]; then
  echo "Failed to build yay: package archive not found." >&2
  exit 1
fi
install -m 0644 "$YAY_PACKAGE" "$YAY_STAGE_PACKAGE"
echo "Staged the yay package for the CarsonOS live image."

mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
printf '\nBuild finished. Check ISO output in: %s\n' "$OUT"
