#!/bin/sh

set -ex

function config_sync {
  cp "$1/configs/.bashrc" "/home/$USER/.bashrc"
  cp "$1/configs/.xinitrc" "/home/$USER/.xinitrc"
  cp "$1/configs/.bash_history" "/home/$USER/.bash_history"

  cp "$1/configs/desktop-items-0.conf" "/home/$USER/.config/pcmanfm/default/desktop-items-0.conf"
  substitute_variables "/home/$USER/.config/pcmanfm/default/desktop-items-0.conf"

  cp /etc/xdg/openbox "/home/$USER/.config" -r
  cp "$1/configs/autostart" "/home/$USER/.config/openbox/autostart"
  cp "$1/configs/rc.xml" "/home/$USER/.config/openbox/rc.xml"
  substitute_variables "/home/$USER/.config/openbox/autostart"
  substitute_variables "/home/$USER/.config/openbox/rc.xml"

  cp "$1/configs/.Xresources" "/home/$USER/.Xresources"
  substitute_variables "/home/$USER/.Xresources"

  cp "$1/configs/.gtkrc-2.0" "/home/$USER/.gtkrc-2.0"
  substitute_variables "/home/$USER/.gtkrc-2.0"

  cp "$1/configs/libfm.conf" "/home/$USER/.config/libfm/libfm.conf"
  substitute_variables "/home/$USER/.config/libfm/libfm.conf"

  cp "$1/configs/panel" "/home/$USER/.config/lxpanel/default/panels/panel"
  substitute_variables "/home/$USER/.config/lxpanel/default/panels/panel"

  rm -f "/home/$USER/Desktop/"*.desktop
  cp "$1/configs/desktop/"* "/home/$USER/Desktop/"
  substitute_variables "/home/$USER/Desktop/idea.desktop"

  cp "$1/configs/.vimrc" "/home/$USER/.vimrc"
  substitute_variables "/home/$USER/.vimrc"

  cp "$1/configs/.xbindkeysrc" "/home/$USER/.xbindkeysrc"
}
