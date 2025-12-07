#!/usr/bin/env bash

set -euxo pipefail

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/variables.sh"

systemctl enable NetworkManager --now
systemctl enable avahi-daemon --now
systemctl enable bluetooth --now
systemctl enable docker --now
systemctl enable cups --now
systemctl enable vpnagentd.service --now #для cisco anyconnect, написано в AUR что надо так сделать

sudo -u "$USER" mkdir "/home/$USER/.ssh" -p
sudo -u "$USER" cp "$ARCH_INSTALL_USB/ssh/"* "/home/$USER/.ssh/"
sudo -u "$USER" chmod 700 "/home/$USER/.ssh/id_rsa"
sudo -u "$USER" chmod 700 "/home/$USER/.ssh/test-stand-key"
sudo -u "$USER" chmod 700 "/home/$USER/.ssh/pkey.hh"

sudo -u "$USER" cp "$ARCH_INSTALL_USB/software/idea" "/home/$USER/software/" -r
sudo -u "$USER" cp "$ARCH_INSTALL_USB/software/reset_jb.sh" "/home/$USER/software/"
chmod +x "/home/$USER/software/idea/bin/idea.sh"

sudo -u "$USER" cp "$ARCH_INSTALL_USB/maven/settings.xml" "/home/$USER/.m2/settings.xml"

wget https://crt.pyn.ru/hhtestersCA2025.crt -O /tmp/crt.crt
trust anchor --store /tmp/crt.crt
update-ca-trust

cp "$ARCH_INSTALL_USB/amnezia_configs/"* "/tmp/"

#локаль, время
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
timedatectl set-ntp true
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

log_info "Нажми любую клавишу после того как подключишь вайфай"
read -n1 -s

sudo -u "$USER" git clone "$REPOSITORY_ROOT_URL/obsidian_work.git" "/home/$USER/Obsidian Vault"

log_info "Нажми любую клавишу после того как подключишь vpn"
read -n1 -s

sudo -u "$USER" pipx install 'git+ssh://git@forgejo.pyn.ru/hhru/hh-tilt.git@master'
sudo -u "$USER" docker login registry.pyn.ru
sudo -u "$USER" mkdir -p "/home/$USER/programming/work"
