#!/usr/bin/env bash

USER="kirill"
REPOSITORY_ROOT_URL="git@github.com:SmirnovKirill"
WINDOWS_INSTALLED="n"
WINDOWS_GRUB_ENTRY_TITLE="Microsoft Windows 10"
GIT_USER_EMAIL_WORK="k.smirnov@hh.ru"
GIT_USER_EMAIL_HOME="smirnov.kirill.vladimirovich@gmail.com"
GIT_USER_NAME="Kirill Smirnov"
FONT_SIZE=16
FONT_NAME="DejaVuSans"
FONT_NAME_XTERM="DejaVuSansMono" #Xterm нужен моноширинный шрифт
USB_NAME="ARCH_201901"
MODE="LAPTOP" #LAPTOP/DESKTOP
ARCH_INSTALL_USB="/run/media/$USER/$USB_NAME/arch_installation"
BACKUP_DEVICE_PATH="/run/media/${USER}/backupssd"
BACKUP_REPO="$BACKUP_DEVICE_PATH/borg_backup_home"

# Переменные, которые нужно подставлять в конфиги функцией substitute_variables
VARS_TO_SUBSTITUTE=(
  USER
  REPOSITORY_ROOT_URL
  WINDOWS_INSTALLED
  WINDOWS_GRUB_ENTRY_TITLE
  GIT_USER_EMAIL_WORK
  GIT_USER_EMAIL_HOME
  GIT_USER_NAME
  FONT_SIZE
  FONT_NAME
  FONT_NAME_XTERM
  USB_NAME
  MODE
  ARCH_INSTALL_USB
  BACKUP_DEVICE_PATH
  BACKUP_REPO
)