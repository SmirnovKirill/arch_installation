#!/bin/sh

set -ex

USER="kirill"
REPOSITORY_URL="https://github.com/SmirnovKirill/arch_installation.git"
WINDOWS_INSTALLED="y"
WINDOWS_GRUB_ENTRY_TITLE="Microsoft Windows 10"
GIT_USER_EMAIL="smirnov.kirill.vladimirovich@gmail.com"
GIT_USER_NAME="Kirill Smirnov"
FONT_SIZE=16
FONT_NAME="sans"

function substituteVariables() {
  sed -i "s/\$USER/$USER/g" $1
  sed -i "s/\$REPOSITORY_URL/$REPOSITORY_URL/g" $1
  sed -i "s/\$WINDOWS_INSTALLED/$WINDOWS_INSTALLED/g" $1
  sed -i "s/\$WINDOWS_GRUB_ENTRY_TITLE/$WINDOWS_GRUB_ENTRY_TITLE/g" $1
  sed -i "s/\$GIT_USER_EMAIL/$GIT_USER_EMAIL/g" $1
  sed -i "s/\$GIT_USER_NAME/$GIT_USER_NAME/g" $1
  sed -i "s/\$FONT_SIZE/$FONT_SIZE/g" $1
  sed -i "s/\$FONT_NAME/$FONT_NAME/g" $1
}
