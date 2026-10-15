# CarsonOS live ISO and installation

## Current approach

The live image currently uses the Arch `archinstall` guided installer. The **Install CarsonOS** desktop icon and System application-menu entry run `carsonos-installer`, which launches `archinstall` in the live session.

The live desktop is configured around XFCE, LightDM, NetworkManager, a tray applet for network controls, PipeWire/WirePlumber audio, volume controls, a dark CarsonOS terminal palette, and the original CarsonOS wallpaper.

Calamares is not bundled because it is not available from the enabled official Arch repositories. It was removed from the package list so ISO builds can proceed. The live ISO uses systemd-boot for UEFI, the maintained successor to gummiboot, and Syslinux for BIOS. The boot menu stays text-based by design; the CarsonOS wallpaper is used on the desktop rather than forced into the bootloader.

## Before testing

- Test in VirtualBox first with a disposable virtual disk.
- Take a VM snapshot before installation tests.
- Confirm the target disk by size and device name.
- Installation and partitioning can erase data. Never select a disk containing files you need.
- Review boot mode, partitions, bootloader, users, desktop packages, and network configuration.
- For Wi-Fi, connect through the NetworkManager tray applet before starting installation if the installer needs internet access.

## Known limitations

- Calamares is not included in the ISO yet. A separately packaged build and a complete install test are needed before it can be offered.
- The `archinstall` fallback relies on the version bundled in the live image; it is normally recommended for use from the official Arch Linux ISO.
- For UEFI installs, select systemd-boot in `archinstall` (the maintained successor to gummiboot). The live ISO uses systemd-boot for UEFI and Syslinux for BIOS.
- The ISO profile has not been declared working until it has been built and tested.
- Live-session users and settings are not automatically guaranteed to match the installed system.
- Hardware compatibility varies; test networking, sound, display, suspend, and reboot on each target.

## Build

From an Arch Linux build VM, install `archiso` and run:

```bash
sudo pacman -Syu
sudo pacman -S --needed archiso git
sudo bash scripts/build-iso.sh
```
