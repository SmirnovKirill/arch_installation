#!/usr/bin/env bash

function substitute_variables {
  local expressions=()

  # VARS_TO_SUBSTITUTE объявлен в variables.sh
  for var in "${VARS_TO_SUBSTITUTE[@]}"; do
    local value="${!var}"

    # Экранируем спецсимволы для sed: \, &, |
    value=${value//\\/\\\\}
    value=${value//&/\\&}
    value=${value//|/\\|}

    expressions+=(-e "s|\$$var|$value|g")
  done

  sudo -u "$USER" sed -i "${expressions[@]}" "$1"
}

color_green="\033[1;32m"
color_red="\033[1;31m"
color_blue="\033[1;34m"
color_reset="\033[0m"

function log_info()  { echo -e "${color_blue}[*]${color_reset} $*"; }
function log_ok()    { echo -e "${color_green}[OK]${color_reset} $*"; }
function log_error() { echo -e "${color_red}[ERR]${color_reset} $*"; }

function install_yay() {
  sudo -u "$USER" mkdir "/home/$USER/software/AUR" -p
  sudo -u $USER git clone https://aur.archlinux.org/yay.git "/home/$USER/software/AUR/yay"
  cd "/home/$USER/software/AUR/yay"
  sudo -u $USER makepkg -si
  cd /home/$USER
}
