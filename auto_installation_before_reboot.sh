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
#jdk8-openjdk для sqldeveloper
#xarchiver для интеграции с pcmanfm
#pulseaudio-alsa, pulseaudio-bluetooth и bluez-utils для bluetooth гарнитуры
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
  xbindkeys \
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
  jdk8-openjdk \
  jdk11-openjdk \
  thunderbird \
  xarchiver \
  zip \
  unzip \
  unrar \
  p7zip \
  subversion \
  networkmanager \
  network-manager-applet \
  networkmanager-openvpn \
  openssh \
  transmission-gtk \
  vlc \
  evince \
  maven \
  libreoffice-still \
  workrave \
  pulseaudio-alsa \
  pulseaudio-bluetooth \
  bluez-utils \
  physlock
    
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
echo "SVN_SSH=ssh -l svn" >> /etc/environment

if [[ $MODE == "LAPTOP" ]]; then
  usermod -a -G video $USER #группа для работы с яркостью экрана
  echo "blacklist psmouse" >> /etc/modprobe.d/blacklist.conf #отключение модуля с тачпадом чтобы не сыпались ошибки что устройство не найдено
fi

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
substitute_variables "/home/$USER/Desktop/telegram.desktop"
substitute_variables "/home/$USER/Desktop/idea.desktop"

sudo -u $USER cp "$CURRENT_DIRECTORY/configs/.vimrc" "/home/$USER/.vimrc"
substitute_variables "/home/$USER/.vimrc"

cp "$CURRENT_DIRECTORY/configs/90-backlight.rules" "/etc/udev/rules.d/90-backlight.rules"

sudo -u $USER cp "$CURRENT_DIRECTORY/configs/.xbindkeysrc" "/home/$USER/.xbindkeysrc"

sudo -u $USER mkdir "/home/$USER/software/AUR" -p

sudo -u $USER git clone https://aur.archlinux.org/acpilight.git /home/$USER/software/AUR/acpilight #управление яркостью
cd /home/$USER/software/AUR/acpilight
sudo -u $USER makepkg -si
cd /home/$USER

#На домашнем компе клавиатура k290 у которой функциональные клавиши работают только при нажатии вместе с FN.
if [[ $MODE == "HOME" ]]; then
  sudo -u $USER git clone https://aur.archlinux.org/k290-fnkeyctl.git /home/$USER/software/AUR/k290-fnkeyctl
  cd /home/$USER/software/AUR/k290-fnkeyctl
  sudo -u $USER makepkg -si
  cd /home/$USER
fi

sudo -u $USER git clone https://aur.archlinux.org/google-chrome.git /home/$USER/software/AUR/chrome
cd /home/$USER/software/AUR/chrome
sudo -u $USER makepkg -si
cd /home/$USER

sudo -u $USER git clone https://aur.archlinux.org/zoom.git /home/$USER/software/AUR/zoom
cd /home/$USER/software/AUR/zoom
sudo -u $USER makepkg -si
cd /home/$USER

if [[ $MODE == "HEADHUNTER" ]]; then
  sudo -u $USER git clone https://aur.archlinux.org/slack-desktop.git /home/$USER/software/AUR/slack
  cd /home/$USER/software/AUR/slack
  sudo -u $USER makepkg -si
  cd /home/$USER
  
  sudo -u $USER git clone https://aur.archlinux.org/teams.git /home/$USER/software/AUR/teams
  cd /home/$USER/software/AUR/teams
  sudo -u $USER makepkg -si
  cd /home/$USER
fi
