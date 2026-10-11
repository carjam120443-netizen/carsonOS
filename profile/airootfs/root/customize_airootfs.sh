#!/usr/bin/env bash
set -euo pipefail

# Preserve the original repository configuration before enabling Chaotic-AUR.
# These copies let users restore the original Arch repository setup later.
install -d -m 0755 /etc/pacman.d/carsonos-repo-backup
if [[ ! -e /etc/pacman.d/carsonos-repo-backup/pacman.conf ]]; then
  cp -a /etc/pacman.conf /etc/pacman.d/carsonos-repo-backup/pacman.conf
fi
if [[ -f /etc/pacman.d/mirrorlist && ! -e /etc/pacman.d/carsonos-repo-backup/mirrorlist ]]; then
  cp -a /etc/pacman.d/mirrorlist /etc/pacman.d/carsonos-repo-backup/mirrorlist
fi
if ! grep -q '^\\[chaotic-aur\\]' /etc/pacman.conf; then
  cat >> /etc/pacman.conf <<'EOF'

# CarsonOS: Chaotic-AUR binary package repository
[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
fi

# This script is run by the live image's first-boot customization service.
if ! id liveuser >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash --groups wheel,audio,video,storage,optical,power liveuser
fi

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
chown -R liveuser:liveuser /home/liveuser/Desktop
cp /etc/skel/.bashrc /home/liveuser/.bashrc
cp /etc/skel/.bashrc.carsonos /home/liveuser/.bashrc.carsonos
chown liveuser:liveuser /home/liveuser/.bashrc /home/liveuser/.bashrc.carsonos

# NetworkManager starts for Ethernet and Wi-Fi; the applet exposes Wi-Fi controls.
# PipeWire's user sockets provide audio and PulseAudio compatibility.
systemctl enable NetworkManager.service
systemctl enable lightdm.service
systemctl enable systemd-timesyncd.service
