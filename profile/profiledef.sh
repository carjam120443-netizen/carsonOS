#!/usr/bin/env bash
iso_name="carsonos"
iso_label="CARSONOS_$(date +%Y%m)"
iso_publisher="CarsonOS Project <https://github.com/carjam120443-netizen/carsonOS>"
iso_application="CarsonOS Live Desktop"
iso_version="$(date +%Y.%m.%d)"
install_dir="carsonos"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi-iso' 'uefi-x64.systemd-boot')
arch=('x86_64')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
file_permissions=(
  ["/root/customize_airootfs.sh"]="0:0:755"
)
