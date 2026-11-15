# CarsonOS live ISO and installation

## Current approach

The live image is intended to use Calamares, built from the AUR during ISO creation. The **Install CarsonOS** desktop icon and System application-menu entry run `carsonos-installer`, which launches Calamares and falls back to `archinstall` if Calamares is unavailable.

The live desktop uses Hyprland by default, with LightDM, NetworkManager, PipeWire/WirePlumber audio, a bottom Waybar, Wofi, Kitty, notifications, clipboard history, idle locking, and the original CarsonOS wallpaper. Cinnamon remains installed as an optional fallback; use **Switch to Cinnamon** to expose LightDM's session chooser.

Calamares is built from the AUR as part of the ISO build, so the build needs internet access and a working Arch build environment. The Calamares setup is experimental and must be validated with a disposable VM before any real installation. The live ISO uses systemd-boot for UEFI and Syslinux for BIOS; the CarsonOS wallpaper is rendered for Hyprpaper in the Hyprland session, not the boot menu.

## Before testing

- Test in VirtualBox first with a disposable virtual disk.
- Take a VM snapshot before installation tests.
- Confirm the target disk by size and device name.
- Installation and partitioning can erase data. Never select a disk containing files you need.
- Review boot mode, partitions, bootloader, users, desktop packages, and network configuration.
- For Wi-Fi, connect through the NetworkManager tray applet before starting installation if the installer needs internet access.

## Known limitations

- Calamares is AUR-built and included, but its installation configuration and desktop package selection have not yet been verified end-to-end. Treat it as experimental; the Archinstall fallback is the currently configured Hyprland install path.
- The `archinstall` fallback now loads `/etc/carsonos/archinstall.json`. It preselects Hyprland, LightDM, NetworkManager, and a graphical boot target, while also installing Cinnamon as an optional fallback. Disk layout, bootloader, and user choices remain for the installer to confirm. Review every selection; this preset does not make installation risk-free.
- The Archinstall preset configures NetworkManager and LightDM, then fetches the current CarsonOS Hyprland dotfiles from GitHub in the installed system. Matching existing config files are backed up before replacement. Internet access is required for this final theming step; if the download fails, the install continues and Hyprland can still generate its default config.
- For UEFI installs, choose a suitable UEFI bootloader in `archinstall`; the live ISO uses systemd-boot for UEFI and Syslinux for BIOS.
- The ISO profile and preset still need a fresh build and a complete disposable-VM install test before being considered verified.
- Live-session users and settings are not automatically copied into the installed system; the preset installs the main desktop/network components separately.
- Hardware compatibility varies; test networking, sound, display, suspend, and reboot on each target.

## Build

From an Arch Linux build VM, install `archiso` and run:

```bash
sudo pacman -Syu
sudo pacman -S --needed archiso git
sudo bash scripts/build-iso.sh
```
