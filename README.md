# CarsonOS

**A custom Arch Linux-based desktop operating system.**
<img src="https://www.svgrepo.com/show/349296/arch-linux.svg" alt="Arch Linux logo" width="40" height="40" align="right" />
<img src="https://cdn-icons-png.flaticon.com/512/518/518713.png" alt="linux logo" width="40" height="40" align="right" />

CarsonOS aims to make Arch Linux approachable as a daily desktop OS, with original Carson branding, a ready-to-use Cinnamon desktop, and a live ISO that boots on a computer and provides an installation entry point.

> **Project status:** Early development. The ISO builds in GitHub Actions and has booted to the CarsonOS live desktop in VirtualBox. Network/package installation and the optional Hyprland path are still being tested. Calamares is built from the AUR during ISO creation and is the default installer, with `archinstall` retained as a fallback. The installer remains experimental until a fresh ISO is built and a full install is tested.

## Goals

- Boot into a usable live Cinnamon desktop from USB or a virtual machine.
- Provide a clear path from the live environment to an installed system.
- Keep Arch Linux's standard package-management workflow with `pacman`.
- Add original CarsonOS wallpaper, terminal styling, and system information tools.
- Keep the build reproducible and the project easy to understand and contribute to.

## Planned stack

| Component | Implementation |
| --- | --- |
| Base | Arch Linux, x86_64 |
| Live image | `archiso` profile in `profile/` |
| Desktop | Cinnamon (default); XFCE tools retained for compatibility |
| Display manager | LightDM with automatic login in the live session |
| Networking | NetworkManager and its XFCE-friendly tray applet |
| Audio | PipeWire, WirePlumber, PulseAudio compatibility, and volume controls |
| Init and services | systemd |
| Bootloader | systemd-boot for UEFI (the maintained successor to gummiboot); Syslinux for BIOS |
| Package management | pacman, official Arch repositories, and `yay` built from its AUR PKGBUILD |
| System information | `fastfetch` with a custom CarsonOS ASCII logo, shown when a terminal opens |
| Optional desktops | Hyprland; Cinnamon is the default desktop |
| Installer | Calamares from the AUR, with `archinstall` as a fallback |
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
4. The intended live session uses Cinnamon, LightDM, NetworkManager, the volume controls, and the CarsonOS wallpaper and terminal helpers.
5. Use the NetworkManager tray icon to connect to Wi-Fi or inspect wired networking.
6. Fastfetch displays the custom CarsonOS ASCII logo when you open a terminal.
7. Cinnamon is the default desktop and uses the original CarsonOS wallpaper. The desktop shortcut **Cinnamon Desktop** opens the Cinnamon session.
8. Double-click **Install Hyprland** to install the optional Hyprland/Wayland desktop in the live session. Then log out and select **Hyprland** from the LightDM session menu.
9. Double-click **Install CarsonOS** to launch Calamares. The installer is built from the AUR during ISO creation and remains experimental until a full install test passes. Test only in a disposable VM; installation can erase data.

## Included CarsonOS tools

- `fastfetch` — system summary with the built-in CarsonOS ASCII logo; it runs automatically when an interactive terminal opens.
- `yay` — AUR helper built during the ISO customization step. AUR packages are community-maintained; review PKGBUILDs before installing packages.
- `carsonfetch` — basic system and hardware summary.
- `carson-help` — quick reference for common commands.
- `carsonos-hyprland` — installs Hyprland and its supporting Wayland tools on demand.
- Cinnamon — the default desktop environment, with the original CarsonOS wallpaper.
- `carsonos-installer` — launches Calamares, falling back to `archinstall` if needed.
- `update-system` — shell alias for a full `pacman -Syu` system update.

## Development roadmap

- [x] Add an initial archiso profile for BIOS and UEFI boot.
- [x] Set Cinnamon as the default desktop and configure the CarsonOS wallpaper.
- [x] Add original CarsonOS vector wallpaper and terminal helper commands.
- [x] Add NetworkManager tray controls and PipeWire audio packages.
- [x] Add a desktop and menu launcher for the `archinstall` guided installer.
- [x] Build the ISO successfully in GitHub Actions.
- [x] Boot the live desktop in VirtualBox and verify the CarsonOS wallpaper.
- [ ] Test booting in both BIOS and UEFI modes.
- [ ] Verify networking, sound, display settings, and the installer entry.
- [ ] Complete fresh-install and reboot testing.
- [ ] Ensure the installed system receives CarsonOS branding and desktop defaults.
- [ ] Test the AUR-built Calamares installer end-to-end, including partitioning, filesystem setup, bootloader installation, and first boot.
- [ ] Publish a clearly labelled preview ISO with known issues and installation notes.

## Updates and maintenance

CarsonOS follows Arch Linux's rolling-release model. Keep the system updated using supported full-system upgrade workflows; avoid partial upgrades. Rebuild and test ISO images regularly so new installations do not start from a stale package set.

## Contributing and bug reports

When reporting an issue, include the ISO build or commit, whether the issue occurred in VirtualBox or on physical hardware, steps to reproduce, and relevant logs with personal information removed.

## Disclaimer

CarsonOS is an independent project based on Arch Linux, not an official Arch Linux release. Early builds are experimental. Test them in a virtual machine first and do not install them over a system containing important data.

## License

A project license has not been selected yet. Add a license before distributing project-specific code or assets as an open-source release. Third-party components retain their own licenses.
