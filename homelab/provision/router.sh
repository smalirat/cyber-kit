#!/usr/bin/env bash
# Router/firewall del homelab: forwarding, NAT de salida, política nftables y DNS (dnsmasq).
# Uso: router.sh corp=10.10.10.1 soc=10.10.20.1 dmz=10.10.30.1 attacker=10.10.99.1 siem=IP dc=IP domain=lab.local
# Idempotente: se puede re-ejecutar con `vagrant provision router`.
set -euo pipefail

declare -A NET_IP=()
SIEM_IP="" DC_IP="" DOMAIN="lab.local"
for arg in "$@"; do
  key="${arg%%=*}" val="${arg#*=}"
  case "$key" in
    siem)   SIEM_IP="$val" ;;
    dc)     DC_IP="$val" ;;
    domain) DOMAIN="$val" ;;
    *)      NET_IP[$key]="$val" ;;
  esac
done

iface_for_ip() { ip -o -4 addr show | awk -v ip="$1" '{split($4, a, "/"); if (a[1] == ip) print $2}'; }

declare -A NET_IF=()
for net in corp soc dmz attacker; do
  [[ -n "${NET_IP[$net]:-}" ]] || { echo "Falta la red '$net' en los argumentos" >&2; exit 1; }
  ifname="$(iface_for_ip "${NET_IP[$net]}")"
  [[ -n "$ifname" ]] || { echo "No hay interfaz con IP ${NET_IP[$net]} ($net)" >&2; exit 1; }
  NET_IF[$net]="$ifname"
done
WAN_IF="$(ip -o -4 addr show | awk '$4 ~ /^10\.0\.2\./ {print $2; exit}')"   # Adaptador NAT de VirtualBox
[[ -n "$WAN_IF" ]] || { echo "No encontré el adaptador NAT (10.0.2.x)" >&2; exit 1; }

echo "[router] WAN=$WAN_IF corp=${NET_IF[corp]} soc=${NET_IF[soc]} dmz=${NET_IF[dmz]} attacker=${NET_IF[attacker]}"

# --- Forwarding -------------------------------------------------------------
cat > /etc/sysctl.d/99-lab-router.conf <<EOF
net.ipv4.ip_forward = 1
EOF
sysctl -q --system

# --- DNS (dnsmasq) ----------------------------------------------------------
# Se escribe la config ANTES de instalar para que el servicio no choque con systemd-resolved en :53.
LISTEN="$(IFS=,; echo "${NET_IP[*]}")"
mkdir -p /etc/dnsmasq.d
cat > /etc/dnsmasq.d/lab.conf <<EOF
# Generado por provision/router.sh — no editar a mano.
bind-dynamic
listen-address=${LISTEN}
no-resolv
server=10.0.2.3
server=/${DOMAIN}/${DC_IP}
domain-needed
bogus-priv
cache-size=1000
# Las consultas quedan en el journal: telemetría para el SIEM (proyecto 0.3).
log-queries
EOF

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq nftables dnsmasq >/dev/null

# --- Firewall (nftables) ----------------------------------------------------
cat > /etc/nftables.conf <<EOF
#!/usr/sbin/nft -f
# Generado por provision/router.sh — la política documentada está en docs/red.md
flush ruleset

define WAN      = "${WAN_IF}"
define CORP     = "${NET_IF[corp]}"
define SOC      = "${NET_IF[soc]}"
define DMZ      = "${NET_IF[dmz]}"
define ATTACKER = "${NET_IF[attacker]}"
define SIEM     = ${SIEM_IP}

table inet filter {
  chain input {
    type filter hook input priority filter; policy drop;
    ct state established,related accept
    ct state invalid drop
    iif "lo" accept
    iifname \$WAN tcp dport 22 accept comment "SSH de Vagrant por el adaptador NAT"
    meta l4proto { icmp, ipv6-icmp } accept
    iifname { \$CORP, \$SOC, \$DMZ, \$ATTACKER } meta l4proto { tcp, udp } th dport 53 accept comment "DNS"
    iifname \$SOC tcp dport 22 accept comment "Administración desde el SOC"
    limit rate 10/second log prefix "LAB-IN-DROP " level info
  }

  chain forward {
    type filter hook forward priority filter; policy drop;
    ct state established,related accept
    ct state invalid drop
    iifname { \$CORP, \$SOC, \$DMZ, \$ATTACKER } oifname \$WAN accept comment "Salida a Internet"
    iifname \$SOC accept comment "El SOC alcanza todos los segmentos"
    oifname \$SOC ip daddr \$SIEM tcp dport { 1514, 1515 } accept comment "Agentes Wazuh hacia el SIEM"
    iifname \$ATTACKER oifname { \$DMZ, \$CORP } accept comment "Atacante hacia el alcance autorizado"
    iifname \$CORP oifname \$DMZ tcp dport { 80, 443, 3000, 8080 } accept comment "Usuarios hacia apps de la DMZ"
    limit rate 10/second log prefix "LAB-FWD-DROP " level info
  }

  chain output {
    type filter hook output priority filter; policy accept;
  }
}

table ip nat {
  chain postrouting {
    type nat hook postrouting priority srcnat; policy accept;
    oifname \$WAN masquerade
  }
}
EOF

nft -c -f /etc/nftables.conf          # Validar antes de aplicar
systemctl enable --now nftables >/dev/null
nft -f /etc/nftables.conf

systemctl enable dnsmasq >/dev/null
systemctl restart dnsmasq

echo "[router] OK — forwarding, NAT, firewall y DNS activos"
