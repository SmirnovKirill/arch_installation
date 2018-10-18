#!/bin/sh

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

grub-mkconfig -o /boot/grub/grub.cfg
