#!/usr/bin/env bash
set -euo pipefail

# === Настраиваемые IP (поставь свои) ===
AMNEZIA_ENDPOINT="146.59.95.94"          # твой сервер амнезии (xray)
YANDEX_DNS_1="77.88.8.8"
YANDEX_DNS_2="77.88.8.1"
CORP_DNS_1="94.124.205.83"
CORP_DNS_2="94.124.204.83"

# === интерфейсы ===
cisco_dev=$(
  ip -o link show up | grep -oP '(?<=: )cscotun[0-9]+(?=:)' || true | head -n1
)

amnezia_dev=$(
  ip -o link show up | grep -oP '(?<=: )(?:tun|tap|wg)[0-9]+(?=:)' || true | head -n1
)

# === находим "обычный" дефолт (WAN), не через VPN интерфейсы ===
novpn_route=$(
  ip -4 route show default |
    grep -Ev ' dev (cscotun|tun|tap|wg)[0-9]*' |
    sed -E 's/^(.*[[:space:]]metric[[:space:]]+([0-9]+).*)$/\2\t\1/' |
    sort -n -k1,1 |
    head -n1 |
    cut -f2-
)

wan_dev=$(
  awk '{
    for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}
  }' <<<"$novpn_route"
)

# --- чистим таблицы (чтобы не было мусора от прошлых запусков) ---
ip -4 route flush table novpn 2>/dev/null || true
ip -4 route flush table corp  2>/dev/null || true
ip -4 route flush table amnezia 2>/dev/null || true

# -----------------------
# ШАГ 1/3: novpn (WAN)
# -----------------------
# default
ip -4 route replace $novpn_route table novpn

# добавляем link-route локальной сети (scope link) в novpn
# (иначе после сна/смены сети иногда вылезают "странности")
ip -4 route show dev "$wan_dev" scope link | awk '{print $1}' | while read -r dst; do
  [[ -n "$dst" ]] || continue
  ip -4 route replace "$dst" dev "$wan_dev" scope link table novpn
done

# rules: чистим
for p in 40 41 42 43 50 51 52 60 61 90 100 110 120 200; do
  ip rule del pref "$p" 2>/dev/null || true
done

# 1) endpoints всегда через novpn, чтобы VPN не строился поверх VPN
ip rule add pref 40 to "${AMNEZIA_ENDPOINT}/32" lookup novpn

# (опционально, но очень полезно) автоматически добавим все внешние IP vpnagentd в novpn
# чтобы AnyConnect не пытался жить через amnezia.
cisco_endpoints=$(
  ss -H -tupn | awk '/vpnagentd/ {print $6}' |
    sed -E 's/:[0-9]+$//' |
    grep -Ev '^(127\.|::1$|$)' |
    sort -u || true
)
pref=41
for ipaddr in $cisco_endpoints; do
  ip rule add pref "$pref" to "${ipaddr}/32" lookup novpn
  pref=$((pref+1))
done

# 2) DNS “без VPN” (если ты так хочешь)
ip rule add pref 50 to "${YANDEX_DNS_1}/32" lookup novpn
ip rule add pref 51 to "${YANDEX_DNS_2}/32" lookup novpn

# -----------------------
# ШАГ 2/3: corp (Cisco)
# -----------------------
if [[ -n "${cisco_dev:-}" ]]; then
  cisco_ip=$(ip -4 -o addr show dev "$cisco_dev" | awk '{print $4}' | cut -d/ -f1 | head -n1)

  # on-link маршруты cisco (если есть)
  ip -4 route show dev "$cisco_dev" scope link | awk '{print $1}' | while read -r dst; do
    [[ -n "$dst" ]] || continue
    ip -4 route replace "$dst" dev "$cisco_dev" scope link table corp
  done

  # дефолт + КРИТИЧНО: src
  ip -4 route replace default dev "$cisco_dev" src "$cisco_ip" table corp

  # корпоративный DNS (чтобы резолв гарантированно шёл в Cisco)
  ip rule add pref 60 to "${CORP_DNS_1}/32" lookup corp
  ip rule add pref 61 to "${CORP_DNS_2}/32" lookup corp

  # страховка: RFC1918 10/8 всегда в corp (очень полезно против “таймаутов”)
  ip rule add pref 90 to 10.0.0.0/8 lookup corp

  # fwmark -> corp
  ip rule add pref 100 fwmark 0x1 lookup corp
fi

# -----------------------
# ШАГ 3/3: amnezia
# -----------------------
if [[ -n "${amnezia_dev:-}" ]]; then
  am_ip=$(ip -4 -o addr show dev "$amnezia_dev" | awk '{print $4}' | cut -d/ -f1 | head -n1)

  # on-link маршруты tun2 (10.33.0.0/24 и т.п.)
  ip -4 route show dev "$amnezia_dev" scope link | awk '{print $1}' | while read -r dst; do
    [[ -n "$dst" ]] || continue
    ip -4 route replace "$dst" dev "$amnezia_dev" scope link table amnezia
  done

  # дефолт + src
  ip -4 route replace default dev "$amnezia_dev" src "$am_ip" table amnezia

  # fwmark -> novpn/amnezia
  ip rule add pref 110 fwmark 0x2 lookup novpn
  ip rule add pref 120 fwmark 0x3 lookup amnezia
fi