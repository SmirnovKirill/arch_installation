#!/usr/bin/env bash

set -euxo pipefail

function config_sync {
  sudo -u "$USER" cp "$1/configs/.bashrc" "/home/$USER/.bashrc"
  sudo -u "$USER" cp "$1/configs/.xinitrc" "/home/$USER/.xinitrc"
  sudo -u "$USER" cp "$1/configs/.bash_history" "/home/$USER/.bash_history"

  sudo -u "$USER" cp "$1/configs/desktop-items-0.conf" "/home/$USER/.config/pcmanfm/default/desktop-items-0.conf"
  substitute_variables "/home/$USER/.config/pcmanfm/default/desktop-items-0.conf"

  sudo -u "$USER" cp /etc/xdg/openbox "/home/$USER/.config" -r
  sudo -u "$USER" cp "$1/configs/autostart" "/home/$USER/.config/openbox/autostart"
  sudo -u "$USER" cp "$1/configs/rc.xml" "/home/$USER/.config/openbox/rc.xml"
  substitute_variables "/home/$USER/.config/openbox/autostart"
  substitute_variables "/home/$USER/.config/openbox/rc.xml"

  sudo -u "$USER" cp "$1/configs/.Xresources" "/home/$USER/.Xresources"
  substitute_variables "/home/$USER/.Xresources"

  sudo -u "$USER" mkdir -p "/home/$USER/.config/gtk-3.0" "/home/$USER/.config/gtk-4.0"

  sudo -u "$USER" cp "$1/configs/gtk_settings.ini" "/home/$USER/config/gtk-3.0/settings.ini"
  substitute_variables "/home/$USER/config/gtk-3.0/settings.ini"

  sudo -u "$USER" cp "$1/configs/gtk_settings.ini" "/home/$USER/config/gtk-4.0/settings.ini"
  substitute_variables "/home/$USER/config/gtk-4.0/settings.ini"

  sudo -u "$USER" cp "$1/configs/libfm.conf" "/home/$USER/.config/libfm/libfm.conf"
  substitute_variables "/home/$USER/.config/libfm/libfm.conf"

  sudo -u "$USER" cp "$1/configs/panel" "/home/$USER/.config/lxpanel/default/panels/panel"
  substitute_variables "/home/$USER/.config/lxpanel/default/panels/panel"

  sudo -u "$USER" rm -f "/home/$USER/Desktop/"*.desktop
  sudo -u "$USER" cp "$1/configs/desktop/"* "/home/$USER/Desktop/"
  substitute_variables "/home/$USER/Desktop/idea.desktop"

  sudo -u "$USER" cp "$1/configs/.vimrc" "/home/$USER/.vimrc"
  substitute_variables "/home/$USER/.vimrc"

  sudo -u "$USER" cp "$1/configs/.xbindkeysrc" "/home/$USER/.xbindkeysrc"

  if [ "$EUID" -ne 0 ] && [ -z "${SUDO_USER-}" ]; then
    log_info "Запущено как обычный пользователь, можно делать dconf"
    dconf load / < "$1/configs/workrave.ini"
  else
    log_info "dconf пропускаем: скрипт под sudo или от root"
  fi
}
