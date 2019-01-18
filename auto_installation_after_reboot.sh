#!/bin/sh

set -ex

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/installation_variables.sh"

sudo -u $USER mkdir "/home/$USER/.ssh" -p
sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/ssh/id_rsa.pub" "/home/$USER/.ssh/"
sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/ssh/id_rsa" "/home/$USER/.ssh/"
sudo -u $USER chmod 700 "/home/$USER/.ssh/id_rsa"

sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/telegram" "/home/$USER/software/" -r
chmod +x "/home/$USER/software/telegram/Telegram"

sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/idea" "/home/$USER/software/" -r
chmod +x "/home/$USER/software/idea/bin/idea.sh"
substitute_variables "/home/$USER/software/idea/bin/idea.vmoptions"
substitute_variables "/home/$USER/software/idea/bin/idea64.vmoptions"

sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/tomcat" "/home/$USER/software/" -r
chmod +x "/home/$USER/software/tomcat/bin/startup.sh"
chmod +x "/home/$USER/software/tomcat/bin/catalina.sh"
chmod +x "/home/$USER/software/tomcat/bin/shutdown.sh"

sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/sqldeveloper" "/home/$USER/software/" -r
chmod +x "/home/$USER/software/sqldeveloper/sqldeveloper.sh"

sudo -u $USER mkdir "/home/$USER/network" -p
sudo -u $USER cp "/run/media/$USER/$USB_NAME/arch_installation/network/*.conf" "/home/$USER/netwok/" -r

#локаль, время
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
timedatectl set-ntp true
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf 
