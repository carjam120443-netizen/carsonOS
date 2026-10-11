# CarsonOS live ISO and installation

## Current approach

The live image uses XFCE and includes the Arch Linux `archinstall` guided installer. The desktop's **Install CarsonOS** launcher opens `archinstall` in a terminal.

This is a practical first installation path, not a custom graphical installer. It installs an Arch-based system using the options selected by the user; it does not yet automatically reproduce every CarsonOS live-session customization.

## Before testing

- Test in VirtualBox first with a disposable virtual disk.
- Take a VM snapshot before installation tests.
- Confirm the target disk by size and device name.
- Installation and partitioning can erase data. Never select a disk containing files you need.
- Review each installer screen and confirm boot mode, partitions, bootloader, users, desktop packages, and network configuration.

## Known limitations

- No custom Calamares graphical installer is included.
- The first install workflow depends on `archinstall` and its current supported configuration.
- The live ISO has not been declared production-ready until it has been built and tested.
- Live-session users and settings are not automatically guaranteed to match the installed system.
- Hardware compatibility varies; test networking, sound, display, suspend, and reboot on each target.

## Build

Run `sudo ./scripts/build-iso.sh` from an Arch Linux build VM after installing `archiso`.
