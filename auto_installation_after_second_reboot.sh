#!/bin/sh

set -ex

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/installation_variables.sh"

sudo -u kirill cp "$CURRENT_DIRECTORY/configs/desktop-items-0.conf" "/home/$USER/.config/pcmanfm/default/desktop-items-0.conf"
