#!/bin/sh

set -ex

function config_sync {
  cp "$1/configs/.bashrc" "~/.bashrc"
  cp "$1/configs/.xinitrc" "~/.xinitrc"
  cp "$1/configs/.bash_history" "~/.bash_history"

  cp "$1/configs/desktop-items-0.conf" "~/.config/pcmanfm/default/desktop-items-0.conf"
  substitute_variables "~/.config/pcmanfm/default/desktop-items-0.conf"

  cp /etc/xdg/openbox "~/.config" -r
  cp "$1/configs/autostart" "~/.config/openbox/autostart"
  cp "$1/configs/rc.xml" "~/.config/openbox/rc.xml"
  substitute_variables "~/.config/openbox/autostart"
  substitute_variables "~/.config/openbox/rc.xml"

  cp "$1/configs/.Xresources" "~/.Xresources"
  substitute_variables "~/.Xresources"

  cp "$1/configs/.gtkrc-2.0" "~/.gtkrc-2.0"
  substitute_variables "~/.gtkrc-2.0"

  cp "$1/configs/libfm.conf" "~/.config/libfm/libfm.conf"
  substitute_variables "~/.config/libfm/libfm.conf"

  cp "$1/configs/panel" "~/.config/lxpanel/default/panels/panel"
  substitute_variables "~/.config/lxpanel/default/panels/panel"

  rm -f "~/Desktop/"*.desktop
  cp "$1/configs/desktop/"* "~/Desktop/"
  substitute_variables "~/Desktop/idea.desktop"

  cp "$1/configs/.vimrc" "~/.vimrc"
  substitute_variables "~/.vimrc"

  cp "$1/configs/.xbindkeysrc" "~/.xbindkeysrc"
}
