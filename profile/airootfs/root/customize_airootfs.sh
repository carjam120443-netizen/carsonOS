#!/usr/bin/env bash
set -euo pipefail

# Runs while mkarchiso assembles the live root filesystem.
if ! id liveuser >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash --groups wheel,audio,video,storage,optical,power liveuser
fi

install -d -m 0755 /etc/sudoers.d
printf '%s\n' 'liveuser ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-carsonos-live
chmod 0440 /etc/sudoers.d/10-carsonos-live
visudo -cf /etc/sudoers.d/10-carsonos-live

install -d -m 0755 /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-carsonos.conf <<'EOF'
[Seat:*]
greeter-session=lightdm-gtk-greeter
autologin-user=liveuser
autologin-user-timeout=0
EOF

install -d -m 0755 /etc/skel
cat > /etc/skel/.bashrc.carsonos <<'EOF'
# CarsonOS interactive shell additions.
alias ll='ls -alF'
alias update-system='sudo pacman -Syu'
alias carson-help='printf "%s\\n" "CarsonOS quick help:" "  update-system  Update installed packages" "  pacman -S <pkg> Install a package" "  carsonfetch     Show system information"'
EOF
if ! grep -q 'bashrc.carsonos' /etc/skel/.bashrc 2>/dev/null; then
  printf '\n# CarsonOS defaults\n[[ -f ~/.bashrc.carsonos ]] && source ~/.bashrc.carsonos\n' >> /etc/skel/.bashrc
fi

cat > /usr/local/bin/carson-help <<'EOF'
#!/usr/bin/env bash
cat <<'HELP'
CarsonOS quick help

  carsonfetch       Show basic system information
  carson-help       Show this help
  update-system     Update packages with pacman
  sudo archinstall  Start the guided Arch installation assistant

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
  printf '  %-12s %s\n' 'CPU' "$(lscpu | awk -F: '/Model name/ {sub(/^[ \\t]+/, "", $2); print $2; exit}')"
fi
if command -v free >/dev/null 2>&1; then
  printf '  %-12s %s\n' 'Memory' "$(free -h | awk '/^Mem:/ {print $3 " used / " $2; exit}')"
fi
EOF
chmod 0755 /usr/local/bin/carsonfetch

cat > /etc/motd <<'EOF'
Welcome to CarsonOS Live!

This is an early development image. Use carson-help for quick commands.
Run carsonfetch to display system information.
The Install CarsonOS launcher starts archinstall; review every disk choice.
Back up important files before installing.
EOF

install -d -m 0755 /etc/xdg/autostart
install -d -m 0755 /usr/share/applications
cat > /usr/share/applications/carsonos-installer.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Install CarsonOS
Comment=Start the Arch Linux installation assistant
Exec=xfce4-terminal --title="CarsonOS Installer" --command="sudo archinstall"
Icon=system-software-install
Terminal=false
Categories=System;
EOF

systemctl enable NetworkManager.service
systemctl enable lightdm.service
systemctl enable systemd-timesyncd.service
