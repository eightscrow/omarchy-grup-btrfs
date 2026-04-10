#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/lib/common.sh"

if [[ ! -f /etc/arch-release ]]; then
  die "This installer supports Arch Linux only."
fi

need_cmd sudo
need_cmd pacman
need_cmd findmnt
need_cmd awk
need_cmd grep

log "Starting full Arch GRUB+BTRFS+Snapper installer"

"$ROOT_DIR/scripts/install-packages.sh"
"$ROOT_DIR/scripts/setup-snapper.sh"
"$ROOT_DIR/scripts/setup-grub-btrfs.sh"
"$ROOT_DIR/scripts/verify.sh"

log "Regenerating GRUB config to include bootstrap snapshots"
if select_grub_paths; then
  run_sudo "$GRUB_MKCONFIG" -o "$GRUB_CFG" >/dev/null
fi

log "Installer completed successfully"
