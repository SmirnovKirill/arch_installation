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

echo "EDITOR=vim" >> /etc/environment
echo "SUDO_EDITOR=vim" >> /etc/environment

#программы
#xorg-xinit для ручной инициализации иксов
pacman -S \
  vim \
  xorg-server \
  xorg-xinit \
  openbox \
  ttf-dejavu
  
localectl --no-convert set-x11-keymap "us,ru" "pc105" "" "grp:alt_shift_toggle"
