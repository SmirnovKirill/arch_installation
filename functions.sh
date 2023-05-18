#!/bin/sh

set -ex

function substitute_variables {
  sudo -u $USER sed -i "s/\$USER/$USER/g" $1
  sudo -u $USER sed -i "s/\$REPOSITORY_URL/${REPOSITORY_URL//\//\\\/}/g" $1
  sudo -u $USER sed -i "s/\$WINDOWS_INSTALLED/$WINDOWS_INSTALLED/g" $1
  sudo -u $USER sed -i "s/\$WINDOWS_GRUB_ENTRY_TITLE/$WINDOWS_GRUB_ENTRY_TITLE/g" $1
  sudo -u $USER sed -i "s/\$GIT_USER_EMAIL_WORK/$GIT_USER_EMAIL_WORK/g" $1
  sudo -u $USER sed -i "s/\$GIT_USER_EMAIL_HOME/$GIT_USER_EMAIL_HOME/g" $1
  sudo -u $USER sed -i "s/\$GIT_USER_NAME/$GIT_USER_NAME/g" $1
  sudo -u $USER sed -i "s/\$FONT_SIZE/$FONT_SIZE/g" $1
  sudo -u $USER sed -i "s/\$FONT_NAME/$FONT_NAME/g" $1
  sudo -u $USER sed -i "s/\$FONT_NAME_XTERM/$FONT_NAME_XTERM/g" $1
  sudo -u $USER sed -i "s/\$USB_NAME/$USB_NAME/g" $1
}

function install_from_aur {
  sudo -u $USER git clone $1 $2
  cd $2
  sudo -u $USER makepkg -si
  cd /home/$USER
}

