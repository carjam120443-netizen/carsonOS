# CarsonOS

**A custom Arch Linux-based desktop operating system.**

CarsonOS aims to make Arch Linux approachable as a daily desktop OS, with original Carson branding, a ready-to-use XFCE desktop, and a live ISO that boots on a computer and guides the user through installing the system to disk.

> **Project status:** Early development. The live ISO, installer, and hardware support are not yet considered release-ready. Features listed as planned are goals, not claims about the current build.

## Goals

- Boot into a usable live desktop from a USB drive or virtual machine.
- Provide a clear installation path from the live environment to an installed system.
- Use XFCE for a lightweight, familiar desktop experience.
- Keep Arch Linux's standard package-management workflow with `pacman`.
- Add original CarsonOS wallpapers, icons, terminal styling, and system information.
- Keep the build reproducible and the project easy to understand and contribute to.

## Planned stack

| Component | Plan |
| --- | --- |
| Base | Arch Linux, x86_64 |
| Live image | `archiso` |
| Desktop | XFCE |
| Init and services | systemd |
| Package management | pacman and official Arch repositories |
| Installer | Start with a reliable installation workflow; evaluate Calamares for a graphical installer |
| Filesystem | ext4 as the straightforward initial default |
| Initial testing | VirtualBox, then selected physical test systems |

CarsonOS will build on Arch Linux rather than maintaining a separate kernel or package format. Custom CarsonOS tools should initially be packaged separately and use the normal system tools underneath.

## Intended live ISO experience

The intended first release should:

1. Boot into the CarsonOS live desktop.
2. Provide working basic networking, audio, and desktop settings where supported by the hardware.
3. Clearly explain how to start the installer.
4. Install a bootable CarsonOS system onto the selected disk.
5. Reboot into the installed desktop.

The installer must clearly identify the target disk and explain that installing can erase data on that disk. Back up important files before testing an installer.

## Building

Build the ISO from an Arch Linux environment or an Arch Linux virtual machine. Install the required tools:

```bash
sudo pacman -Syu
sudo pacman -S --needed archiso git
```

The project will use an `archiso` profile for the live image. Once the profile is added to this repository, build instructions will be documented here and kept in sync with the actual profile. Build commands depend on the profile directory and should not be treated as available until those files are present.

## Development roadmap

- [ ] Add and validate the initial `archiso` profile.
- [ ] Boot the unmodified live image in VirtualBox.
- [ ] Add XFCE, networking, audio, and a useful default application set.
- [ ] Create the CarsonOS wallpaper, logo, and desktop defaults.
- [ ] Implement and test the install-to-disk workflow.
- [ ] Test fresh installs, rebooting, updates, networking, and common recovery scenarios.
- [ ] Publish a clearly labelled preview ISO with known issues and installation notes.

## Updates and maintenance

CarsonOS follows Arch Linux's rolling-release model. Keep the system updated using supported full-system upgrade workflows; avoid partial upgrades. ISO images should be rebuilt and tested regularly so new installations do not start from a stale package set.

## Contributing and bug reports

Suggestions, bug reports, and contributions are welcome. When reporting an issue, include:

- Whether the issue occurred in VirtualBox or on physical hardware.
- The ISO build or commit you tested.
- The steps to reproduce the issue.
- Relevant error messages or logs, with personal information removed.

## Disclaimer

CarsonOS is an independent project based on Arch Linux. It is not an official Arch Linux release. Early builds are experimental: test them in a virtual machine first and do not install them over a system containing important data.

## License

A project license has not been selected yet. Add a license before distributing project-specific code or assets as an open-source release. Third-party components retain their own licenses.
