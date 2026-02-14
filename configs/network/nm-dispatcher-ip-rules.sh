#!/usr/bin/env bash

set -euo pipefail

case "${2-}" in
  up|down|vpn-up|vpn-down|dhcp4-change|dhcp6-change|connectivity-change)
    /usr/local/sbin/ip_rules.sh
    ;;
esac
