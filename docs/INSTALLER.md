# CarsonOS live ISO and installation

## Current approach

The live image includes a first Calamares graphical installer configuration. The **Install CarsonOS** desktop icon and System application-menu entry run `carsonos-installer`, which launches Calamares through PolicyKit when available and falls back to the Arch `archinstall` guided installer if Calamares cannot be launched.

The live desktop is configured around XFCE, LightDM, NetworkManager, a tray applet for network controls, PipeWire/WirePlumber audio, volume controls, a dark CarsonOS terminal palette, and the original CarsonOS wallpaper.

Calamares is configured to extract the live root filesystem, create the requested user, and use GRUB as the installed system's bootloader. The CarsonOS wallpaper is converted to PNG for GRUB and configured as the installed system's GRUB background. This is an early integration and has not yet been verified in a fresh ISO build; the live image is not yet declared a reliable installer.

## Before testing

- Test in VirtualBox first with a disposable virtual disk.
- Take a VM snapshot before installation tests.
- Confirm the target disk by size and device name.
- Installation and partitioning can erase data. Never select a disk containing files you need.
- Review boot mode, partitions, bootloader, users, desktop packages, and network configuration.
- For Wi-Fi, connect through the NetworkManager tray applet before starting installation if the installer needs internet access.

## Known limitations

- Calamares source-image extraction, partitioning, and installed-system cleanup still require testing in a freshly built ISO.
- The `archinstall` fallback relies on the version bundled in the live image; it is normally recommended for use from the official Arch Linux ISO.
- GRUB is configured for the installed system; the ISO's own boot menu still uses the existing archiso BIOS/UEFI boot modes.
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
