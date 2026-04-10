#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/lib/common.sh"

need_cmd snapper

if ! select_grub_paths; then
  die "Could not detect GRUB directory and mkconfig command."
fi

if [[ ! -x /etc/grub.d/41_snapshots-btrfs ]]; then
  die "grub-btrfs script missing at /etc/grub.d/41_snapshots-btrfs"
fi

config_file="/etc/default/grub-btrfs/config"
mkconfig_lib="/usr/share/grub/grub-mkconfig_lib"
if [[ ! -f "$mkconfig_lib" && -f "/usr/share/grub2/grub-mkconfig_lib" ]]; then
  mkconfig_lib="/usr/share/grub2/grub-mkconfig_lib"
fi

log "Writing grub-btrfs config"
write_kv_config "$config_file" "GRUB_BTRFS_GRUB_DIRNAME" "\"$GRUB_DIR\""
write_kv_config "$config_file" "GRUB_BTRFS_MKCONFIG" "/usr/bin/$GRUB_MKCONFIG"
write_kv_config "$config_file" "GRUB_BTRFS_SCRIPT_CHECK" "$GRUB_SCRIPT_CHECK"
write_kv_config "$config_file" "GRUB_BTRFS_MKCONFIG_LIB" "$mkconfig_lib"

root_snapshot_count=$(run_snapper -c root list 2>/dev/null | awk 'NR>2 && $1 ~ /^[1-9][0-9]*$/ {count++} END {print count+0}')
if (( root_snapshot_count == 0 )); then
  log "Creating bootstrap root snapshot"
  run_snapper -c root create --description "omarchy installer bootstrap snapshot" --cleanup-algorithm number
fi

if has_snapper_config home; then
  home_snapshot_count=$(run_snapper -c home list 2>/dev/null | awk 'NR>2 && $1 ~ /^[1-9][0-9]*$/ {count++} END {print count+0}')
  if (( home_snapshot_count == 0 )); then
    log "Creating bootstrap home snapshot"
    run_snapper -c home create --description "omarchy installer bootstrap snapshot" --cleanup-algorithm timeline
  fi
fi

log "Regenerating GRUB config at $GRUB_CFG"
run_sudo "$GRUB_MKCONFIG" -o "$GRUB_CFG" >/dev/null

if systemctl list-unit-files 2>/dev/null | grep -q '^grub-btrfsd\.service'; then
  log "Enabling grub-btrfsd service"
  run_sudo systemctl enable --now grub-btrfsd
else
  warn "grub-btrfsd.service not found; snapshot menu will update on next manual grub-mkconfig"
fi

log "GRUB BTRFS setup complete"
