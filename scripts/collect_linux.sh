#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_VERSION="2026-09-29.3"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROLE="${ROLE:-generic}"
PHASE="${PHASE:-snapshot}"
OUTPUT_BASE="${OUTPUT_BASE:-}"
OUTPUT_FILE="${OUTPUT_FILE:-}"

usage() {
  cat <<USAGE
Usage: collect_linux.sh [--role ROLE] [--phase PHASE] [--output-base DIR] [--output-file FILE]

Collects a read-only JSON system snapshot for Linux, Proxmox, VM, LXC,
media, and SteamOS hosts. Use --output-base /mnt/core/backups/snapshots
for homelab maintenance runs.
USAGE
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

json_array_or_empty() {
  local cmd="$1"
  local output=""
  if output="$(eval "$cmd" 2>/dev/null)"; then
    printf '%s' "${output:-[]}"
    return 0
  fi
  printf '[]'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --role)
      ROLE="${2:-}"
      shift 2
      ;;
    --phase)
      PHASE="${2:-}"
      shift 2
      ;;
    --output-base)
      OUTPUT_BASE="${2:-}"
      shift 2
      ;;
    --output-file)
      OUTPUT_FILE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

REQUIRED=(jq lscpu lsblk ip awk uname date)
for cmd in "${REQUIRED[@]}"; do
  if ! need_cmd "$cmd"; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

HOST="$(hostname -s 2>/dev/null || hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || uname -n 2>/dev/null || echo unknown)"
FQDN="$(hostname -f 2>/dev/null || hostname 2>/dev/null || echo "$HOST")"
RUN_DATE="$(date +%F)"
FILE_TS="$(date +%Y-%m-%d_%H-%M-%S)"
TIMESTAMP="$(date -Iseconds)"
ARCH="$(uname -m)"
KERNEL="$(uname -r)"

if [ -z "$OUTPUT_FILE" ]; then
  if [ -z "$OUTPUT_BASE" ]; then
    OUTPUT_BASE="$SCRIPT_DIR/output"
  fi
  OUTPUT_DIR="$OUTPUT_BASE/$RUN_DATE/$PHASE/$HOST"
  mkdir -p "$OUTPUT_DIR"
  OUTPUT_FILE="$OUTPUT_DIR/${HOST}_${PHASE}_${FILE_TS}.json"
else
  mkdir -p "$(dirname "$OUTPUT_FILE")"
fi

if [ -f /etc/os-release ]; then
  OS="$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
  OS_ID="$(grep '^ID=' /etc/os-release | cut -d= -f2- | tr -d '"')"
else
  OS="$(uname -s)"
  OS_ID="unknown"
fi

UPTIME="$(awk '{print int($1)}' /proc/uptime 2>/dev/null || echo 0)"
LOADAVG_JSON="$(awk '{printf "{\"1m\":%s,\"5m\":%s,\"15m\":%s}", $1,$2,$3}' /proc/loadavg 2>/dev/null || echo '{"1m":0,"5m":0,"15m":0}')"
CPU_JSON="$(lscpu -J 2>/dev/null || echo '{"lscpu":[]}')"
CPU_MODEL="$(jq -r '.lscpu[]? | select(.field=="Model name:") | .data' <<<"$CPU_JSON" 2>/dev/null | head -n1)"
THREADS="$(jq -r '.lscpu[]? | select(.field=="CPU(s):") | .data' <<<"$CPU_JSON" 2>/dev/null | head -n1)"
CORES="$(jq -r '(((.lscpu[]? | select(.field=="Core(s) per socket:") | .data) // "0" | tonumber) * ((.lscpu[]? | select(.field=="Socket(s):") | .data) // "1" | tonumber))' <<<"$CPU_JSON" 2>/dev/null || echo 0)"
RAM_GB="$(awk '/MemTotal:/ {printf "%.0f", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo 0)"

GPU_JSON="[]"
if need_cmd lspci; then
  GPU_JSON="$(lspci -nn 2>/dev/null | awk 'BEGIN{IGNORECASE=1} /vga|3d|display/ {sub(/^[^:]+: /, ""); gsub(/"/, "\\\""); print "{\"model\":\"" $0 "\"}"}' | jq -s '.')"
fi

STORAGE_JSON="$(lsblk -d -b -J -o NAME,SIZE,MODEL,TYPE,ROTA,TRAN 2>/dev/null | jq '[.blockdevices[]? | select(.type=="disk") | {name:.name, model:((.model // "") | if length==0 then "unknown" else . end), size_gb:(.size / 1073741824 | floor), type:(if .rota == true then "hdd" elif (.tran // "") == "nvme" then "nvme" else "ssd" end)}]')"
DF_OUTPUT="$(df -PT 2>&1 || true)"
DF_WARNINGS="$(printf '%s\n' "$DF_OUTPUT" | awk '/^df:/ {sub(/^df:[[:space:]]*/, ""); printf "%s%s", separator, $0; separator="; "}')"
FILESYSTEM_JSON="$(printf '%s\n' "$DF_OUTPUT" | awk '$1 != "Filesystem" && $1 !~ /^df:/ {printf "{\"filesystem\":\"%s\",\"type\":\"%s\",\"blocks\":%s,\"used\":%s,\"available\":%s,\"capacity\":\"%s\",\"mountpoint\":\"%s\"}\n", $1,$2,$3,$4,$5,$6,$7}' | jq -s '.')"
MNT_CORE_JSON="{}"
if need_cmd findmnt; then
  MNT_CORE_JSON="$(findmnt -J -T /mnt/core 2>/dev/null || echo '{}')"
fi

SMART_JSON="[]"
SMART_SKIPPED="smartctl unavailable or passwordless sudo unavailable"
if need_cmd smartctl && sudo -n true 2>/dev/null; then
  mapfile -t DISKS < <(lsblk -dno NAME,TYPE 2>/dev/null | awk '$2=="disk" && $1 !~ /^zram/ {print "/dev/"$1}')
  if [ "${#DISKS[@]}" -gt 0 ]; then
    SMART_JSON="$(for d in "${DISKS[@]}"; do sudo smartctl -a -j "$d" 2>/dev/null | jq --arg disk "$d" '. + {device: $disk}' || true; done | jq -s 'map(select(type=="object"))')"
    SMART_SKIPPED=""
  fi
fi

SENSORS_JSON="{}"
if need_cmd sensors; then
  SENSORS_OUTPUT=""
  if SENSORS_OUTPUT="$(sensors -j 2>/dev/null)" && jq -e . >/dev/null 2>&1 <<<"$SENSORS_OUTPUT"; then
    SENSORS_JSON="$SENSORS_OUTPUT"
  fi
fi

DMI_JSON="{}"
DMI_SKIPPED="dmidecode unavailable or passwordless sudo unavailable"
if need_cmd dmidecode && sudo -n true 2>/dev/null; then
  if DMI_JSON="$(sudo dmidecode -t system -t baseboard -t bios 2>/dev/null | jq -R -s '{raw: .}')"; then
    DMI_SKIPPED=""
  else
    DMI_JSON="{}"
    DMI_SKIPPED="dmidecode unavailable or blocked by container hardware restrictions"
  fi
fi

NETWORK_JSON="$(jq -n --argjson links "$(ip -j link 2>/dev/null || echo '[]')" --argjson addrs "$(ip -j addr 2>/dev/null || echo '[]')" '
  $links
  | map(select(.ifname != "lo"))
  | map(. as $link | {
      name: ($link.ifname // "unknown"),
      mac: ($link.address // "unknown"),
      state: (if (($link.operstate // "") | ascii_downcase) == "up" then "up" elif (($link.operstate // "") | ascii_downcase) == "down" then "down" else "unknown" end),
      type: ($link.link_type // "unknown"),
      addresses: ((($addrs | map(select(.ifname == $link.ifname)) | first | .addr_info) // []) | map(.local) | map(select(test("^[0-9]+\\."))) | map(select(startswith("127.") | not)) | unique)
    })
  | sort_by(.name)
')"

PCI_JSON="$(json_array_or_empty 'lspci -mm 2>/dev/null | jq -R "{raw: .}" | jq -s')"
USB_JSON="$(json_array_or_empty 'lsusb 2>/dev/null | jq -R "{raw: .}" | jq -s')"

DOCKER_PS_JSON="[]"
DOCKER_INFO_JSON="{}"
if need_cmd docker && docker info >/dev/null 2>&1; then
  DOCKER_PS_JSON="$(docker ps -a --format '{{json .}}' 2>/dev/null | jq -s '.')"
  DOCKER_INFO_JSON="$(docker info --format '{{json .}}' 2>/dev/null || echo '{}')"
fi

COMPOSE_FILES_JSON="[]"
if [ -d /mnt/core/services ]; then
  COMPOSE_FILES_JSON="$(find /mnt/core/services -maxdepth 5 \( -name docker-compose.yml -o -name compose.yml \) 2>/dev/null | sort | jq -R . | jq -s '.')"
fi

PKG_MANAGER="unknown"
PENDING_UPDATES_JSON="{}"
if need_cmd apt; then
  PKG_MANAGER="apt"
  PENDING_UPDATES_JSON="$(apt list --upgradable 2>/dev/null | awk 'NR>1' | jq -R . | jq -s '{items: ., count: length}')"
elif need_cmd dnf; then
  PKG_MANAGER="dnf"
  if DNF_OUTPUT="$(dnf check-update --quiet 2>&1)"; then
    DNF_STATUS=0
  else
    DNF_STATUS=$?
  fi
  if [ "$DNF_STATUS" -ne 0 ] && [ "$DNF_STATUS" -ne 100 ]; then
    printf '%s\n' "$DNF_OUTPUT" >&2
    echo "dnf check-update failed with exit code ${DNF_STATUS}." >&2
    exit "$DNF_STATUS"
  fi
  PENDING_UPDATES_JSON="$(printf '%s\n' "$DNF_OUTPUT" | awk 'NF>=3 {print}' | jq -R . | jq -s '{items: ., count: length}')"
elif need_cmd pacman; then
  PKG_MANAGER="pacman"
  if need_cmd checkupdates; then
    if CHECKUPDATES_OUTPUT="$(checkupdates 2>&1)"; then
      CHECKUPDATES_STATUS=0
    else
      CHECKUPDATES_STATUS=$?
    fi
    if [ "$CHECKUPDATES_STATUS" -eq 0 ]; then
      PENDING_UPDATES_JSON="$(printf '%s\n' "$CHECKUPDATES_OUTPUT" | jq -R . | jq -s '{items: ., count: length}')"
    elif [ "$CHECKUPDATES_STATUS" -eq 2 ]; then
      PENDING_UPDATES_JSON='{"items":[],"count":0}'
    else
      printf '%s\n' "$CHECKUPDATES_OUTPUT" >&2
      echo "checkupdates failed with exit code ${CHECKUPDATES_STATUS}." >&2
      exit "$CHECKUPDATES_STATUS"
    fi
  else
    PENDING_UPDATES_JSON='{"items":[],"count":0,"note":"checkupdates unavailable"}'
  fi
fi

for json_name in LOADAVG_JSON CPU_JSON GPU_JSON STORAGE_JSON FILESYSTEM_JSON MNT_CORE_JSON NETWORK_JSON SMART_JSON PCI_JSON USB_JSON DMI_JSON SENSORS_JSON DOCKER_PS_JSON DOCKER_INFO_JSON COMPOSE_FILES_JSON PENDING_UPDATES_JSON; do
  if ! jq -n --argjson check "${!json_name}" 'true' >/dev/null 2>&1; then
    echo "Invalid JSON collected for ${json_name}; refusing to write an incomplete snapshot." >&2
    exit 1
  fi
done
echo "Snapshot JSON fields validated." >&2

jq -n \
  --arg schema "fleet-linux-v1" \
  --arg script_version "$SCRIPT_VERSION" \
  --arg role "$ROLE" \
  --arg phase "$PHASE" \
  --arg host "$HOST" \
  --arg fqdn "$FQDN" \
  --arg os "$OS" \
  --arg os_id "$OS_ID" \
  --arg kernel "$KERNEL" \
  --arg timestamp "$TIMESTAMP" \
  --arg arch "$ARCH" \
  --arg cpu "${CPU_MODEL:-unknown}" \
  --arg cores "${CORES:-0}" \
  --arg threads "${THREADS:-0}" \
  --arg ram "${RAM_GB:-0}" \
  --arg uptime "${UPTIME:-0}" \
  --arg pkg_manager "$PKG_MANAGER" \
  --arg smart_skipped "$SMART_SKIPPED" \
  --arg dmi_skipped "$DMI_SKIPPED" \
  --arg df_warning "$DF_WARNINGS" \
  --argjson load "$LOADAVG_JSON" \
  --argjson gpu "$GPU_JSON" \
  --argjson storage "$STORAGE_JSON" \
  --argjson filesystems "$FILESYSTEM_JSON" \
  --argjson mnt_core "$MNT_CORE_JSON" \
  --argjson net "$NETWORK_JSON" \
  --argjson smart "$SMART_JSON" \
  --argjson pci "$PCI_JSON" \
  --argjson usb "$USB_JSON" \
  --argjson dmi "$DMI_JSON" \
  --argjson sensors "$SENSORS_JSON" \
  --argjson docker_ps "$DOCKER_PS_JSON" \
  --argjson docker_info "$DOCKER_INFO_JSON" \
  --argjson compose_files "$COMPOSE_FILES_JSON" \
  --argjson pending_updates "$PENDING_UPDATES_JSON" '
{
  meta: {
    schema: $schema,
    script_version: $script_version,
    role: $role,
    phase: $phase,
    hostname: $host,
    fqdn: $fqdn,
    os: $os,
    os_id: $os_id,
    kernel: $kernel,
    timestamp: $timestamp
  },
  hardware: {
    cpu: {model: $cpu, cores: ($cores | tonumber? // 0), threads: ($threads | tonumber? // 0), architecture: $arch},
    memory: {total_gb: ($ram | tonumber? // 0)},
    gpu: ($gpu // []),
    storage: ($storage // []),
    motherboard: ($dmi // {})
  },
  system: {
    uptime_seconds: ($uptime | tonumber? // 0),
    loadavg: $load,
    filesystems: ($filesystems // []),
    mnt_core: ($mnt_core // {}),
    package_manager: $pkg_manager,
    pending_updates: ($pending_updates // {})
  },
  docker: {
    info: ($docker_info // {}),
    containers: ($docker_ps // []),
    compose_files: ($compose_files // [])
  },
  peripherals: {pci: ($pci // []), usb: ($usb // [])},
  network: ($net // []),
  health: {
    smart: ($smart // []),
    sensors: ($sensors // {}),
    skipped: ([ $smart_skipped, $dmi_skipped, $df_warning ] | map(select(length > 0)))
  }
}
' > "$OUTPUT_FILE"

printf 'Saved: %s\n' "$OUTPUT_FILE"
