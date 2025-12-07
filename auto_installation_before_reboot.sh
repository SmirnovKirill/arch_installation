#!/usr/bin/env bash

set -euxo pipefail

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/variables.sh"
source "$CURRENT_DIRECTORY/functions.sh"
source "$CURRENT_DIRECTORY/config_sync.sh"

function install_pacman_dependencies() {
      #--needed для повторных запусков
      #efibootmgr для граба
      #xorg-xinit для ручной инициализации иксов
      #xorg-xinput для отключения тачпада
      #udiskie для автомонтирования
      #ntfs-3g чтобы ntfs можно было смотреть
      #lxqt-notificationd и libnotify для уведомлений на рабочем столе https://wiki.archlinux.org/title/Desktop_notifications
      #imagemagick для скриншотов
      #xarchiver для интеграции с pcmanfm
      #strongswan для l2tp
      #pulseaudio-alsa, pulseaudio-bluetooth и bluez-utils для bluetooth гарнитуры
      #nss-mdns для печати (с avahi)
      #doncf для того чтобы сразу конфиги workrave прописать
      #libsecret нужен для кейринга
      #inetutils всякие ping, traceroute, telnet и тд
      #usbutils - для lsusb
      #rsync - для tilt но и вообще полезно
      #ncdu смотреть использование диска
      pacman -S --needed \
        base-devel \
        wpa_supplicant \
        grub \
        efibootmgr \
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
        lxqt-notificationd \
        libnotify \
        papirus-icon-theme \
        imagemagick \
        filezilla \
        jdk11-openjdk \
        jdk17-openjdk \
        jdk21-openjdk \
        thunderbird \
        xarchiver \
        zip \
        unzip \
        unrar \
        7zip \
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
        python-pipx \
        python-poetry \
        skaffold \
        telegram-desktop \
        dconf \
        htop \
        gnome-keyring \
        libsecret \
        gvfs-mtp \
        borg \
        firefox \
        inetutils \
        obsidian \
        noto-fonts-emoji \
        wget \
        usbutils \
        rsync \
        ncdu \
        mousepad \
        slock
}

function add_user_and_groups() {
  useradd -m "$USER"
  passwd "$USER"
  sed -i "/root ALL=(ALL:ALL) ALL/a $USER ALL=(ALL:ALL) ALL" /etc/sudoers
  passwd #пароль для рута
  passwd -l root #отключаем возможность логиниться рутом
  gpasswd -a "$USER" docker #иначе контейнер с постгресом в тестах не поднимался
}

function install_aur_dependencies() {
    #--needed для повторных запусков
    #отдельно запускаем потому что из AUR под рутом
    #jdk20-openj9-bin для билда поиска
    #woeusb-ng загрузочные флешки для винды
    #acpilight для управления яркостью
    sudo -u "$USER" yay -S --needed \
      pinta \
      jdk20-openj9-bin \
      woeusb-ng \
      adr-tools \
      postman-bin \
      tilt-bin \
      google-chrome \
      zoom \
      acpilight \
      amneziavpn-bin \
      cisco-secure-client \
      downgrade
}

function install_optional_dependencies() {
    if [[ $MODE == "LAPTOP" ]];
    then
      #sof-firmware чтобы звук работал
      pacman -S --needed \
        sof-firmware
    fi

    if [[ $MODE == "DESKTOP" ]];
    then
      #На домашнем компе клавиатура k290 у которой функциональные клавиши работают только при нажатии вместе с FN.
      #rtl88xxau-aircrack-dkms-git Для wifi модуля
      sudo -u "$USER" yay -S --needed \
          k290-fnkeyctl \
          rtl88xxau-aircrack-dkms-git
    fi
}

function set_environment_variables() {
  echo "EDITOR=vim" >> /etc/environment
  echo "SUDO_EDITOR=vim" >> /etc/environment
  echo "TARGET_TEST_STAND=ts62.pyn.ru" >> /etc/environment
  echo "TEST_STAND_SSH_IDENTITY=file:~/.ssh/pkey.hh" >> /etc/environment

}

function install_loader() {
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
}

install_pacman_dependencies
add_user_and_groups #надо делать после установки базовой (где будет установлен докер и sudo) и до AUR
install_yay
install_aur_dependencies
install_optional_dependencies
install_loader

sudo -u "$USER" git config --global user.email "$GIT_USER_EMAIL_WORK"
sudo -u "$USER" git config --global user.name "$GIT_USER_NAME"

set_environment_variables

archlinux-java set java-21-openjdk

if [[ $MODE == "LAPTOP" ]]; 
then
  usermod -a -G video $USER #группа для работы с яркостью экрана
  echo "blacklist psmouse" >> /etc/modprobe.d/blacklist.conf #отключение модуля с тачпадом чтобы не сыпались ошибки что устройство не найдено
fi

sudo -u "$USER" mkdir "/home/$USER/.config" -p
sudo -u "$USER" mkdir "/home/$USER/.config/pcmanfm/default" -p
sudo -u "$USER" mkdir "/home/$USER/.config/libfm" -p
sudo -u "$USER" mkdir "/home/$USER/.config/lxpanel/default/panels" -p
sudo -u "$USER" mkdir "/home/$USER/.config/filezilla" -p
sudo -u "$USER" mkdir "/home/$USER/.m2" -p
sudo -u "$USER" mkdir "/home/$USER/Desktop" -p
cp "$CURRENT_DIRECTORY/configs/anyconnect_hh.xml" "/opt/cisco/secureclient/vpn/profile"
config_sync "$CURRENT_DIRECTORY"

sudo -u "$USER" cp "$CURRENT_DIRECTORY/configs/filezilla/sitemanager.xml" "/home/$USER/.config/filezilla/sitemanager.xml"
substitute_variables "/home/$USER/.config/filezilla/sitemanager.xml"

cp "$CURRENT_DIRECTORY/configs/90-backlight.rules" "/etc/udev/rules.d/90-backlight.rules"

udevadm control --reload-rules
udevadm trigger #код выше чтобы часы распознавались при подключении

sed -i 's/hosts: mymachines resolve/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve/g' /etc/nsswitch.conf #чтобы принтер искался
sed -i 's/Listen \/run\/cups\/cups.sock/#Listen \/run\/cups\/cups.sock/g' /etc/cups/cupsd.conf #чтобы не было бесконечного ожидания принтера при печати

sed -i '/^auth[[:space:]]\+include[[:space:]]\+system-local-login[[:space:]]*$/a auth       optional   pam_gnome_keyring.so' /etc/pam.d/login
sed -i '/^session[[:space:]]\+include[[:space:]]\+system-local-login[[:space:]]*$/a session    optional   pam_gnome_keyring.so auto_start' /etc/pam.d/login

sudo -u "$USER" git clone "$REPOSITORY_ROOT_URL/arch_installation.git" "/home/$USER/arch_installation"
