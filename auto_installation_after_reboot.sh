#!/usr/bin/env bash

set -euxo pipefail

CURRENT_DIRECTORY="$(dirname "$0")"
source "$CURRENT_DIRECTORY/variables.sh"

function enable_services() {
  systemctl enable NetworkManager --now
  systemctl enable avahi-daemon --now
  systemctl enable bluetooth --now
  systemctl enable docker --now
  systemctl enable cups --now
  systemctl enable vpnagentd.service --now #для cisco anyconnect, написано в AUR что надо так сделать
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

function install_hh_test_cert() {
  wget https://crt.pyn.ru/hhtestersCA2025.crt -O /tmp/crt.crt
  trust anchor --store /tmp/crt.crt
  update-ca-trust
}

function install_work_related_repos() {
  sudo -u "$USER" pipx install 'git+ssh://git@forgejo.pyn.ru/hhru/hh-tilt.git@master'
  sudo -u "$USER" docker login registry.pyn.ru

  sudo -u "$USER" mkdir -p "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/hh.ru" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/negotiations" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/topic-auto-action" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/politeness" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/resume-views" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/hiring-plan" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/jlogic" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/logic" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/hhapi" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/resume-search" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/search-impl" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/search-api-hh" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/db-scheme" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/dbscripts" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/deploy" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/hr-tamagotchi" "/home/$USER/programming/work"
  sudo -u "$USER" git clone "git clone git@forgejo.pyn.ru:hhru/data-platform" "/home/$USER/programming/work"

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

hostnamectl set-hostname archlinux #Чтобы anyconnect например не скидывал

log_info "Нажми любую клавишу после того как подключишь вайфай"
read -n1 -s

install_hh_test_cert

sudo -u "$USER" git clone "$REPOSITORY_ROOT_URL/obsidian_work.git" "/home/$USER/Obsidian Vault"

log_info "Нажми любую клавишу после того как подключишь vpn"
read -n1 -s

install_work_related_repos
