# Boot entry Snapshots for Asahi Alarm

Installs and configures snapper + grub-btrfs on Arch Linux so BTRFS snapshots show up as boot entries in GRUB 

## Requirements

- Asahi Alarm
- BTRFS root filesystem
- GRUB bootloader
- sudo access

## Install

```bash
git clone https://github.com/eightscrow/Asahi-Alarm-Snapshots.git && cd Asahi-Alarm-Snaphshots && bash install.sh
```

## What it does

1. Installs `snapper`, `grub-btrfs`, `btrfs-assistant`, `snap-pac`, `inotify-tools`
2. Creates snapper configs for `/` and `/home` (if `/home` is also BTRFS)
3. Applies retention policies — keeps hourly/daily/weekly/monthly snapshots, drops old ones automatically
4. Enables `snapper-timeline.timer` and `snapper-cleanup.timer`
5. Writes grub-btrfs config pointing at the correct GRUB directory
6. Creates a bootstrap snapshot if none exist, regenerates GRUB config
7. Enables `grub-btrfsd` so the snapshot submenu stays up to date without manual `grub-mkconfig`

After install, you'll see a snapshots submenu in GRUB on next boot.

## Uninstall

```bash
bash uninstall.sh
```

Removes all packages, snapper configs, BTRFS subvolumes, and regenerates a clean GRUB config.

## Verify

```bash
bash scripts/verify.sh
```
