# CarsonOS

**A custom Arch Linux-based desktop operating system.**
<img src="https://www.svgrepo.com/show/349296/arch-linux.svg" alt="Arch Linux logo" width="40" height="40" align="right" />
<img src="https://cdn-icons-png.flaticon.com/512/518/518713.png" alt="linux logo" width="40" height="40" align="right" />
 > ## because arch needs to be simpler sometimes 
 
CarsonOS aims to make Arch Linux approachable as a daily desktop OS, with original Carson branding, a ready-to-use Cinnamon desktop, and a live ISO that boots on a computer and provides an installation entry point.

> **Project status:** Early development. The ISO builds in GitHub Actions and has booted to the CarsonOS live desktop in VirtualBox. Networking, `pacman`, official-repository package installation, and AUR package installation through the included `yay` and `paru` helpers have been tested and work. The optional Hyprland path is still being tested. Calamares is built from the AUR during ISO creation and is the default installer, with `archinstall` retained as a fallback. Both installation paths remain experimental until a fresh ISO is built and a complete install is tested.

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
| Package management | `pacman`, official Arch repositories, and the AUR helpers `yay` and `paru`, built from their AUR PKGBUILDs |
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
5. Use the NetworkManager tray icon to connect to Wi-Fi or inspect wired networking. Networking has been tested in the live environment.
6. Open a terminal: Fastfetch displays the custom CarsonOS ASCII logo. Use `pacman` for official repository packages, or `yay` / `paru` for AUR packages. Package installation through these tools has been tested.
7. Cinnamon is the default desktop and uses the original CarsonOS wallpaper. The desktop shortcut **Cinnamon Desktop** opens the Cinnamon session.
8. Double-click **Easy Archinstall** to launch Archinstall with CarsonOS defaults in a terminal. Review every disk and partition choice carefully before confirming.
9. Double-click **Install Hyprland** to try the optional Hyprland/Wayland desktop and CarsonOS theme (Waybar pinned to the bottom, matching Wofi/Kitty styling, and the default CarsonOS wallpaper rendered for Hyprpaper). This path is still being tested; the live session resets installed packages on reboot.
10. Double-click **Install CarsonOS** to launch Calamares. The installer is built from the AUR during ISO creation and remains experimental until a full install test passes. Test recommended only in a disposable VM; installation can erase data.
11. or use archinstall or easy-archinstall they're the same thing just easy-archinstall is faster to run. 

## Included CarsonOS tools

- `fastfetch` — system summary with the built-in CarsonOS ASCII logo; it runs automatically when an interactive terminal opens.
- `yay` — AUR helper built during ISO creation. AUR packages are community-maintained; review PKGBUILDs before installing packages.
- `paru` — second AUR helper, also built during ISO creation. Both helpers can install packages from the AUR; normal `pacman` package management remains available for official repositories.
- `carsonfetch` — basic system and hardware summary, using the same white/blue/dark-gray CarsonOS ASCII banner as Fastfetch.
- `cfan-git` — optional fan-control utility built from the AUR when its CPU-specific build step is supported by the ISO builder. A failed build does not block the ISO; when included, it is not configured or enabled automatically, and fan support depends on physical hardware and sensor interfaces.
- `adb-gripper` — graphical Android device manager for common ADB tasks; requires a connected device with USB or wireless debugging authorized.
- `adb-wifi-scanner` — scans for Android devices available through ADB wireless debugging; its command is `adbw`.
- `adbcontrol` — Java-based ADB remote-control utility for viewing and interacting with a connected Android device.
- `android-tools` — provides `adb` and `fastboot`, the platform tools used by the Android utilities.
- `carson-help` — quick reference for common commands.
- `carsonos-hyprland` — installs Hyprland and supporting Wayland tools on demand, renders the default CarsonOS wallpaper for Hyprpaper, applies the bundled Hyprland/Waybar/Wofi/Kitty theme, and disables live-session autologin so LightDM's session selector is available.
- Cinnamon — the default desktop environment, with the original CarsonOS wallpaper.
- Brave Origin — the default browser for HTTP/HTTPS links and HTML files; Firefox remains available as an alternative.
- `carsonos-installer` — launches Calamares, falling back to `archinstall` if needed.
- `easy-archinstall` — launches Archinstall directly with the CarsonOS preset when available; the **Easy Archinstall** desktop shortcut opens it in a terminal. Disk and partition choices remain interactive.
- `update-system` — shell alias for a full `pacman -Syu` system update.

## Development roadmap

- [x] Add an initial archiso profile for BIOS and UEFI boot.
- [x] Set Cinnamon as the default desktop and configure the CarsonOS wallpaper.
- [x] Add original CarsonOS vector wallpaper and terminal helper commands.
- [x] Add NetworkManager tray controls and PipeWire audio packages.
- [x] Add a desktop and menu launcher for the `archinstall` guided installer.
- [x] Add the `easy-archinstall` command and an **Easy Archinstall** desktop shortcut.
- [x] Build the ISO successfully in GitHub Actions.
- [x] Boot the live desktop in VirtualBox and verify the CarsonOS wallpaper.
- [x] Add an optional Hyprland setup script and a CarsonOS-themed Waybar pinned to the bottom.
- [x] Test booting in both BIOS and UEFI modes.
- [x] Verify live networking, `pacman`, and official-repository package installation.
- [x] Verify AUR helper operation and AUR package installation with `yay` / `paru`.
- [ ] Complete a full fresh-install and post-install reboot test.
- [ ] Verify CarsonOS branding and desktop defaults on a fully installed system.
- [ ] Test the AUR-built Calamares installer end-to-end, including partitioning, filesystem setup, bootloader installation, and first boot.
- [ ] Publish a clearly labelled preview ISO with known issues and installation notes.
- [ ] test easy-archinstall 

## Updates and maintenance

CarsonOS follows Arch Linux's rolling-release model. Keep the system updated using supported full-system upgrade workflows; avoid partial upgrades. Rebuild and test ISO images regularly so new installations do not start from a stale package set.

## Contributing and bug reports

When reporting an issue, include the ISO build or commit, whether the issue occurred in VirtualBox or on physical hardware, steps to reproduce, and relevant logs with personal information removed.

## Disclaimer

CarsonOS is an independent project based on Arch Linux, not an official Arch Linux release. Early builds are experimental. Test them in a virtual machine first and do not install them over a system containing important data.

## warning 
if you do install on a real machine please always make sure to back up your old os configs

## License

A project license has not been selected yet. Add a license before distributing project-specific code or assets as an open-source release. Third-party components retain their own licenses.
