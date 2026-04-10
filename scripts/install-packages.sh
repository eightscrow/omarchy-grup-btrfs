#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/lib/common.sh"

packages=(
  btrfs-progs
  snapper
  grub-btrfs
  inotify-tools
  btrfs-assistant
  snap-pac
  grub
  efibootmgr
)

log "Installing required packages"
run_sudo pacman -Syu --noconfirm --needed "${packages[@]}"

log "Package install step complete"
