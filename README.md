# CarsonOS

**A custom Arch Linux-based desktop operating system.**

CarsonOS aims to make Arch Linux approachable as a daily desktop OS, with original Carson branding, a ready-to-use XFCE desktop, and a live ISO that boots on a computer and provides an installation entry point.

> **Project status:** Early development. The profile and configuration are committed, but an ISO must still be built and tested before the project can claim a working release. The current installer entry launches Arch Linux's guided `archinstall` utility; it is not yet a custom graphical installer.

## Goals

- Boot into a usable live XFCE desktop from USB or a virtual machine.
- Provide a clear path from the live environment to an installed system.
- Keep Arch Linux's standard package-management workflow with `pacman`.
- Add original CarsonOS wallpaper, terminal styling, and system information tools.
- Keep the build reproducible and the project easy to understand and contribute to.

## Planned stack

| Component | Implementation |
| --- | --- |
| Base | Arch Linux, x86_64 |
| Live image | `archiso` profile in `profile/` |
| Desktop | XFCE |
| Display manager | LightDM with automatic login in the live session |
| Init and services | systemd |
| Package management | pacman and official Arch repositories |
| Installer entry point | `archinstall` in a terminal |
| Initial testing | VirtualBox, then selected physical test systems |

The live-session account is `liveuser`. Its passwordless sudo rule is intended only for the disposable live environment. Do not copy that rule into an installed system.

## Build the ISO

Build from an Arch Linux installation or an Arch Linux virtual machine, not directly from Windows. Allocate enough free disk space for downloaded packages, the temporary build tree, and the final ISO.

Install the tools:

```bash
sudo pacman -Syu
sudo pacman -S --needed archiso git
git clone https://github.com/carjam120443-netizen/carsonOS.git
cd carsonOS
```

Build the ISO:

```bash
sudo bash scripts/build-iso.sh
```

The script writes generated ISO files to `out/` and uses `/tmp/carsonos-archiso-work` for temporary build files. You can change the work directory by setting `CARSONOS_WORK_DIR` before running the script.

## Try the live image

1. Create a new VirtualBox VM with a 64-bit Linux profile and a disposable virtual disk.
2. Attach the generated ISO as the optical drive.
3. Boot the VM and choose **CarsonOS Live Desktop**.
4. The intended live session uses XFCE, LightDM, NetworkManager, and the CarsonOS wallpaper and terminal helpers.
5. Open **Install CarsonOS** to start `archinstall`.

The installer is the standard Arch guided installer. Review every option and configure the installed system's bootloader, disk layout, user, network, and desktop packages carefully. Installing can erase the selected disk. For early tests, use only a disposable VM disk.

## Included CarsonOS tools

- `carsonfetch` — basic system and hardware summary.
- `carson-help` — quick reference for common commands.
- `update-system` — shell alias for a full `pacman -Syu` system update.

## Development roadmap

- [x] Add an initial archiso profile for BIOS and UEFI boot.
- [x] Define the first XFCE desktop package set and live-session defaults.
- [x] Add original CarsonOS vector wallpaper and terminal helper commands.
- [ ] Build the ISO successfully on a clean Arch Linux VM.
- [ ] Test booting in VirtualBox in BIOS and UEFI modes.
- [ ] Verify networking, sound, display settings, and the installer entry.
- [ ] Complete fresh-install and reboot testing.
- [ ] Consider a graphical installer after the first installation path is reliable.
- [ ] Publish a clearly labelled preview ISO with known issues and installation notes.

## Updates and maintenance

CarsonOS follows Arch Linux's rolling-release model. Keep the system updated using supported full-system upgrade workflows; avoid partial upgrades. Rebuild and test ISO images regularly so new installations do not start from a stale package set.

## Contributing and bug reports

When reporting an issue, include the ISO build or commit, whether the issue occurred in VirtualBox or on physical hardware, steps to reproduce, and relevant logs with personal information removed.

## Disclaimer

CarsonOS is an independent project based on Arch Linux, not an official Arch Linux release. Early builds are experimental. Test them in a virtual machine first and do not install them over a system containing important data.

## License

A project license has not been selected yet. Add a license before distributing project-specific code or assets as an open-source release. Third-party components retain their own licenses.
