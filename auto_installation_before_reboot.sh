#!/bin/sh

set -ex

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/installation_variables.sh"

sed -i 's/#TotalDownload/TotalDownload/g' /etc/pacman.conf #общий прогрессбар

#efibootmgr для граба
#xorg-xinit для ручной инициализации иксов
#xorg-xinput для отключения тачпада
#udiskie для автомонтирования
#imagemagick для скриншотов
#meld для diff
#xarchiver для интеграции с pcmanfm
pacman -S \
  sudo \
  wpa_supplicant \
  grub \
  efibootmgr \
  base-devel \
  vim \
  xorg-server \
  xorg-xinit \
  xorg-xinput \
  openbox \
  ttf-dejavu \
  xterm \
  pcmanfm \
  udiskie \
  lxpanel \
  papirus-icon-theme \
  leafpad \
  imagemagick \
  pinta \
  meld \
  filezilla \
  chromium \
  jdk-openjdk \
  jdk8-openjdk \
  thunderbirdn \
  xarchiver \
  zip \
  unzip
    
#загрузчик
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB

if [[ $WINDOWS_INSTALLED == "y" ]]; then
  FS_UUSID="$(grub-probe --target=fs_uuid /efi/EFI/Microsoft/Boot/bootmgfw.efi)"
  HINTS_STRING="$(grub-probe --target=hints_string /efi/EFI/Microsoft/Boot/bootmgfw.efi)"

  cat << EndOfText >> /boot/grub/custom.cfg
menuentry "$WINDOWS_GRUB_ENTRY_TITLE" {
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

useradd -m $USER
passwd $USER
sed -i "/root ALL=(ALL) ALL/a $USER ALL=(ALL) ALL" /etc/sudoers
passwd #пароль для рута
passwd -l root #отключаем возможность логиниться рутом

sudo -u $USER git clone $REPOSITORY_URL /home/$USER/arch_installation #выкачать заново, уже в домашнюю директорию
sudo -u $USER git config --global user.email $GIT_USER_EMAIL
sudo -u $USER git config --global user.name $GIT_USER_NAME 

echo "EDITOR=vim" >> /etc/environment
echo "SUDO_EDITOR=vim" >> /etc/environment

echo "blacklist psmouse" >> /etc/modprobe.d/blacklist.conf #отключение модуля с тачпадом чтобы не сыпались ошибки что устройство не найдено

sudo -u $USER mkdir "/home/$USER/.config" -p

sudo -u $USER cp "$CURRENT_DIRECTORY/configs/.bashrc" "/home/$USER/.bashrc"
sudo -u $USER cp "$CURRENT_DIRECTORY/configs/.xinitrc" "/home/$USER/.xinitrc"

sudo -u $USER mkdir "/home/$USER/.config/pcmanfm/default" -p
sudo -u $USER cp "$CURRENT_DIRECTORY/configs/desktop-items-0.conf" "/home/$USER/.config/pcmanfm/default/desktop-items-0.conf"
substitute_variables "/home/$USER/.config/pcmanfm/default/desktop-items-0.conf"

sudo -u $USER cp /etc/xdg/openbox "/home/$USER/.config" -r
sudo -u $USER cp "$CURRENT_DIRECTORY/configs/autostart" "/home/$USER/.config/openbox/autostart"
sudo -u $USER cp "$CURRENT_DIRECTORY/configs/rc.xml" "/home/$USER/.config/openbox/rc.xml"
substitute_variables "/home/$USER/.config/openbox/autostart"
substitute_variables "/home/$USER/.config/openbox/rc.xml"

sudo -u $USER cp "$CURRENT_DIRECTORY/configs/.Xresources" "/home/$USER/.Xresources"
substitute_variables "/home/$USER/.Xresources"

sudo -u $USER cp "$CURRENT_DIRECTORY/configs/.gtkrc-2.0" "/home/$USER/.gtkrc-2.0"
substitute_variables "/home/$USER/.gtkrc-2.0"

sudo -u $USER mkdir "/home/$USER/.config/libfm" -p
sudo -u $USER cp "$CURRENT_DIRECTORY/configs/libfm.conf" "/home/$USER/.config/libfm/libfm.conf"
substitute_variables "/home/$USER/.config/libfm/libfm.conf"

sudo -u $USER mkdir "/home/$USER/.config/lxpanel/default/panels" -p
sudo -u $USER cp "$CURRENT_DIRECTORY/configs/panel" "/home/$USER/.config/lxpanel/default/panels/panel"
substitute_variables "/home/$USER/.config/lxpanel/default/panels/panel"

sudo -u $USER mkdir "/home/$USER/Desktop" -p
sudo -u $USER cp "$CURRENT_DIRECTORY/configs/desktop/"* "/home/$USER/Desktop/"

sudo -u $USER cp "$CURRENT_DIRECTORY/configs/.vimrc" "/home/$USER/.vimrc"
substitute_variables "/home/$USER/.vimrc"

sudo -u $USER mkdir "/home/$USER/.sqldeveloper/18.3.0" -p
sudo -u $USER cp "$CURRENT_DIRECTORY/configs/product.conf" "/home/$USER/.sqldeveloper/18.3.0/product.conf"
