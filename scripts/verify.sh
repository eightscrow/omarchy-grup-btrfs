#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/lib/common.sh"

need_cmd snapper

if ! select_grub_paths; then
  die "GRUB detection failed"
fi

has_snapper_config root || die "snapper root config missing"

if ! run_sudo grep -q 'grub-btrfs\.cfg' "$GRUB_CFG"; then
  die "grub-btrfs include not found in $GRUB_CFG"
fi

run_sudo systemctl is-enabled snapper-timeline.timer >/dev/null || die "snapper-timeline.timer is not enabled"
run_sudo systemctl is-enabled snapper-cleanup.timer >/dev/null || die "snapper-cleanup.timer is not enabled"

if systemctl list-unit-files 2>/dev/null | grep -q '^grub-btrfsd\.service'; then
  run_sudo systemctl is-enabled grub-btrfsd >/dev/null || die "grub-btrfsd is not enabled"
fi

log "Verification successful"
