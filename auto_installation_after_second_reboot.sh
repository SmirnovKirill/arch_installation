#!/bin/sh

set -ex

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/installation_variables.sh"

cp "$CURRENT_DIRECTORY/resources/desktop.jpg" "/usr/share/lxde/wallpapers/desktop.jpg"
cp "$CURRENT_DIRECTORY/configs/lxdm.conf" "/etc/lxdm/lxdm.conf"
sudo -u kirill cp "$CURRENT_DIRECTORY/configs/panel" "/home/$USER/.config/lxpanel/LXDE/panels/panel"
sudo -u kirill cp "$CURRENT_DIRECTORY/configs/desktop-items-0.conf" "/home/$USER/.config/lxpanel/LXDE/panels/desktop-items-0.conf"
sudo -u kirill cp "$CURRENT_DIRECTORY/configs/lxde-rc.xml" "/home/$USER/.config/openbox/lxde-rc.xml"
