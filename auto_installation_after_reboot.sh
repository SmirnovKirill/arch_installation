#!/usr/bin/env bash

set -euxo pipefail

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/variables.sh"

systemctl enable NetworkManager --now
systemctl enable avahi-daemon --now
systemctl enable bluetooth --now
systemctl enable docker --now
systemctl enable cups --now

sudo -u "$USER" cat "$CURRENT_DIRECTORY/configs/workrave.ini" | dconf load /

sudo -u "$USER" mkdir "/home/$USER/.ssh" -p
sudo -u "$USER" cp "$ARCH_INSTALL_USB/ssh/"* "/home/$USER/.ssh/"
sudo -u "$USER" chmod 700 "/home/$USER/.ssh/id_rsa"
sudo -u "$USER" chmod 700 "/home/$USER/.ssh/test-stand-key"
sudo -u "$USER" chmod 700 "/home/$USER/.ssh/pkey.hh"

sudo -u "$USER" cp "$ARCH_INSTALL_USB/software/idea" "/home/$USER/software/" -r
sudo -u "$USER" cp "$ARCH_INSTALL_USB/software/reset_jb.sh" "/home/$USER/software/"
chmod +x "/home/$USER/software/idea/bin/idea.sh"

sudo -u "$USER" cp "$ARCH_INSTALL_USB/maven/settings.xml" "/home/$USER/.m2/settings.xml"

cp "$ARCH_INSTALL_USB/hhtestersCAnew.crt" "/tmp/"
trust anchor --store /tmp/hhtestersCAnew.crt
update-ca-trust

cp "$ARCH_INSTALL_USB/amnezia_configs/"* "/tmp/"

#локаль, время
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
timedatectl set-ntp true
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf 

sudo -u "$USER" git clone "$REPOSITORY_ROOT_URL/arch_installation.git" "/home/$USER/arch_installation"
sudo -u "$USER" git clone "$REPOSITORY_ROOT_URL/obsidian_work.git" "/home/$USER/Obsidian Vault"

sudo -u "$USER" pipx install 'git+ssh://git@forgejo.pyn.ru/hhru/hh-tilt.git@master'
