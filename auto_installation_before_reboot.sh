#!/bin/sh

set -ex

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/installation_variables.sh"
source "$CURRENT_DIRECTORY/functions.sh"
source "$CURRENT_DIRECTORY/config_sync.sh"

#efibootmgr для граба
#xorg-xinit для ручной инициализации иксов
#xorg-xinput для отключения тачпада
#udiskie для автомонтирования
#ntfs-3g чтобы ntfs можно было смотреть
#imagemagick для скриншотов
#xarchiver для интеграции с pcmanfm
#strongswan для l2tp
#pulseaudio-alsa, pulseaudio-bluetooth и bluez-utils для bluetooth гарнитуры
#nss-mdns для печати (с avahi)
#doncf для того чтобы сразу конфиги workrave прописать
pacman -S \
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
  ntfs-3g \
  lxpanel \
  papirus-icon-theme \
  leafpad \
  imagemagick \
  pinta \
  filezilla \
  jdk11-openjdk \
  jdk17-openjdk \
  thunderbird \
  xarchiver \
  zip \
  unzip \
  unrar \
  p7zip \
  networkmanager \
  network-manager-applet \
  networkmanager-openvpn \
  networkmanager-l2tp \
  strongswan \
  openssh \
  transmission-gtk \
  vlc \
  evince \
  maven \
  libreoffice-still \
  workrave \
  pulseaudio-alsa \
  pavucontrol \
  pulseaudio-bluetooth \
  bluez-utils \
  physlock \
  mattermost-desktop \
  avahi \
  nss-mdns \
  cups \
  sane \
  simple-scan \
  ffmpeg \
  gthumb \
  docker \
  kubectl \
  python \
  python-pip \
  skaffold \
  telegram-desktop \
  dconf

if [[ $MODE == "WORK" ]];
then
  #sof-firmware чтобы звук работал
  pacman -S \
    sof-firmware
fi
    
#загрузчик
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB

if [[ $WINDOWS_INSTALLED == "y" ]]; 
then
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
sed -i "/root ALL=(ALL:ALL) ALL/a $USER ALL=(ALL:ALL) ALL" /etc/sudoers
passwd #пароль для рута
passwd -l root #отключаем возможность логиниться рутом
gpasswd -a $USER docker #иначе контейнер с постгресом в тестах не поднимался

sudo -u $USER git clone $REPOSITORY_URL /home/$USER/arch_installation #выкачать заново, уже в домашнюю директорию
if [[ $MODE == "WORK" ]]; 
then
  sudo -u $USER git config --global user.email $GIT_USER_EMAIL_WORK
else
  sudo -u $USER git config --global user.email $GIT_USER_EMAIL_HOME
fi  
sudo -u $USER git config --global user.name $GIT_USER_NAME 

echo "EDITOR=vim" >> /etc/environment
echo "SUDO_EDITOR=vim" >> /etc/environment
echo "SVN_SSH=ssh -l svn" >> /etc/environment

archlinux-java set java-17-openjdk

if [[ $MODE == "LAPTOP" ]]; 
then
  usermod -a -G video $USER #группа для работы с яркостью экрана
  echo "blacklist psmouse" >> /etc/modprobe.d/blacklist.conf #отключение модуля с тачпадом чтобы не сыпались ошибки что устройство не найдено
fi

sudo -u $USER mkdir "/home/$USER/.config" -p
sudo -u $USER mkdir "/home/$USER/.config/pcmanfm/default" -p
sudo -u $USER mkdir "/home/$USER/.config/libfm" -p
sudo -u $USER mkdir "/home/$USER/.config/lxpanel/default/panels" -p
sudo -u $USER mkdir "/home/$USER/.config/filezilla" -p
sudo -u $USER mkdir "/home/$USER/.m2" -p
sudo -u $USER mkdir "/home/$USER/Desktop" -p
config_sync $CURRENT_DIRECTORY

sudo -u $USER cp "$CURRENT_DIRECTORY/configs/.bash_history" "/home/$USER/.bash_history"

sudo -u $USER cp "$CURRENT_DIRECTORY/configs/filezilla/sitemanager.xml" "/home/$USER/.config/filezilla/sitemanager.xml"
substitute_variables "/home/$USER/.config/filezilla/sitemanager.xml"

cp "$CURRENT_DIRECTORY/configs/90-backlight.rules" "/etc/udev/rules.d/90-backlight.rules"

sudo -u $USER mkdir "/home/$USER/software/AUR" -p

install_from_aur https://aur.archlinux.org/acpilight.git /home/$USER/software/AUR/acpilight #управление яркостью
install_from_aur https://aur.archlinux.org/google-chrome.git /home/$USER/software/AUR/chrome
install_from_aur https://aur.archlinux.org/zoom.git /home/$USER/software/AUR/zoom

#На домашнем компе клавиатура k290 у которой функциональные клавиши работают только при нажатии вместе с FN.
if [[ $MODE == "HOME" ]];
then
  install_from_aur https://aur.archlinux.org/k290-fnkeyctl.git /home/$USER/software/AUR/k290-fnkeyctl
fi

if [[ $MODE == "WORK" ]]; 
then
  install_from_aur https://aur.archlinux.org/teams.git /home/$USER/software/AUR/teams
fi

sed -i 's/hosts: mymachines resolve/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve/g' /etc/nsswitch.conf #чтобы принтер искался
sed -i 's/Listen \/run\/cups\/cups.sock/#Listen \/run\/cups\/cups.sock/g' /etc/cups/cupsd.conf #чтобы не было бесконечного ожидания принтера при печати
