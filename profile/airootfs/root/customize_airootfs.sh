#!/usr/bin/env bash
set -euo pipefail

# Preserve the stock repository configuration; Chaotic-AUR stays opt-in.
install -d -m 0755 /etc/pacman.d/carsonos-repo-backup
if [[ ! -e /etc/pacman.d/carsonos-repo-backup/pacman.conf ]]; then
  cp -a /etc/pacman.conf /etc/pacman.d/carsonos-repo-backup/pacman.conf
fi
if [[ -f /etc/pacman.d/mirrorlist && ! -e /etc/pacman.d/carsonos-repo-backup/mirrorlist ]]; then
  cp -a /etc/pacman.d/mirrorlist /etc/pacman.d/carsonos-repo-backup/mirrorlist
fi

# Optional one-command setup for users who want Chaotic-AUR.
cat > /usr/local/bin/enable-chaotic-aur <<'CHAOTIC'
#!/usr/bin/env bash
set -euo pipefail
if [[ $EUID -ne 0 ]]; then
  echo "Run with: sudo enable-chaotic-aur" >&2
  exit 1
fi
BACKUP_DIR=/etc/pacman.d/carsonos-repo-backup
install -d -m 0755 "$BACKUP_DIR"
if [[ ! -e "$BACKUP_DIR/pacman.conf" ]]; then
  cp -a /etc/pacman.conf "$BACKUP_DIR/pacman.conf"
fi
if [[ -f /etc/pacman.d/mirrorlist && ! -e "$BACKUP_DIR/mirrorlist" ]]; then
  cp -a /etc/pacman.d/mirrorlist "$BACKUP_DIR/mirrorlist"
fi
PACMAN_KEY="$(command -v pacman-key)"
"$PACMAN_KEY" --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
"$PACMAN_KEY" --lsign-key 3056513887B78AEB
pacman -U --noconfirm \
  https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst \
  https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst
if ! grep -Fqx '[chaotic-aur]' /etc/pacman.conf; then
  printf '\n%s\n%s\n' '# CarsonOS optional Chaotic-AUR repository' '[chaotic-aur]' >> /etc/pacman.conf
  printf '%s\n' 'Include = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf
fi
pacman -Syu --noconfirm
echo "Chaotic-AUR enabled; original config backup is in /etc/pacman.d/carsonos-repo-backup"
CHAOTIC
chmod 0755 /usr/local/bin/enable-chaotic-aur

# This script is run by the live image's first-boot customization service.
if ! id liveuser >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash --groups wheel,audio,video,storage,optical,power liveuser
fi
# Requested default password for the live account (autologin remains enabled).
printf '%s\n' 'liveuser:live' | chpasswd

install -d -m 0755 /etc/sudoers.d
printf '%s\n' 'liveuser ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-carsonos-live
chmod 0440 /etc/sudoers.d/10-carsonos-live
visudo -cf /etc/sudoers.d/10-carsonos-live

# CarsonOS live-session identity.
cat > /etc/os-release <<'EOF'
NAME="CarsonOS"
PRETTY_NAME="CarsonOS Live"
ID=carsonos
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="0;32"
HOME_URL="https://github.com/carjam120443-netizen/carsonOS"
SUPPORT_URL="https://github.com/carjam120443-netizen/carsonOS/issues"
BUG_REPORT_URL="https://github.com/carjam120443-netizen/carsonOS/issues"
EOF
printf '%s\n' 'carsonos-live' > /etc/hostname

install -d -m 0755 /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-carsonos.conf <<'EOF'
[Seat:*]
greeter-session=lightdm-gtk-greeter
autologin-user=liveuser
autologin-user-timeout=0
EOF

# Keep the live user's shell helpful without overwriting the distro defaults.
install -d -m 0755 /etc/skel
touch /etc/skel/.bashrc
cat > /etc/skel/.bashrc.carsonos <<'EOF'
# CarsonOS interactive shell additions.
alias ll='ls -alF'
alias update-system='sudo pacman -Syu'
if [[ $- == *i* ]] && command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi
alias carson-help='printf "%s\\n" "CarsonOS quick help:" "  update-system  Update installed packages" "  pacman -S <pkg> Install a package" "  carsonfetch     Show system information"'
EOF
if ! grep -q 'bashrc.carsonos' /etc/skel/.bashrc; then
  printf '\n# CarsonOS defaults\n[[ -f ~/.bashrc.carsonos ]] && source ~/.bashrc.carsonos\n' >> /etc/skel/.bashrc
fi

cat > /usr/local/bin/carson-help <<'EOF'
#!/usr/bin/env bash
cat <<'HELP'
CarsonOS quick help

  carsonfetch       Show system information
  fastfetch         Show system information with the CarsonOS ASCII logo
  yay               Search and install packages from official repos and the AUR
  carsonos-hyprland Install the optional Hyprland desktop
  carsonos-cinnamon Install the optional Cinnamon desktop
  carson-help       Show this help
  update-system     Update packages with pacman
  carsonos-installer Start the guided Arch installation assistant

CarsonOS is an early development image. Review the target disk carefully
before installing; installation can erase data.
HELP
EOF
chmod 0755 /usr/local/bin/carson-help

cat > /usr/local/bin/carsonfetch <<'EOF'
#!/usr/bin/env bash
set -eu
printf '\033[1;32m'
cat <<'LOGO'
   ____                          ____  _____
  / ___|__ _ _ __ ___  ___  _ __/ ___|| ____|
 | |   / _` | '__/ __|/ _ \\| '_ \\___ \\|  _|
 | |__| (_| | | | (__| (_) | | | |__) | |___
  \\____\\__,_|_|  \\___|\\___/|_| |_|____/|_____|
LOGO
printf '\033[0m'
printf '  %-12s %s\n' 'OS' 'CarsonOS (Arch-based)'
printf '  %-12s %s\n' 'Kernel' "$(uname -r)"
printf '  %-12s %s\n' 'Architecture' "$(uname -m)"
printf '  %-12s %s\n' 'Hostname' "$(hostname)"
if command -v lscpu >/dev/null 2>&1; then
  printf '  %-12s %s\n' 'CPU' "$(lscpu | awk -F: '/Model name/ {sub(/^[ \t]+/, "", $2); print $2; exit}')"
fi
if command -v free >/dev/null 2>&1; then
  printf '  %-12s %s\n' 'Memory' "$(free -h | awk '/^Mem:/ {print $3 " used / " $2; exit}')"
fi
EOF
chmod 0755 /usr/local/bin/carsonfetch

cat > /usr/local/bin/carsonos-installer <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if ! command -v archinstall >/dev/null 2>&1; then
  xfce4-terminal --title="CarsonOS Installer" --command="bash -lc 'echo CarsonOS installer is missing; check the ISO package list; read -r -p "Press Enter to close..."'" 
  exit 1
fi
exec sudo archinstall
EOF
chmod 0755 /usr/local/bin/carsonos-installer

cat > /etc/motd <<'EOF'
Welcome to CarsonOS Live!

Use carson-help for quick commands and carsonfetch for system information.
Double-click Install CarsonOS on the desktop to start the guided installer.
Review every disk choice carefully; installation can erase data.
EOF

# Put a visible installer icon on the live user's desktop and in the app menu.
install -d -m 0755 /etc/skel/Desktop /home/liveuser/Desktop /usr/share/applications
cat > /usr/share/applications/carsonos-installer.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Install CarsonOS
Comment=Install CarsonOS using the guided Arch installer
Exec=carsonos-installer
Icon=system-software-install
Terminal=true
Categories=System;
StartupNotify=true
EOF
install -m 0644 /usr/share/applications/carsonos-installer.desktop /etc/skel/Desktop/Install\ CarsonOS.desktop
install -m 0644 /usr/share/applications/carsonos-installer.desktop /home/liveuser/Desktop/Install\ CarsonOS.desktop
install -m 0644 /usr/share/applications/carsonos-hyprland.desktop /home/liveuser/Desktop/Install\ Hyprland.desktop
install -m 0644 /usr/share/applications/carsonos-cinnamon.desktop /home/liveuser/Desktop/Install\ Cinnamon.desktop
chmod 0755 /usr/local/bin/carsonos-hyprland /usr/local/bin/carsonos-cinnamon
chown -R liveuser:liveuser /home/liveuser/Desktop
cp /etc/skel/.bashrc /home/liveuser/.bashrc
cp /etc/skel/.bashrc.carsonos /home/liveuser/.bashrc.carsonos
install -d -m 0755 /home/liveuser/.config
cp -a /etc/skel/.config/fastfetch /home/liveuser/.config/
cp -a /etc/skel/.config/hypr /home/liveuser/.config/
# Reapply the ISO's XFCE channel settings explicitly, including the pinned panel.
install -d -m 0755 /home/liveuser/.config/xfce4/xfconf/xfce-perchannel-xml
cp -af /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml /home/liveuser/.config/xfce4/xfconf/xfce-perchannel-xml/
chown liveuser:liveuser /home/liveuser/.bashrc /home/liveuser/.bashrc.carsonos
chown -R liveuser:liveuser /home/liveuser/.config/fastfetch /home/liveuser/.config/hypr /home/liveuser/.config/xfce4

# NetworkManager starts for Ethernet and Wi-Fi; the applet exposes Wi-Fi controls.
# PipeWire's user sockets provide audio and PulseAudio compatibility.
systemctl enable NetworkManager.service
systemctl enable lightdm.service
systemctl enable systemd-timesyncd.service

# Install the yay package built by scripts/build-iso.sh in the build environment.
# The target live root stays free of the Go compiler and base-devel toolchain.
YAY_PACKAGE="/root/yay.pkg.tar.zst"
if [[ ! -f "$YAY_PACKAGE" ]]; then
  echo "Missing staged yay package. Build the ISO with scripts/build-iso.sh." >&2
  exit 1
fi

# CheckSpace cannot determine a mount point for the target root while this
# customization runs inside mkarchiso's chroot. Disable only that check for
# this local package transaction; keep all other Pacman settings unchanged.
YAY_PACMAN_CONFIG="$(mktemp /tmp/carsonos-pacman-yay.XXXXXX.conf)"
sed '/^[[:space:]]*CheckSpace[[:space:]]*$/d' /etc/pacman.conf > "$YAY_PACMAN_CONFIG"
pacman --config "$YAY_PACMAN_CONFIG" -U --noconfirm "$YAY_PACKAGE"
rm -f "$YAY_PACKAGE" "$YAY_PACMAN_CONFIG"


# Configure Calamares as CarsonOS's graphical installer.
# Convert the existing CarsonOS wallpaper to a GRUB-supported PNG.
if command -v rsvg-convert >/dev/null 2>&1 && [[ -f /usr/share/backgrounds/carsonos/default.svg ]]; then
  rsvg-convert -o /usr/share/backgrounds/carsonos/default.png /usr/share/backgrounds/carsonos/default.svg
fi
if [[ -f /etc/default/grub ]]; then
  sed -i '/^GRUB_BACKGROUND=/d' /etc/default/grub
  printf '%s\n' 'GRUB_BACKGROUND="/usr/share/backgrounds/carsonos/default.png"' >> /etc/default/grub
fi

install -d -m 0755 /etc/calamares/modules /etc/calamares/branding/carsonos
cat > /etc/calamares/settings.conf <<'CALAMARES_SETTINGS'
modules-search: [ local, /usr/lib/calamares/modules ]
sequence:
  - show:
      - welcome
      - locale
      - keyboard
      - partition
      - users
      - summary
      - finished
      - restart
  - exec:
      - partition
      - mount
      - unpackfs
      - machineid
      - fstab
      - locale
      - keyboard
      - localecfg
      - users
      - displaymanager
      - networkcfg
      - hwclock
      - services
      - shellprocess
      - bootloader
      - initramfs
      - grubcfg
      - umount
branding: carsonos
CALAMARES_SETTINGS

cat > /etc/calamares/modules/unpackfs.conf <<'CALAMARES_UNPACK'
unpack:
  - source: "/run/archiso/bootmnt/arch/x86_64/airootfs.sfs"
    sourcefs: "squashfs"
    destination: ""
CALAMARES_UNPACK

cat > /etc/calamares/modules/bootloader.conf <<'CALAMARES_BOOTLOADER'
efiBootLoader: "grub"
grubInstall: true
grubMkconfig: true
CALAMARES_BOOTLOADER

cat > /etc/calamares/modules/shellprocess.conf <<'CALAMARES_SHELLPROCESS'
dontChroot: false
timeout: 60
script: "/usr/local/bin/carsonos-calamares-finalize.sh"
CALAMARES_SHELLPROCESS

cat > /etc/calamares/branding/carsonos/branding.desc <<'CALAMARES_BRANDING'
componentName: CarsonOS
welcomeStyle: sidebar
strings:
  productName: CarsonOS
  shortProductName: CarsonOS
  version: rolling
  shortVersion: rolling
  bootloaderEntryName: CarsonOS
  productUrl: https://github.com/carjam120443-netizen/carsonOS
  supportUrl: https://github.com/carjam120443-netizen/carsonOS/issues
images:
  productLogo: carsonos.svg
CALAMARES_BRANDING

cat > /etc/calamares/branding/carsonos/carsonos.svg <<'CALAMARES_LOGO'
<svg xmlns="http://www.w3.org/2000/svg" width="160" height="160" viewBox="0 0 160 160">
  <rect x="8" y="8" width="64" height="64" rx="8" fill="#4cff91"/>
  <rect x="88" y="8" width="64" height="64" rx="8" fill="#35b8ff"/>
  <rect x="8" y="88" width="64" height="64" rx="8" fill="#35b8ff"/>
  <rect x="88" y="88" width="64" height="64" rx="8" fill="#4cff91"/>
</svg>
CALAMARES_LOGO

# Remove live-session privilege escalation and autologin from the installed copy.
cat > /usr/local/bin/carsonos-calamares-finalize.sh <<'CALAMARES_FINALIZE'
#!/usr/bin/env bash
set -euo pipefail
passwd -l liveuser 2>/dev/null || true
gpasswd -d liveuser wheel 2>/dev/null || true
rm -f /etc/sudoers.d/10-carsonos-live
if [[ -f /etc/lightdm/lightdm.conf.d/50-carsonos.conf ]]; then
  sed -i '/^autologin-user=/d; /^autologin-user-timeout=/d' /etc/lightdm/lightdm.conf.d/50-carsonos.conf
fi
sed -i 's/^NAME="CarsonOS Live"$/NAME="CarsonOS"/; s/^PRETTY_NAME="CarsonOS Live"$/PRETTY_NAME="CarsonOS"/' /etc/os-release
printf '%s\n' 'carsonos' > /etc/hostname
CALAMARES_FINALIZE
chmod 0755 /usr/local/bin/carsonos-calamares-finalize.sh

# Prefer Calamares, but keep the guided installer available as a fallback.
cat > /usr/local/bin/carsonos-installer <<'CARSONOS_INSTALLER'
#!/usr/bin/env bash
set -euo pipefail
if command -v calamares >/dev/null 2>&1 && command -v pkexec >/dev/null 2>&1; then
  exec pkexec calamares
fi
if command -v archinstall >/dev/null 2>&1; then
  exec xfce4-terminal --title="CarsonOS Installer" --command="sudo archinstall"
fi
echo "No graphical or guided installer is available." >&2
exit 1
CARSONOS_INSTALLER
chmod 0755 /usr/local/bin/carsonos-installer

cat > /usr/share/applications/carsonos-installer.desktop <<'CALAMARES_DESKTOP'
[Desktop Entry]
Type=Application
Name=Install CarsonOS
Comment=Install CarsonOS with the Calamares graphical installer
Exec=carsonos-installer
Icon=system-software-install
Terminal=false
Categories=System;
StartupNotify=true
CALAMARES_DESKTOP
install -m 0644 /usr/share/applications/carsonos-installer.desktop /etc/skel/Desktop/Install\ CarsonOS.desktop
install -m 0644 /usr/share/applications/carsonos-installer.desktop /home/liveuser/Desktop/Install\ CarsonOS.desktop
chown liveuser:liveuser /home/liveuser/Desktop/Install\ CarsonOS.desktop
