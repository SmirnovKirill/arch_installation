#!/bin/sh

set -ex

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/installation_variables.sh"

#локаль, время
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
timedatectl set-ntp true
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf 

#общий прогрессбар
sed -i 's/#TotalDownload/TotalDownload/g' /etc/pacman.conf

#программы
#xorg-xrandr чтобы управлять разрешением экрана
#lxde-common минимальные требования lxde
#lxsession минимальные требования lxde
#pinta редактор
#meld для diff
pacman -S \
  xorg-server \
  xorg-xrandr \
  openbox \
  lxde-common \
  lxsession \
  lxpanel \
  lxdm \
  lxterminal \
  pcmanfm \
  ttf-dejavu \
  zip \
  unzip \
  imagemagick \
  gpicview \
  pinta \
  meld

echo "EDITOR=vim" >> /etc/environment
echo "SUDO_EDITOR=vim" >> /etc/environment

localectl --no-convert set-x11-keymap "ru,us" "pc105" "" "grp:alt_shift_toggle"

systemctl enable lxdm

cp "$CURRENT_DIRECTORY/resources/desktop.jpg" /usr/share/lxde/wallpapers/desktop.jpg
cp "$CURRENT_DIRECTORY/configs/desktop-items-0.conf" /home/kirill/.config/lxpanel/LXDE/panels/desktop-items-0.conf
cp "$CURRENT_DIRECTORY/configs/lxde-rc.xml" /home/kirill/.config/openbox/lxde-rc.xml
cp "$CURRENT_DIRECTORY/configs/lxdm.conf" /etc/lxdm/lxdm.conf
cp "$CURRENT_DIRECTORY/configs/panel" /home/kirill/.config/lxpanel/LXDE/panels/panel
