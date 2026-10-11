#!/usr/bin/env bash
# CarsonOS archiso profile definition.
iso_name="carsonos"
iso_label="CARSONOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="CarsonOS Project <https://github.com/carjam120443-netizen/carsonOS>"
iso_application="CarsonOS Live Desktop"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="carsonos"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi.systemd-boot')
arch=('x86_64')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/root/customize_airootfs.sh"]="0:0:755"
)
