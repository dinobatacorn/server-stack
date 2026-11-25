#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROLE="generic"
PHASE="pre"
OUTPUT_BASE="$SCRIPT_DIR/output"

usage() {
  cat <<USAGE
Usage: collect_update_baseline.sh --role ROLE --phase pre|post [--output-base DIR]

Wraps collect_linux.sh with the fleet-update defaults used for homelab
maintenance. Run before and after updates on each reachable Linux host.
By default, snapshots are written under scripts/output/[date]/[phase].
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

exec bash "$SCRIPT_DIR/collect_linux.sh" \
  --role "$ROLE" \
  --phase "$PHASE" \
  --output-base "$OUTPUT_BASE"