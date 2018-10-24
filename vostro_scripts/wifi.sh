#!/bin/sh

ip link set wlp2s0 up
killall wpa_supplicant
wpa_supplicant -B -i wlp2s0 -c /home/kirill/komtex1.conf
dhcpcd wlp2s0
