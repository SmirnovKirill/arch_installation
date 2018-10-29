#!/bin/sh

set -ex

source installation_variables.sh

#программы
#efibootmgr для граба
pacman -S \
  wpa_supplicant \
  grub \
  efibootmgr 
  
#загрузчик
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB

if [[ $WINDOWS_INSTALLED == "y" ]] then
  FS_UUSID="$(grub-probe --target=fs_uuid /efi/EFI/Microsoft/Boot/bootmgfw.efi)"
  HINTS_STRING="$(grub-probe --target=hints_string /efi/EFI/Microsoft/Boot/bootmgfw.efi)"

  cat << EndOfText >> /boot/grub/custom.cfg
  menuentry "Microsoft Windows 10" {
    insmod part_gpt
    insmod fat
    insmod search_fs_uuid
    insmod chain
    search --fs-uuid --set=root $HINTS_STRING $FS_UUSID
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
  }
  EndOfText
fi

grub-mkconfig -o /boot/grub/grub.cfg
