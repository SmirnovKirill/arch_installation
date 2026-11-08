#!/usr/bin/env bash

set -euxo pipefail

ARCH_INSTALLATION_SCRIPT_DIRECTORY="$(cd "$(dirname "$0")" && pwd)"
source "$ARCH_INSTALLATION_SCRIPT_DIRECTORY/variables.sh"
source "$ARCH_INSTALLATION_SCRIPT_DIRECTORY/functions.sh"

function enable_services() {
  systemctl enable NetworkManager --now
  systemctl enable avahi-daemon --now
  systemctl enable bluetooth --now
  systemctl enable docker --now
  systemctl enable cups --now
  systemctl enable vpnagentd.service --now #для cisco anyconnect, написано в AUR что надо так сделать
  systemctl enable dnsmasq --now
  systemctl enable nftables --now
}

function handle_ssh_keys() {
  sudo -u "$USER" mkdir "/home/$USER/.ssh" -p
  sudo -u "$USER" cp "$ARCH_INSTALL_USB/ssh/"* "/home/$USER/.ssh/"
  sudo -u "$USER" chmod 700 "/home/$USER/.ssh/id_rsa"
}

function install_idea_reset() {
  sudo -u "$USER" cp "$ARCH_INSTALL_USB/software/reset_jb.sh" "/home/$USER/software/"
}

function handle_locale_and_time() {
  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
  timedatectl set-ntp true
  log_info "Ожидание синхронизации времени (до 120 секунд)"
  if ! timeout 120 bash -c 'until [[ "$(timedatectl show --property=NTPSynchronized --value)" == yes ]]; do sleep 1; done'; then
    log_error "Время не синхронизировано. Проверь подключение к интернету и работу NTP."
    return 1
  fi
  hwclock --systohc
  sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
  sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

function configure_network() {
  hostnamectl set-hostname archlinux #Чтобы anyconnect например не скидывал

  mkdir -p /etc/NetworkManager/conf.d

  tee /etc/NetworkManager/conf.d/dns-servers.conf >/dev/null <<'EOF'
[global-dns-domain-*]
servers=8.8.8.8,8.8.4.4
EOF

  systemctl reload NetworkManager
}

enable_services
handle_ssh_keys
install_idea_reset

sudo -u "$USER" cp "$ARCH_INSTALL_USB/maven/settings.xml" "/home/$USER/.m2/settings.xml"

cp "$ARCH_INSTALL_USB/amnezia_configs/"* "/tmp/"

configure_network

log_info "Нажми любую клавишу после того как подключишь вайфай"
read -n1 -s

handle_locale_and_time

sudo -u "$USER" git -C "/home/$USER/arch_installation" remote set-url origin "$REPOSITORY_ROOT_URL/arch_installation.git"
sudo -u "$USER" git clone "$REPOSITORY_ROOT_URL/obsidian_work.git" "/home/$USER/Obsidian Vault"
