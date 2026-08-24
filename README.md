# dotfiles

Curated mirror of the Omarchy/Hyprland config and scripts actually authored
or customized on this machine - not a full `~/.config` dump.

## What's here

- `config/hypr/` - Hyprland Lua config (keybinds, monitors, window rules, look'n'feel)
- `config/omarchy/plugins/mrrobot.*` - custom Quickshell bar plugins (audio mixer, cliamp indicator, menu, ProtonVPN toggle)
- `config/omarchy/shell.json`, `extensions/omarchy-menu.jsonc`, `theme-picker-allowlist` - bar layout and menu config
- `config/systemd/user/omarchy-*` - the systemd user units written here (screen-recording organizer, update reminder)
- `config/foot/foot.ini`, `config/cliamp/` - terminal and music player config
- `local/bin/` - the utility scripts behind keybinds/menu actions (not npm/tool shims that happen to live in the same PATH directory)

## What's deliberately NOT here

Third-party Omarchy plugins installed via `omarchy plugin clone/install`
(they have their own upstream repos), anything under `.cache`, browser
profiles, keyrings, session/socket/log files, or credentials of any kind.

## Updating

```sh
./sync.sh          # copies the live files in, mirroring their $HOME path
git status          # review the diff
git add -A && git commit -m "..." && git push
```
