#!/usr/bin/env bash
set -euo pipefail

# carsonOS Ubuntu 26.04 LTS ISO builder
# Works both in GitHub Actions and when run locally.

export DEBIAN_FRONTEND=noninteractive

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
  --bootappend-live "boot=live components quiet splash" \
  --memtest none

mkdir -p config/package-lists config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml
cp "$REPO_DIR/config/package-list.txt" config/package-lists/carsonos.list.chroot

# Copy repository chroot hooks, if present.
if [[ -d "$REPO_DIR/config/hooks/normal" ]]; then
  find "$REPO_DIR/config/hooks/normal" -type f -name '*.hook.chroot' -exec cp {} config/hooks/ \;
fi
find config/hooks -maxdepth 1 -type f -name '*.hook.chroot' -exec chmod +x {} +

# The Ubuntu live-build stack may create dangling initrd symlinks during
# kernel handling. Remove them immediately before binary kernel processing;
# the actual versioned initramfs is preserved.
cat > config/hooks/9999-remove-dangling-initrd.hook.binary <<'EOF'
#!/bin/sh
set -eu
for link in chroot/boot/initrd.img chroot/boot/initrd.img.old; do
    if [ -L "$link" ] && [ ! -e "$link" ]; then
        echo "Removing dangling initramfs symlink: $link"
        rm -f -- "$link"
    fi
done
EOF
chmod +x config/hooks/9999-remove-dangling-initrd.hook.binary

WALLPAPER_DIR="config/includes.chroot/usr/share/backgrounds/carsonOS"
mkdir -p "$WALLPAPER_DIR"
curl -fL --retry 3 --retry-delay 2 \
  "https://raw.githubusercontent.com/carjam120443-netizen/carsonOS/main/branding/gnu.jpg" \
  -o "$WALLPAPER_DIR/gnu.jpg"

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
