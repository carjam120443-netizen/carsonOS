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

# Build yay and Paru outside the target live filesystem. The target root has an overlay
# package cache, so installing the Go toolchain inside customize_airootfs.sh can
# fail with an alpm cachedir mount-point / free-space error.
AUR_BUILD_USER="carsonos-aur-${BASHPID}"
AUR_BUILD_DIR=""
YAY_STAGE_PACKAGE="$PROFILE/airootfs/root/yay.pkg.tar.zst"
PARU_STAGE_PACKAGE="$PROFILE/airootfs/root/paru.pkg.tar.zst"
CALAMARES_STAGE_PACKAGE="$PROFILE/airootfs/root/calamares.pkg.tar.zst"
CALAMARES_DEPS_STAGE="$PROFILE/airootfs/root/calamares-runtime-deps.txt"
BRAVE_ORIGIN_STAGE="$PROFILE/airootfs/root/brave-origin-bin.pkg.tar.zst"
BRAVE_ORIGIN_DEPS_STAGE="$PROFILE/airootfs/root/brave-origin-runtime-deps.txt"
AUR_SUDOERS="/etc/sudoers.d/${AUR_BUILD_USER}"

cleanup_yay_build() {
  if id "$AUR_BUILD_USER" >/dev/null 2>&1; then
    userdel -r "$AUR_BUILD_USER" >/dev/null 2>&1 || true
  fi
  if [[ -n "$AUR_BUILD_DIR" && -d "$AUR_BUILD_DIR" ]]; then
    rm -rf "$AUR_BUILD_DIR"
  fi
  rm -f "$YAY_STAGE_PACKAGE" "$PARU_STAGE_PACKAGE" "$CALAMARES_STAGE_PACKAGE" "$CALAMARES_DEPS_STAGE" "$BRAVE_ORIGIN_STAGE" "$BRAVE_ORIGIN_DEPS_STAGE"
  rm -f "$AUR_SUDOERS"
}
trap cleanup_yay_build EXIT
rm -f "$YAY_STAGE_PACKAGE" "$PARU_STAGE_PACKAGE" "$BRAVE_ORIGIN_STAGE" "$BRAVE_ORIGIN_DEPS_STAGE"

# These dependencies are installed only in the disposable/building system.
pacman -S --needed --noconfirm base-devel go git rust sudo

AUR_BUILD_DIR="$(mktemp -d /tmp/carsonos-yay-build.XXXXXX)"
chmod 0755 "$AUR_BUILD_DIR"
useradd --create-home --shell /bin/bash "$AUR_BUILD_USER"
printf '%s\n' "$AUR_BUILD_USER ALL=(root) NOPASSWD: /usr/bin/pacman" > "$AUR_SUDOERS"
chmod 0440 "$AUR_SUDOERS"
visudo -cf "$AUR_SUDOERS"
install -d -m 0755 -o "$AUR_BUILD_USER" -g "$AUR_BUILD_USER" "$AUR_BUILD_DIR/src"
runuser -u "$AUR_BUILD_USER" -- git clone --depth 1 https://aur.archlinux.org/yay.git "$AUR_BUILD_DIR/src/yay"
runuser -u "$AUR_BUILD_USER" -- bash -c "cd \"$AUR_BUILD_DIR/src/yay\" && makepkg --noconfirm"
runuser -u "$AUR_BUILD_USER" -- git clone --depth 1 https://aur.archlinux.org/paru.git "$AUR_BUILD_DIR/src/paru"
runuser -u "$AUR_BUILD_USER" -- bash -c "cd \"$AUR_BUILD_DIR/src/paru\" && makepkg --noconfirm"

YAY_PACKAGE="$(find "$AUR_BUILD_DIR/src/yay" -maxdepth 1 -type f -name "yay-[0-9]*-*.pkg.tar.zst" -print -quit)"
if [[ -z "$YAY_PACKAGE" ]]; then
  echo "Failed to build yay: package archive not found." >&2
  exit 1
fi
install -m 0644 "$YAY_PACKAGE" "$YAY_STAGE_PACKAGE"
PARU_PACKAGE="$(find "$AUR_BUILD_DIR/src/paru" -maxdepth 1 -type f -name "paru-[0-9]*-*.pkg.tar.zst" -print -quit)"
if [[ -z "$PARU_PACKAGE" ]]; then
  echo "Failed to build Paru: package archive not found." >&2
  exit 1
fi
install -m 0644 "$PARU_PACKAGE" "$PARU_STAGE_PACKAGE"
runuser -u "$AUR_BUILD_USER" -- git clone --depth 1 https://aur.archlinux.org/calamares.git "$AUR_BUILD_DIR/src/calamares"
runuser -u "$AUR_BUILD_USER" -- bash -c "cd \"$AUR_BUILD_DIR/src/calamares\" && makepkg --syncdeps --noconfirm"
CALAMARES_PACKAGE="$(find "$AUR_BUILD_DIR/src/calamares" -maxdepth 1 -type f -name "calamares-[0-9]*-*.pkg.tar.zst" -print -quit)"
if [[ -z "$CALAMARES_PACKAGE" ]]; then
  echo "Failed to build Calamares: package archive not found." >&2
  exit 1
fi
install -m 0644 "$CALAMARES_PACKAGE" "$CALAMARES_STAGE_PACKAGE"
bsdtar -xOf "$CALAMARES_PACKAGE" .PKGINFO | sed -n 's/^depend = //p' | sed -E 's/[<>=].*$//' | sort -u > "$CALAMARES_DEPS_STAGE"
# Brave Origin is a binary AUR package. Build it outside the live root,
# then stage its package and runtime dependencies for installation.
runuser -u "$AUR_BUILD_USER" -- git clone --depth 1 https://aur.archlinux.org/brave-origin-bin.git "$AUR_BUILD_DIR/src/brave-origin-bin"
runuser -u "$AUR_BUILD_USER" -- bash -c "cd \"$AUR_BUILD_DIR/src/brave-origin-bin\" && makepkg --syncdeps --noconfirm"
BRAVE_ORIGIN_PACKAGE="$(find "$AUR_BUILD_DIR/src/brave-origin-bin" -maxdepth 1 -type f -name "brave-origin-bin-[0-9]*-*.pkg.tar.zst" -print -quit)"
if [[ -z "$BRAVE_ORIGIN_PACKAGE" ]]; then
  echo "Failed to build Brave Origin: package archive not found." >&2
  exit 1
fi
install -m 0644 "$BRAVE_ORIGIN_PACKAGE" "$BRAVE_ORIGIN_STAGE"
bsdtar -xOf "$BRAVE_ORIGIN_PACKAGE" .PKGINFO | sed -n 's/^depend = //p' | sed -E 's/[<>=].*$//' | sort -u > "$BRAVE_ORIGIN_DEPS_STAGE"
echo "Staged yay, Paru, Calamares, and Brave Origin packages for the CarsonOS live image."

mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"
printf '\nBuild finished. Check ISO output in: %s\n' "$OUT"
