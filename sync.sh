#!/bin/bash
# Copies the curated set of live config/scripts into this repo, mirroring
# their path under $HOME (minus the leading dot: ~/.config/x -> config/x,
# ~/.local/bin -> local/bin). Run this, then commit/push - it does not
# commit or push itself, so a diff can always be reviewed first.
#
# Deliberately NOT a symlink-based (stow-style) setup: the live files under
# ~/.config and ~/.local/bin are what actually gets edited day to day, so
# this repo is a tracked mirror updated by this script, not the live copy.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO"

mirror() {
  local src="$HOME/$1"
  local dest="$REPO/$2"
  [[ -e "$src" ]] || return 0
  mkdir -p "$(dirname "$dest")"
  rsync -a --delete "$src" "$dest"
}

# hypr/: *.lua only - excludes *.bak.*, .luarc.json, hyprsunset.conf,
# xdph.conf (never approved for this repo).
mkdir -p "$REPO/config/hypr"
find "$REPO/config/hypr" -maxdepth 1 -type f -delete
for f in "$HOME"/.config/hypr/*.lua; do
  [[ -e "$f" ]] || continue
  cp "$f" "$REPO/config/hypr/$(basename "$f")"
done

# Only mrrobot.* plugins - those are the ones actually authored/customized
# here. Third-party plugins (omarchy plugin clone/install) have their own
# upstream repos already and can pull in megabytes of vendored source
# (compiled daemons, fonts, assets) that don't belong in a personal
# dotfiles repo - and some carry their own .git, which would corrupt this
# one if copied in.
mkdir -p "$REPO/config/omarchy/plugins"
find "$REPO/config/omarchy/plugins" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
for d in "$HOME"/.config/omarchy/plugins/mrrobot.*/; do
  [[ -e "$d" ]] || continue
  rsync -a --delete "$d" "$REPO/config/omarchy/plugins/$(basename "$d")/"
done

mirror ".config/omarchy/shell.json" "config/omarchy/shell.json"
mirror ".config/omarchy/extensions/omarchy-menu.jsonc" "config/omarchy/extensions/omarchy-menu.jsonc"
mirror ".config/omarchy/theme-picker-allowlist" "config/omarchy/theme-picker-allowlist"
mirror ".config/foot/foot.ini" "config/foot/foot.ini"
mirror ".config/cliamp/config.toml" "config/cliamp/config.toml"
mirror ".config/cliamp/playlists/" "config/cliamp/playlists/"

# rclone: the sync filter only. NEVER mirror the rclone directory - rclone.conf
# holds the Proton Drive account credentials and must not enter this repo.
mirror ".config/rclone/protondrive-filter.txt" "config/rclone/protondrive-filter.txt"

mkdir -p "$REPO/config/systemd/user"
for f in "$HOME"/.config/systemd/user/omarchy-* \
         "$HOME"/.config/systemd/user/protondrive-*; do
  [[ -e "$f" ]] || continue
  cp "$f" "$REPO/config/systemd/user/$(basename "$f")"
done

# local/bin/: only scripts actually authored/edited here - not npm/mise
# tool shims (claude, gh, opencode, ...) or compiled binaries (librepods)
# that happen to live on PATH in the same directory.
mkdir -p "$REPO/local/bin"
find "$REPO/local/bin" -maxdepth 1 -type f -delete
bin_scripts=(
  compress-video-19.5mb
  nautilus-trim-video-dialog
  omarchy-borders-toggle
  omarchy-favorites-pin-app
  omarchy-gaps-adjust
  omarchy-gaps-reset
  omarchy-launch-browser-personal
  omarchy-launch-slack
  omarchy-list-apps-for-pin
  omarchy-menu-keybindings-relabeled
  omarchy-rotate-windows
  omarchy-screenrecord-copy-last
  omarchy-screenrecord-latest
  omarchy-screenrecord-notify-oversized
  omarchy-screenrecord-open-last
  omarchy-screenrecord-organize
  omarchy-screenrecord-to-1080
  omarchy-screenshot-organize
  omarchy-theme-switcher-curated
  protondrive-sync
  protondrive-watch
  # system-backup.sh moved to /usr/local/sbin/omarchy-system-backup on
  # 2026-08-26: omarchy-backup.service runs it as root, and a root-executed
  # script must not sit in a user-writable directory. It is outside this
  # repo's $HOME-mirroring model now, along with its wrapper
  # /usr/local/sbin/omarchy-backup-run and /usr/local/bin/omarchy-backup-catchup.
  system-restore.sh
  video-to-1080
  ws5-music-layout
)
for f in "${bin_scripts[@]}"; do
  [[ -e "$HOME/.local/bin/$f" ]] || continue
  cp "$HOME/.local/bin/$f" "$REPO/local/bin/$f"
done

echo "Synced. Run: git -C \"$REPO\" status"
