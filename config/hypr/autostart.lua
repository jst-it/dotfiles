-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Silent login layout: Discord + X webapps on workspace 4, native Spotify
-- and CLIAMP on workspace 5. Workspace placement itself is handled by the
-- window rules in hypr/hyprland.lua ("... silent"); these just trigger the
-- launches. Delays give omarchy-launch-shell time to be up before we use
-- them.
--
-- Slack is intentionally NOT autostarted here -- launch it via the
-- SUPER+SHIFT+L keybind (hypr/bindings.lua) when you need it. It still
-- defaults to workspace 6 via the passive window rule in hyprland.lua.
--
-- The workspace-5 pair goes through ws5-music-layout rather than two
-- exec_on_start lines: dwindle gives the left slot to whichever window maps
-- first, and Spotify (Electron) maps far slower than CLIAMP (a terminal TUI),
-- so a staggered delay would reliably get the order backwards. The script
-- waits for Spotify's window before starting CLIAMP.
o.exec_on_start("sleep 3 && omarchy-launch-webapp https://discord.com/channels/@me")
o.exec_on_start("sleep 3 && omarchy-launch-webapp https://x.com/")
o.exec_on_start("sleep 5 && " .. os.getenv("HOME") .. "/.local/bin/ws5-music-layout")

-- Proton VPN's GUI and CLI cannot run at the same time (the CLI refuses to
-- act while the GUI process is alive), so it is NOT autostarted here — doing
-- so would permanently break the SUPER+SHIFT+V hotkey and menu toggle, which
-- are CLI-driven. Launch it manually from the Omarchy menu ("Proton VPN" >
-- "Open Proton VPN app") when you want its tray icon; quit it again to get
-- the hotkey/menu back.
