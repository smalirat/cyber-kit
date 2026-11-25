#!/usr/bin/env bash
# Configura un host Linux del lab para que use el router como gateway y DNS.
# El adaptador NAT de Vagrant (10.0.2.x) queda sólo para gestión (vagrant ssh).
# Uso: linux-client.sh ip=10.10.30.10 gw=10.10.30.1 domain=lab.local
set -euo pipefail

IP="" GW="" DOMAIN="lab.local"
for arg in "$@"; do
  case "${arg%%=*}" in
    ip) IP="${arg#*=}" ;; gw) GW="${arg#*=}" ;; domain) DOMAIN="${arg#*=}" ;;
  esac
done
[[ -n "$IP" && -n "$GW" ]] || { echo "Uso: $0 ip=<ip> gw=<gateway> [domain=<dominio>]" >&2; exit 1; }

LAB_IF="$(ip -o -4 addr show | awk -v ip="$IP" '{split($4, a, "/"); if (a[1] == ip) print $2}')"
NAT_IF="$(ip -o -4 addr show | awk '$4 ~ /^10\.0\.2\./ {print $2; exit}')"
[[ -n "$LAB_IF" && -n "$NAT_IF" ]] || { echo "No pude detectar las interfaces (lab=$LAB_IF nat=$NAT_IF)" >&2; exit 1; }

# Unidad de systemd-networkd que netplan generó para cada interfaz
unit_for_if() { grep -lx "Name=$1" /run/systemd/network/*.network 2>/dev/null | head -n1; }
NAT_UNIT="$(unit_for_if "$NAT_IF")"
LAB_UNIT="$(unit_for_if "$LAB_IF")"
[[ -n "$NAT_UNIT" && -n "$LAB_UNIT" ]] || { echo "No encontré las unidades de networkd para $NAT_IF/$LAB_IF" >&2; exit 1; }

# --- Persistente: drop-ins de networkd (sobreviven reboot y renovación DHCP) ---
NAT_DROPIN="/etc/systemd/network/$(basename "$NAT_UNIT").d"
LAB_DROPIN="/etc/systemd/network/$(basename "$LAB_UNIT").d"
mkdir -p "$NAT_DROPIN" "$LAB_DROPIN"

cat > "$NAT_DROPIN/10-lab.conf" <<EOF
# Adaptador NAT de Vagrant: sin ruta por defecto ni DNS (sólo gestión)
[Network]
DNSDefaultRoute=false
[DHCPv4]
UseRoutes=false
UseDNS=false
EOF

cat > "$LAB_DROPIN/10-lab.conf" <<EOF
# Todo el tráfico sale por el router del lab
[Network]
Gateway=${GW}
DNS=${GW}
Domains=~. ${DOMAIN}
EOF

networkctl reload

# --- Inmediato: aplicar en caliente sin cortar la sesión SSH de Vagrant ---
ip route replace default via "$GW" dev "$LAB_IF"
ip route del default via 10.0.2.2 dev "$NAT_IF" 2>/dev/null || true
resolvectl dns "$LAB_IF" "$GW"
resolvectl domain "$LAB_IF" "~." "$DOMAIN"
resolvectl default-route "$NAT_IF" false
resolvectl dns "$NAT_IF" "" 2>/dev/null || true

# --- Utilidad de verificación usada por tests/Test-Network.ps1 ---
cat > /usr/local/bin/lab-check <<'EOF'
#!/usr/bin/env bash
# lab-check route            -> IP del gateway usado para salir a Internet
# lab-check dns  <nombre>    -> OK | FAIL
# lab-check http <url>       -> OK | FAIL
# lab-check tcp  <host> <p>  -> OPEN (acepta) | CLOSED (rechaza: el firewall lo dejó pasar) | FILTERED (timeout: bloqueado)
case "${1:-}" in
  route) ip route get 1.1.1.1 | awk '{for (i = 1; i <= NF; i++) if ($i == "via") {print $(i+1); exit}}' ;;
  dns)   getent ahostsv4 "$2" >/dev/null && echo OK || echo FAIL ;;
  http)  code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$2")"; [[ "$code" != "000" ]] && echo OK || echo FAIL ;;
  tcp)   timeout 3 bash -c "</dev/tcp/$2/$3" 2>/dev/null; rc=$?
         if   [[ $rc -eq 0   ]]; then echo OPEN
         elif [[ $rc -eq 124 ]]; then echo FILTERED
         else echo CLOSED; fi ;;
  *)     echo "uso: lab-check route|dns|http|tcp" >&2; exit 2 ;;
esac
EOF
chmod 755 /usr/local/bin/lab-check

echo "[linux-client] $(hostname): gateway $(lab-check route) por $LAB_IF, DNS $GW"
