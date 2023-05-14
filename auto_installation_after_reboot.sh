#!/bin/sh

set -ex

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/installation_variables.sh"

systemctl enable NetworkManager --now
systemctl enable avahi-daemon --now
systemctl enable bluetooth --now
systemctl enable docker --now

sudo -u $USER cat "$CURRENT_DIRECTORY/configs/workrave.ini" | dconf load /

sudo -u $USER mkdir "/home/$USER/.ssh" -p
sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/ssh/"* "/home/$USER/.ssh/"
sudo -u $USER chmod 700 "/home/$USER/.ssh/id_rsa"
sudo -u $USER chmod 700 "/home/$USER/.ssh/test-stand-key"
sudo -u $USER chmod 700 "/home/$USER/.ssh/pkey.hh"

sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/idea" "/home/$USER/software/" -r
chmod +x "/home/$USER/software/idea/bin/idea.sh"

sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/maven/settings.xml" "/home/$USER/.m2/settings.xml"

sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/.thunderbird" "/home/$USER/" -r

cp "/run/media/$USER/$USB_NAME/arch_installation/network/"* "/etc/NetworkManager/system-connections/"
chmod 0600 /etc/NetworkManager/system-connections/* #иначе они не подхватятся менеджером
nmcli connection reload

cp "/run/media/$USER/$USB_NAME/arch_installation/hhtestersCAnew.crt" "/tmp/"
trust anchor --store /tmp/hhtestersCAnew.crt
update-ca-trust

#локаль, время
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
timedatectl set-ntp true
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf 
