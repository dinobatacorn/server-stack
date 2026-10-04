#!/usr/bin/env bash
set -Eeuo pipefail

MODE="preflight"
APPLY_SAFE_CLEANUP=0
SNAPSHOT_DATE="${SNAPSHOT_DATE:-$(date +%F)}"
REPORT_BASE="${REPORT_BASE:-/mnt/core/backups/snapshots/${SNAPSHOT_DATE}/pre/media}"
MIN_ROOT_FREE_GB="${MIN_ROOT_FREE_GB:-8}"
MAX_ROOT_USED_PCT="${MAX_ROOT_USED_PCT:-95}"
EXPECTED_HOST="${EXPECTED_HOST:-media}"
EXPECTED_MNT_CORE_SOURCE="${EXPECTED_MNT_CORE_SOURCE:-192.168.0.75:/mnt/core}"
EXPECTED_CONTAINERS=(jellyfin sonarr radarr qbittorrent prowlarr seerr)

usage() {
  cat <<'USAGE'
Usage:
  media_sudo_preflight.sh [--preflight] [--safe-cleanup] [--update-os-if-safe]

Modes:
  --preflight          Run sudo-backed checks and write reports. Default.
  --safe-cleanup       During an update run, clean apt cache and vacuum old journal logs.
  --update-os-if-safe  Run preflight, then apt update/upgrade only if gates pass.

Environment overrides:
  SNAPSHOT_DATE=YYYY-MM-DD
  REPORT_BASE=/mnt/core/backups/snapshots/YYYY-MM-DD/pre/media
  MIN_ROOT_FREE_GB=8
  MAX_ROOT_USED_PCT=95
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --preflight)
      MODE="preflight"
      ;;
    --safe-cleanup)
      APPLY_SAFE_CLEANUP=1
      ;;
    --update-os-if-safe)
      MODE="update-os-if-safe"
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
  shift
done

if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs sudo so it can inspect protected disk, package, and service state." >&2
  echo "Run it as: sudo bash $0 $*" >&2
  exit 2
fi

timestamp="$(date +%F_%H-%M-%S)"
mkdir -p "$REPORT_BASE"
LOG_FILE="${REPORT_BASE}/media_sudo_preflight_${timestamp}.log"
STATUS_FILE="${REPORT_BASE}/media_sudo_preflight_${timestamp}.status"
APT_SIM_FILE="${REPORT_BASE}/media_apt_upgrade_sim_${timestamp}.txt"
DOCKER_PS_FILE="${REPORT_BASE}/media_docker_ps_${timestamp}.txt"
DOCKER_INSPECT_FILE="${REPORT_BASE}/media_docker_inspect_${timestamp}.json"
DISK_USAGE_FILE="${REPORT_BASE}/media_disk_usage_${timestamp}.txt"
BACKUP_LIST_FILE="${REPORT_BASE}/media_backup_recent_files_${timestamp}.txt"
COMPOSE_BACKUP_FILE="${REPORT_BASE}/media_compose_config_${timestamp}.tar.gz"
COMPOSE_RENDERED_FILE="${REPORT_BASE}/media_compose_rendered_${timestamp}.yml"

exec > >(tee -a "$LOG_FILE") 2>&1

failures=()
warnings=()

pass() {
  printf 'PASS: %s\n' "$1"
}

warn() {
  warnings+=("$1")
  printf 'WARN: %s\n' "$1"
}

fail() {
  failures+=("$1")
  printf 'FAIL: %s\n' "$1"
}

run_section() {
  printf '\n## %s\n' "$1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

write_status() {
  {
    printf 'mode=%s\n' "$MODE"
    printf 'timestamp=%s\n' "$timestamp"
    printf 'report_base=%s\n' "$REPORT_BASE"
    printf 'failures=%s\n' "${#failures[@]}"
    printf 'warnings=%s\n' "${#warnings[@]}"
    if [ "${#failures[@]}" -eq 0 ]; then
      printf 'preflight=pass\n'
    else
      printf 'preflight=fail\n'
    fi
    if [ "${#failures[@]}" -gt 0 ]; then
      printf '\n[failure_list]\n'
      printf '%s\n' "${failures[@]}"
    fi
    if [ "${#warnings[@]}" -gt 0 ]; then
      printf '\n[warning_list]\n'
      printf '%s\n' "${warnings[@]}"
    fi
  } > "$STATUS_FILE"
}

check_identity() {
  run_section "Identity"
  local host_short
  host_short="$(hostname -s)"
  printf 'hostname=%s\n' "$host_short"
  printf 'kernel=%s\n' "$(uname -r)"
  printf 'os=%s\n' "$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
  printf 'running_as=%s\n' "$(id)"

  if [ "$host_short" = "$EXPECTED_HOST" ]; then
    pass "Host identity is ${EXPECTED_HOST}."
  else
    fail "Expected hostname ${EXPECTED_HOST}, got ${host_short}."
  fi
}

check_mounts() {
  run_section "Mount Proof"
  findmnt -T /mnt/core || true
  findmnt -T /media || true

  local core_source core_type media_source media_type
  core_source="$(findmnt -n -T /mnt/core -o SOURCE 2>/dev/null || true)"
  core_type="$(findmnt -n -T /mnt/core -o FSTYPE 2>/dev/null || true)"
  media_source="$(findmnt -n -T /media -o SOURCE 2>/dev/null || true)"
  media_type="$(findmnt -n -T /media -o FSTYPE 2>/dev/null || true)"

  if [ "$core_source" = "$EXPECTED_MNT_CORE_SOURCE" ] && [ "$core_type" = "nfs4" ]; then
    pass "/mnt/core is the expected NFS mount."
  else
    fail "/mnt/core is not the expected NFS mount. source=${core_source:-missing} type=${core_type:-missing}"
  fi

  if [ -n "$media_source" ] && [ "$media_source" != "overlay" ] && [ "$media_type" = "ext4" ]; then
    pass "/media is mounted as ext4 from ${media_source}."
  else
    fail "/media is not the expected mounted ext4 filesystem. source=${media_source:-missing} type=${media_type:-missing}"
  fi
}

check_disk() {
  run_section "Disk Space"
  df -h /
  df -h /mnt/core
  df -h /media

  local root_used root_available_bytes root_available_gb
  root_used="$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')"
  root_available_bytes="$(df -P -B1 / | awk 'NR==2 {print $4}')"
  root_available_gb="$(( root_available_bytes / 1024 / 1024 / 1024 ))"

  printf 'root_used_percent=%s\n' "$root_used"
  printf 'root_available_gb=%s\n' "$root_available_gb"
  printf 'min_root_free_gb=%s\n' "$MIN_ROOT_FREE_GB"
  printf 'max_root_used_percent=%s\n' "$MAX_ROOT_USED_PCT"

  if [ "$root_available_gb" -ge "$MIN_ROOT_FREE_GB" ] && [ "$root_used" -le "$MAX_ROOT_USED_PCT" ]; then
    pass "Root filesystem has enough free space for an OS package update."
  else
    fail "Root filesystem space gate failed: ${root_available_gb} GiB free, ${root_used}% used."
  fi

  {
    echo "# df"
    df -h
    echo
    echo "# Largest /var entries"
    du -xhd1 /var 2>/dev/null | sort -h | tail -30 || true
    echo
    echo "# Largest root entries"
    du -xhd1 / 2>/dev/null | sort -h | tail -30 || true
    echo
    echo "# Docker disk usage"
    docker system df 2>/dev/null || true
    echo
    echo "# Journal disk usage"
    journalctl --disk-usage 2>/dev/null || true
  } > "$DISK_USAGE_FILE"
  printf 'disk_usage_report=%s\n' "$DISK_USAGE_FILE"
}

check_services() {
  run_section "Service State"
  if systemctl is-active --quiet ssh; then
    pass "SSH service is active."
  else
    fail "SSH service is not active."
  fi

  if systemctl is-active --quiet docker; then
    pass "Docker service is active."
  else
    fail "Docker service is not active."
  fi

  docker ps --format 'table {{.Names}}\t{{.State}}\t{{.Status}}\t{{.Ports}}' | tee "$DOCKER_PS_FILE"
  docker inspect "${EXPECTED_CONTAINERS[@]}" > "$DOCKER_INSPECT_FILE" 2>/dev/null || true
  printf 'docker_ps_report=%s\n' "$DOCKER_PS_FILE"
  printf 'docker_inspect_report=%s\n' "$DOCKER_INSPECT_FILE"

  local name
  for name in "${EXPECTED_CONTAINERS[@]}"; do
    if docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null | grep -qx true; then
      pass "Container ${name} is running."
    else
      fail "Container ${name} is missing or not running."
    fi
  done
}

check_web_ports() {
  run_section "Media Web Ports"
  if ! command_exists curl; then
    warn "curl is unavailable; skipped web-port checks."
    return
  fi

  local checks=(
    "jellyfin http://127.0.0.1:8096 200,302"
    "sonarr http://127.0.0.1:8989 200,302"
    "radarr http://127.0.0.1:7878 200,302"
    "qbittorrent http://127.0.0.1:8080 200,302"
    "prowlarr http://127.0.0.1:9696 200,302"
    "seerr http://127.0.0.1:5055 200,302,307"
  )

  local item name url expected code
  for item in "${checks[@]}"; do
    name="$(awk '{print $1}' <<< "$item")"
    url="$(awk '{print $2}' <<< "$item")"
    expected="$(awk '{print $3}' <<< "$item")"
    code="$(curl -k -sS -o /dev/null -m 8 -w '%{http_code}' "$url" || true)"
    printf '%s %s -> %s\n' "$name" "$url" "$code"
    if grep -Eq "(^|,)${code}(,|$)" <<< "$expected"; then
      pass "${name} answered with HTTP ${code}."
    else
      fail "${name} returned HTTP ${code}; expected one of ${expected}."
    fi
  done
}

check_backups() {
  run_section "Backups And Config"
  if [ -d /mnt/core/services/media/compose ]; then
    tar -czf "$COMPOSE_BACKUP_FILE" -C /mnt/core/services/media compose
    pass "Media compose/config backup written to ${COMPOSE_BACKUP_FILE}."
  else
    fail "Expected media compose directory is missing: /mnt/core/services/media/compose"
  fi

  if command_exists docker && docker compose version >/dev/null 2>&1 && [ -f /mnt/core/services/media/compose/core/docker-compose.yml ]; then
    if docker compose -f /mnt/core/services/media/compose/core/docker-compose.yml config > "$COMPOSE_RENDERED_FILE"; then
      pass "Rendered media compose config written to ${COMPOSE_RENDERED_FILE}."
    else
      warn "Could not render media compose config; see ${COMPOSE_RENDERED_FILE} for partial output if present."
    fi
  else
    warn "Could not render media compose config; docker compose or compose file unavailable."
  fi

  {
    echo "# Recent backup-like files under /mnt/core/backups"
    find /mnt/core/backups -maxdepth 5 -type f -printf '%TY-%Tm-%Td %TH:%TM %s %p\n' 2>/dev/null | sort | tail -50 || true
  } > "$BACKUP_LIST_FILE"
  printf 'backup_recent_files_report=%s\n' "$BACKUP_LIST_FILE"
}

check_packages() {
  run_section "Package Simulation"
  if ! command_exists apt-get; then
    warn "apt-get unavailable; skipped apt simulation."
    return
  fi

  if apt-get -s upgrade > "$APT_SIM_FILE"; then
    pass "apt upgrade simulation completed."
    grep -E '^[0-9]+ upgraded,' "$APT_SIM_FILE" || true
  else
    fail "apt upgrade simulation failed. See ${APT_SIM_FILE}."
  fi
  printf 'apt_simulation_report=%s\n' "$APT_SIM_FILE"
}

apply_safe_cleanup() {
  run_section "Safe Cleanup"
  apt-get clean
  pass "Cleaned apt package cache."
  if command_exists journalctl; then
    journalctl --vacuum-time=14d || true
    pass "Vacuumed journal logs older than 14 days."
  fi
  warn "Docker images, volumes, and app data were not pruned."
}

update_os_if_safe() {
  run_section "OS Package Update"
  if [ "${#failures[@]}" -ne 0 ]; then
    echo "Refusing OS update because preflight failed."
    write_status
    exit 1
  fi

  if [ "$APPLY_SAFE_CLEANUP" -eq 1 ]; then
    apply_safe_cleanup
  fi

  apt-get update
  apt-get -s upgrade > "$APT_SIM_FILE"
  grep -E '^[0-9]+ upgraded,' "$APT_SIM_FILE" || true
  DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=--force-confold upgrade
  apt-get -s autoremove > "${REPORT_BASE}/media_apt_autoremove_sim_${timestamp}.txt" || true
  pass "OS package update completed."
}

post_update_checks() {
  run_section "Post-Update Checks"
  check_disk
  check_services
  check_web_ports
}

echo "MediaCenter sudo preflight"
echo "mode=${MODE}"
echo "timestamp=${timestamp}"
echo "report_base=${REPORT_BASE}"

check_identity
check_mounts
check_disk
check_services
check_web_ports
check_backups
check_packages
write_status

if [ "${#failures[@]}" -gt 0 ]; then
  echo
  echo "PREFLIGHT FAILED"
  printf '%s\n' "${failures[@]}"
  exit 1
fi

echo
echo "PREFLIGHT PASSED"

if [ "$MODE" = "update-os-if-safe" ]; then
  update_os_if_safe
  post_update_checks
  write_status
  echo
  echo "UPDATE COMPLETE"
fi
