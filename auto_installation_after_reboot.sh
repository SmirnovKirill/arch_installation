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
  sudo -u "$USER" chmod 700 "/home/$USER/.ssh/test-stand-key"
  sudo -u "$USER" chmod 700 "/home/$USER/.ssh/pkey.hh"
}

function install_idea() {
  sudo -u "$USER" cp "$ARCH_INSTALL_USB/software/idea" "/home/$USER/software/" -r
  sudo -u "$USER" cp "$ARCH_INSTALL_USB/software/reset_jb.sh" "/home/$USER/software/"
  chmod +x "/home/$USER/software/idea/bin/idea.sh"
}

function handle_locale_and_time() {
  ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
  timedatectl set-ntp true
  sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
  sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

function configure_network() {
  hostnamectl set-hostname archlinux #Чтобы anyconnect например не скидывал

  mkdir -p /etc/dnsmasq.d
  cp "$ARCH_INSTALLATION_SCRIPT_DIRECTORY/configs/network/dnsmasq-split.conf" /etc/dnsmasq.d/split.conf

  mkdir -p /etc/nftables.d
  echo 'destroy table inet vpnroute' | sudo tee /etc/nftables.d/00-vpnroute-reset.nft
  cp "$ARCH_INSTALLATION_SCRIPT_DIRECTORY/configs/network/vpnroute-mark.nft" /etc/nftables.d/10-vpnroute-mark.nft

  mkdir -p /etc/iproute2
  cp "$ARCH_INSTALLATION_SCRIPT_DIRECTORY/configs/network/rt_tables" /etc/iproute2/rt_tables

  cp "$ARCH_INSTALLATION_SCRIPT_DIRECTORY/configs/network/ip_rules.sh" /usr/local/sbin/ip_rules.sh
  chmod +x /usr/local/sbin/ip_rules.sh

  #todo include в /etc/nftables.conf
  #todo conf-dir в /etc/dnsmasq.conf

  mkdir -p /etc/NetworkManager/dispatcher.d
  cp "$ARCH_INSTALLATION_SCRIPT_DIRECTORY/configs/network/nm-dispatcher-ip-rules.sh" /etc/NetworkManager/dispatcher.d/90-ip-rules
  chmod +x /etc/NetworkManager/dispatcher.d/90-ip-rules

  systemctl reload dnsmasq
  systemctl restart nftables
  systemctl reload NetworkManager
}

function install_hh_test_cert() {
  wget https://crt.pyn.ru/hhtestersCA2025.crt -O /tmp/crt.crt
  trust anchor --store /tmp/crt.crt
  update-ca-trust
}

function install_work_related_repos() {
  sudo -u "$USER" pipx install 'git+ssh://git@forgejo.pyn.ru/hhru/hh-tilt.git@master'
  sudo -u "$USER" docker login registry.pyn.ru

  sudo -u "$USER" mkdir -p "/home/$USER/programming/work"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/hh.ru"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/negotiations"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/topic-auto-action"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/politeness"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/resume-views"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/hiring-plan"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/jlogic"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/logic"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/hhapi"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/resume-search"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/search-impl"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/search-api-hh"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/db-scheme"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/dbscripts"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/deploy"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/hr-tamagotchi"
  sudo -u "$USER" git -C "/home/$USER/programming/work" clone "git@forgejo.pyn.ru:hhru/data-platform"

  cd "/home/$USER/programming/work/logic"
  sudo -u "$USER" poetry install
  sudo -u "$USER" poetry run pytest

  cd "/home/$USER/programming/work/hhapi"
  sudo -u "$USER" poetry install
  sudo -u "$USER" poetry run pytest

  cd "/home/$USER/programming/work/negotiations"
  sudo -u "$USER" mvn clean install -Dmaven.compiler.showDeprecation

  cd "/home/$USER/"
}

enable_services
handle_ssh_keys
install_idea

sudo -u "$USER" cp "$ARCH_INSTALL_USB/maven/settings.xml" "/home/$USER/.m2/settings.xml"

cp "$ARCH_INSTALL_USB/amnezia_configs/"* "/tmp/"

handle_locale_and_time

cp "$ARCH_INSTALL_USB/network/"* "/etc/NetworkManager/system-connections/"
chmod 0600 /etc/NetworkManager/system-connections/* #иначе они не подхватятся менеджером
nmcli connection reload

configure_network

log_info "Нажми любую клавишу после того как подключишь вайфай"
read -n1 -s

sudo -u "$USER" git -C "/home/$USER/arch_installation" remote set-url origin "$REPOSITORY_ROOT_URL/arch_installation.git"
sudo -u "$USER" git clone "$REPOSITORY_ROOT_URL/obsidian_work.git" "/home/$USER/Obsidian Vault"

log_info "Нажми любую клавишу после того как подключишь vpn"
read -n1 -s

install_hh_test_cert
install_work_related_repos
