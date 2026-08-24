#!/usr/bin/env bash
# Full-system backup: LUKS header + /boot (EFI) + all mounted btrfs subvolumes.
# Run as root: sudo bash system-backup.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run this with sudo/root." >&2
  exit 1
fi

DATE=$(date +%Y%m%d-%H%M%S)
TARGET_MOUNT="/run/media/mrrobot/omarchy-backup"
BACKUP_ROOT="$TARGET_MOUNT/system-backup-$DATE"
LUKS_DEV="/dev/nvme1n1p2"

if [[ ! -d "$TARGET_MOUNT" ]]; then
  echo "Backup drive not found at $TARGET_MOUNT — plug it in and re-run." >&2
  exit 1
fi

mkdir -p "$BACKUP_ROOT"
echo "Backing up to: $BACKUP_ROOT"

echo "== 1/4: LUKS header backup =="
cryptsetup luksHeaderBackup "$LUKS_DEV" --header-backup-file "$BACKUP_ROOT/luks-header.img"

echo "== 2/4: /boot (EFI) archive =="
tar -czf "$BACKUP_ROOT/boot-efi.tar.gz" -C /boot .

echo "== 3/4: recording btrfs subvolume layout =="
btrfs subvolume list -o / | tee "$BACKUP_ROOT/subvolume-list.txt"

echo "== 4/4: snapshotting + sending each mounted btrfs subvolume =="
cleanup_snaps=()
trap 'for s in "${cleanup_snaps[@]:-}"; do [[ -n "$s" ]] && btrfs subvolume delete "$s" 2>/dev/null || true; done' EXIT

while read -r MP; do
  NAME=$(echo "$MP" | sed 's#^/##; s#/#-#g')
  [[ -z "$NAME" ]] && NAME="root"
  SNAP="$MP/.backup-snap-$DATE"

  echo "-- snapshotting $MP --"
  btrfs subvolume snapshot -r "$MP" "$SNAP"
  cleanup_snaps+=("$SNAP")

  echo "-- sending $MP -> $BACKUP_ROOT/${NAME}.btrfs.zst --"
  btrfs send "$SNAP" | zstd -T0 -q -o "$BACKUP_ROOT/${NAME}.btrfs.zst"

  btrfs subvolume delete "$SNAP"
  cleanup_snaps=("${cleanup_snaps[@]/$SNAP}")
done < <(findmnt -t btrfs -rno TARGET)

echo "== checksums =="
sha256sum "$BACKUP_ROOT"/* > "$BACKUP_ROOT/SHA256SUMS"

echo
echo "Backup complete: $BACKUP_ROOT"
echo "Contents:"
ls -lh "$BACKUP_ROOT"

echo
echo "== pruning old backups (keeping last 4) =="
mapfile -t OLD_BACKUPS < <(find "$TARGET_MOUNT" -maxdepth 1 -mindepth 1 -type d -name 'system-backup-*' | sort | head -n -4)
for old in "${OLD_BACKUPS[@]:-}"; do
  [[ -n "$old" && -d "$old" ]] || continue
  echo "removing old backup: $old"
  rm -rf "$old"
done
