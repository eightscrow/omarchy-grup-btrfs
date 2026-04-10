#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/common.sh"

if [[ ! -f /etc/arch-release ]]; then
  die "This only supports Arch Linux."
fi

log "Stopping and disabling timers"
run_sudo systemctl stop snapper-timeline.timer snapper-cleanup.timer grub-btrfsd 2>/dev/null || true
run_sudo systemctl disable snapper-timeline.timer snapper-cleanup.timer grub-btrfsd 2>/dev/null || true

if command -v snapper >/dev/null 2>&1; then
  log "Removing snapper configs"
  run_sudo snapper -c root delete-config 2>/dev/null || true
  run_sudo snapper -c home delete-config 2>/dev/null || true
fi

log "Removing .snapshots subvolumes"
for snap in $(run_sudo btrfs subvolume list / 2>/dev/null | awk '/snapshots.*snapshot$/ {print $NF}' | sort -r); do
  run_sudo btrfs subvolume delete "/$snap" 2>/dev/null || true
done
run_sudo btrfs subvolume delete /.snapshots 2>/dev/null || true
run_sudo btrfs subvolume delete /home/.snapshots 2>/dev/null || true

log "Removing packages"
run_sudo pacman -Rns --noconfirm snapper grub-btrfs btrfs-assistant snap-pac inotify-tools 2>/dev/null || true

log "Removing grub-btrfs config"
run_sudo rm -rf /etc/default/grub-btrfs

log "Regenerating GRUB config"
if select_grub_paths; then
  run_sudo "$GRUB_MKCONFIG" -o "$GRUB_CFG" 2>/dev/null
fi

log "Uninstall complete"
