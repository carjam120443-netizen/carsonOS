#!/usr/bin/env bash
set -euo pipefail

# carsonOS Ubuntu 26.04 LTS ISO builder
# Works both in GitHub Actions and when run locally.

export DEBIAN_FRONTEND=noninteractive

# GitHub Actions provides GITHUB_WORKSPACE, but don't require it when running locally.
REPO_DIR="${GITHUB_WORKSPACE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BUILD_DIR="$REPO_DIR/build"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

sudo apt-get update
sudo apt-get install -y apt live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools curl

lb config \
  --distribution resolute \
  --archive-areas "main restricted universe multiverse" \
  --binary-images iso-hybrid \
  --apt-recommends false \
  --bootappend-live "boot=live components quiet splash"

mkdir -p config/package-lists
cp "$REPO_DIR/config/package-list.txt" config/package-lists/carsonos.list.chroot

# Install the repository-hosted wallpaper into the live filesystem.
WALLPAPER_DIR="config/includes.chroot/usr/share/backgrounds/carsonOS"
mkdir -p "$WALLPAPER_DIR"
curl -fL --retry 3 --retry-delay 2 \
  "https://raw.githubusercontent.com/carjam120443-netizen/carsonOS/main/branding/gnu.jpg" \
  -o "$WALLPAPER_DIR/gnu.jpg"

# Include the XFCE desktop configuration that selects the wallpaper and uses
# the 'Fill' image style so it covers the screen instead of tiling/stretching oddly.
mkdir -p config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml
cp "$REPO_DIR/config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" \
  config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

lb build 2>&1 | tee "$REPO_DIR/build.log"

ISO="$(find . -maxdepth 1 -type f -name '*.iso' -print -quit)"
if [[ -z "$ISO" ]]; then
  echo "ERROR: No ISO was produced."
  exit 1
fi

mkdir -p "$REPO_DIR/out"
cp "$ISO" "$REPO_DIR/out/carsonOS-ubuntu-26.04-amd64.iso"
sha256sum "$REPO_DIR/out/carsonOS-ubuntu-26.04-amd64.iso" > "$REPO_DIR/out/SHA256SUMS"

echo "Built: $REPO_DIR/out/carsonOS-ubuntu-26.04-amd64.iso"
