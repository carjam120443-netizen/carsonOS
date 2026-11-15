#!/usr/bin/env bash
set -Eeuo pipefail

# Apply the current CarsonOS Hyprland desktop configuration to an installed
# Arch system. Archinstall runs this from its post-install chroot hook.
# Existing files are backed up before CarsonOS replaces matching paths.

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

BASE_URL="https://raw.githubusercontent.com/carjam120443-netizen/carsonOS/main"
TMP_DIR="$(mktemp -d /tmp/carsonos-hyprland-config.XXXXXX)"
BACKUP_SUFFIX=".carsonos-backup-$(date +%Y%m%d-%H%M%S)"

cleanup() {
  rm -rf -- "$TMP_DIR"
}
trap cleanup EXIT

CONFIG_FILES=(
  "hypr/hyprland.lua"
  "hypr/hyprpaper.conf"
  "hypr/hypridle.conf"
  "hypr/hyprlock.conf"
  "waybar/config.jsonc"
  "waybar/style.css"
  "wofi/style.css"
  "kitty/kitty.conf"
  "swaync/style.css"
)

for relative_path in "${CONFIG_FILES[@]}"; do
  source_path="profile/airootfs/etc/skel/.config/$relative_path"
  destination="$TMP_DIR/$relative_path"
  install -d -m 0755 "$(dirname "$destination")"
  curl --fail --silent --show-error --location \
    "$BASE_URL/$source_path" \
    --output "$destination"
done

POWER_MENU="$TMP_DIR/carsonos-power-menu"
curl --fail --silent --show-error --location \
  "$BASE_URL/profile/airootfs/usr/local/bin/carsonos-power-menu" \
  --output "$POWER_MENU"

WALLPAPER_DIR="$TMP_DIR/wallpaper"
install -d -m 0755 "$WALLPAPER_DIR"
curl --fail --silent --show-error --location \
  "$BASE_URL/profile/airootfs/usr/share/backgrounds/carsonos/default.svg" \
  --output "$WALLPAPER_DIR/default.svg"

if ! command -v rsvg-convert >/dev/null 2>&1; then
  echo "librsvg is required to render the CarsonOS wallpaper (rsvg-convert missing)." >&2
  exit 1
fi
rsvg-convert --width 1920 --height 1080 \
  --output "$WALLPAPER_DIR/default.png" "$WALLPAPER_DIR/default.svg"

backup_if_present() {
  local destination="$1"
  if [[ -e "$destination" ]]; then
    cp -a -- "$destination" "$destination$BACKUP_SUFFIX"
  fi
}

apply_to_home() {
  local home="$1"
  local owner="$2"

  install -d -m 0755 "$home/.config"
  for relative_path in "${CONFIG_FILES[@]}"; do
    local destination="$home/.config/$relative_path"
    install -d -m 0755 "$(dirname "$destination")"
    backup_if_present "$destination"
    install -m 0644 "$TMP_DIR/$relative_path" "$destination"
    chown "$owner" "$destination"
  done

  chown -R "$owner" "$home/.config/hypr" "$home/.config/waybar" \
    "$home/.config/wofi" "$home/.config/kitty" "$home/.config/swaync"
}

# Install the native CarsonOS power menu.\ninstall -m 0755 "$POWER_MENU" /usr/local/bin/carsonos-power-menu\n\n# Install the system-wide wallpaper once.
WALLPAPER_DESTINATION="/usr/share/backgrounds/carsonos"
install -d -m 0755 "$WALLPAPER_DESTINATION"
for wallpaper in default.svg default.png; do
  backup_if_present "$WALLPAPER_DESTINATION/$wallpaper"
  install -m 0644 "$WALLPAPER_DIR/$wallpaper" "$WALLPAPER_DESTINATION/$wallpaper"
done

# Seed future user accounts.
apply_to_home "/etc/skel" "root:root"

# Apply the same desktop to regular user accounts already created by Archinstall.
while IFS=: read -r username home; do
  [[ -d "$home" ]] || continue
  primary_group="$(id -gn "$username")"
  apply_to_home "$home" "$username:$primary_group"
done < <(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 && $6 ~ /^\/home\// { print $1 ":" $6 }')

echo "CarsonOS Hyprland configuration and wallpaper installed."
echo "Existing matching config files were backed up with suffix: $BACKUP_SUFFIX"
