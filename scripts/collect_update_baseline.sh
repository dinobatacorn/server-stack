#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROLE="generic"
PHASE="pre"
OUTPUT_BASE="/mnt/core/backups/snapshots"

usage() {
  cat <<USAGE
Usage: collect_update_baseline.sh --role ROLE --phase pre|post [--output-base DIR]

Wraps collect_linux.sh with the fleet-update defaults used for homelab
maintenance. Run before and after updates on each reachable Linux host.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --role) ROLE="${2:-}"; shift 2 ;;
    --phase) PHASE="${2:-}"; shift 2 ;;
    --output-base) OUTPUT_BASE="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

case "$PHASE" in
  pre|post|snapshot) ;;
  *) echo "Phase must be pre, post, or snapshot" >&2; exit 2 ;;
esac

if [ "$OUTPUT_BASE" = "/mnt/core/backups/snapshots" ]; then
  if command -v findmnt >/dev/null 2>&1; then
    if ! findmnt -T /mnt/core >/dev/null 2>&1; then
      echo "Refusing to write to /mnt/core because findmnt cannot verify it." >&2
      exit 1
    fi
  fi
fi

exec "$SCRIPT_DIR/collect_linux.sh" --role "$ROLE" --phase "$PHASE" --output-base "$OUTPUT_BASE"