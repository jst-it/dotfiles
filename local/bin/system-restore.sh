#!/usr/bin/env bash
# Restore btrfs subvolume(s) from a backup made by system-backup.sh.
# Run as root, from the normally-booted system:
#   sudo bash system-restore.sh /run/media/mrrobot/omarchy-backup/system-backup-<timestamp>
#
# How it works: renames the CURRENT (possibly broken) subvolume aside,
# receives the backup snapshot in its place, and renames it to match.
# Because /etc/fstab mounts by subvolume name (subvol=/@, /@home, ...),
# this takes effect on next mount — no fstab/bootloader changes needed.
# Restoring "/" itself requires a reboot to take effect (you're currently
# running from it). Other subvolumes get remounted live by this script.
#
# This assumes the system still boots. If the disk itself is dead/won't
# boot at all, do this from a live USB instead, using subvolume-list.txt
# from the backup to find the original names.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo/root." >&2
  exit 1
fi

BACKUP_DIR="${1:-}"
if [[ -z "$BACKUP_DIR" || ! -d "$BACKUP_DIR" ]]; then
  echo "Usage: sudo bash system-restore.sh /path/to/system-backup-<timestamp>" >&2
  echo
  echo "Available backups:"
  ls -d /run/media/mrrobot/omarchy-backup/system-backup-* 2>/dev/null || echo "  (drive not mounted?)"
  exit 1
fi
BACKUP_DIR="${BACKUP_DIR%/}"
BACKUP_DATE="${BACKUP_DIR##*system-backup-}"

echo "== Verifying backup integrity =="
(cd "$BACKUP_DIR" && sha256sum -c SHA256SUMS)

BTRFS_DEV="/dev/mapper/root"
TOPMNT=$(mktemp -d)
mount -o subvolid=5 "$BTRFS_DEV" "$TOPMNT"
trap 'umount "$TOPMNT" 2>/dev/null; rmdir "$TOPMNT" 2>/dev/null' EXIT

echo
echo "Backed-up subvolumes available in this backup:"
mapfile -t FILES < <(ls "$BACKUP_DIR"/*.btrfs.zst)
for i in "${!FILES[@]}"; do
  echo "  [$i] $(basename "${FILES[$i]}")"
done
echo "  [a] ALL of the above (full point-in-time rollback)"
read -rp "Restore which? [index/a]: " CHOICE

if [[ "$CHOICE" == "a" ]]; then
  TO_RESTORE=("${FILES[@]}")
else
  TO_RESTORE=("${FILES[$CHOICE]}")
fi

REBOOT_NEEDED=0

for FILE in "${TO_RESTORE[@]}"; do
  NAME=$(basename "$FILE" .btrfs.zst)
  case "$NAME" in
    root) MOUNTPOINT="/" ;;
    *) MOUNTPOINT="/$(echo "$NAME" | sed 's/-/\//g')" ;;
  esac

  if ! mountpoint -q "$MOUNTPOINT"; then
    echo "!! $MOUNTPOINT is not currently mounted, skipping $NAME — restore manually." >&2
    continue
  fi

  SUBVOL_REL=$(btrfs subvolume show "$MOUNTPOINT" | head -1 | sed 's#^/##')
  if [[ -z "$SUBVOL_REL" ]]; then
    echo "!! Could not determine subvolume for $MOUNTPOINT, skipping $NAME." >&2
    continue
  fi

  OLD="$TOPMNT/$SUBVOL_REL"
  BROKEN="${OLD}.broken-$(date +%Y%m%d-%H%M%S)"
  RECEIVED="$TOPMNT/.backup-snap-$BACKUP_DATE"

  echo
  echo "About to restore '$NAME' -> $MOUNTPOINT (subvolume '$SUBVOL_REL')"
  echo "Current data will be kept (renamed), not deleted, until you remove it yourself."
  read -rp "Confirm restore of $MOUNTPOINT from this backup? [y/N]: " CONFIRM
  [[ "$CONFIRM" == "y" ]] || { echo "Skipped $NAME."; continue; }

  mv "$OLD" "$BROKEN"
  zstd -dc "$FILE" | btrfs receive "$TOPMNT"

  if [[ ! -d "$RECEIVED" ]]; then
    echo "!! Expected received subvolume $RECEIVED not found — aborting this one, restoring old data." >&2
    mv "$BROKEN" "$OLD"
    continue
  fi

  mv "$RECEIVED" "$OLD"
  btrfs property set -f "$OLD" ro false

  echo "Restored $NAME."
  echo "  Old (pre-restore) data kept as subvolume: $(basename "$BROKEN")"
  echo "  Remove it later with:"
  echo "    sudo mount -o subvolid=5 $BTRFS_DEV /mnt && sudo btrfs subvolume delete \"/mnt/$(basename "$BROKEN")\" && sudo umount /mnt"

  if [[ "$MOUNTPOINT" == "/" ]]; then
    REBOOT_NEEDED=1
  else
    echo "  Remounting $MOUNTPOINT..."
    umount "$MOUNTPOINT" 2>/dev/null || echo "  ($MOUNTPOINT busy — remount manually or reboot)"
    mount "$MOUNTPOINT" 2>/dev/null || true
  fi
done

echo
if [[ "$REBOOT_NEEDED" == "1" ]]; then
  echo "Root ('/') was restored — reboot now for it to take effect."
else
  echo "Done."
fi
