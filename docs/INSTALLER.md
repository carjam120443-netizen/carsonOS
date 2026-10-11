# CarsonOS live ISO and installation

## Current approach

The live image includes the Arch Linux `archinstall` guided installer. The **Install CarsonOS** desktop launcher opens it in a terminal.

This is the first installation path, not a custom graphical installer. The selected `archinstall` options determine what is installed; the live session's full CarsonOS customization is not automatically guaranteed to carry over.

## Before testing

- Test in VirtualBox first with a disposable virtual disk.
- Take a VM snapshot before installation tests.
- Confirm the target disk by size and device name.
- Installation and partitioning can erase data. Never select a disk containing files you need.
- Review boot mode, partitions, bootloader, users, desktop packages, and network configuration.

## Known limitations

- No custom Calamares graphical installer is included.
- The installer relies on the version of `archinstall` available in the live image.
- The ISO profile has not been declared working until it has been built and tested.
- Live-session users and settings are not automatically guaranteed to match the installed system.
- Hardware compatibility varies; test networking, sound, display, suspend, and reboot on each target.

## Build

From an Arch Linux build VM, install `archiso` and run:

```bash
sudo bash scripts/build-iso.sh
```
