#!/usr/bin/env bash
set -euo pipefail

# carsonOS Ubuntu 26.04 LTS ISO builder
# Ubuntu 26.04 LTS is codenamed Resolute Raccoon.

export DEBIAN_FRONTEND=noninteractive

BUILD_DIR="${GITHUB_WORKSPACE:-$(pwd)}/build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

sudo apt-get update
sudo apt-get install -y live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools

lb config \
  --distribution resolute \
  --archive-areas "main restricted universe multiverse" \
  --binary-images iso-hybrid \
  --apt-recommends true \
  --bootappend-live "boot=live components quiet splash"

mkdir -p config/package-lists
cp "$GITHUB_WORKSPACE/config/package-list.txt" config/package-lists/carsonos.list.chroot

lb build 2>&1 | tee "$GITHUB_WORKSPACE/build.log"

ISO="$(find . -maxdepth 1 -type f -name '*.iso' -print -quit)"
if [[ -z "$ISO" ]]; then
  echo "ERROR: No ISO was produced."
  exit 1
fi

mkdir -p "$GITHUB_WORKSPACE/out"
cp "$ISO" "$GITHUB_WORKSPACE/out/carsonOS-ubuntu-26.04-amd64.iso"
sha256sum "$GITHUB_WORKSPACE/out/carsonOS-ubuntu-26.04-amd64.iso" > "$GITHUB_WORKSPACE/out/SHA256SUMS"

echo "Built: $GITHUB_WORKSPACE/out/carsonOS-ubuntu-26.04-amd64.iso"
