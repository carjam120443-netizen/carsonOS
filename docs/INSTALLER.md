# CarsonOS live ISO and installation

## Current approach

The live image includes the Arch Linux `archinstall` guided installer. The **Install CarsonOS** desktop icon and System application-menu entry both run `carsonos-installer`, which starts `archinstall` with elevated privileges in the live session.

The live desktop is configured around XFCE, LightDM, NetworkManager, a tray applet for network controls, PipeWire/WirePlumber audio, volume controls, a dark CarsonOS terminal palette, and the original CarsonOS wallpaper.

This is the first installation path, not a custom graphical installer. The selected `archinstall` options determine what is installed; the live session's full CarsonOS customization is not automatically guaranteed to carry over.

## Before testing

- Test in VirtualBox first with a disposable virtual disk.
- Take a VM snapshot before installation tests.
- Confirm the target disk by size and device name.
- Installation and partitioning can erase data. Never select a disk containing files you need.
- Review boot mode, partitions, bootloader, users, desktop packages, and network configuration.
- For Wi-Fi, connect through the NetworkManager tray applet before starting installation if the installer needs internet access.

## Known limitations

- No custom Calamares graphical installer is included.
- The installer relies on the version of `archinstall` available in the live image; it is normally recommended for use from the official Arch Linux ISO.
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
