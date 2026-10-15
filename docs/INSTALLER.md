# CarsonOS live ISO and installation

## Current approach

The live image is intended to use Calamares, built from the AUR during ISO creation. The **Install CarsonOS** desktop icon and System application-menu entry run `carsonos-installer`, which launches Calamares and falls back to `archinstall` if Calamares is unavailable.

The live desktop uses Cinnamon by default, with LightDM, NetworkManager, PipeWire/WirePlumber audio, volume controls, and the original CarsonOS wallpaper.

Calamares is built from the AUR as part of the ISO build, so the build needs internet access and a working Arch build environment. The Calamares setup is experimental and must be validated with a disposable VM before any real installation. The live ISO uses systemd-boot for UEFI and Syslinux for BIOS; the CarsonOS wallpaper is applied to Cinnamon, not the boot menu.

## Before testing

- Test in VirtualBox first with a disposable virtual disk.
- Take a VM snapshot before installation tests.
- Confirm the target disk by size and device name.
- Installation and partitioning can erase data. Never select a disk containing files you need.
- Review boot mode, partitions, bootloader, users, desktop packages, and network configuration.
- For Wi-Fi, connect through the NetworkManager tray applet before starting installation if the installer needs internet access.

## Known limitations

- Calamares is AUR-built and included, but its installation configuration has not yet been verified end-to-end. Treat it as experimental.
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
