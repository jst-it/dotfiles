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
-- Both the workspace-4 and workspace-5 pairs go through wrapper scripts
-- rather than plain exec_on_start lines: dwindle gives the left slot to
-- whichever window maps first, so launch order has to be controlled
-- directly instead of tuned with delays (a staggered sleep is not reliable
-- once both apps are roughly the same weight/class). ws4-social-layout also
-- pins --profile-directory=Default on both webapp launches -- without it,
-- launching both at once races Chromium's single-profile-per-launch lock,
-- and the loser gets forwarded into the winner's process under whatever
-- profile was last active, breaking the "^...-Default$" window rules.
o.exec_on_start("sleep 3 && " .. os.getenv("HOME") .. "/.local/bin/ws4-social-layout")
o.exec_on_start("sleep 5 && " .. os.getenv("HOME") .. "/.local/bin/ws5-music-layout")

-- Proton VPN's GUI and CLI cannot run at the same time (the CLI refuses to
-- act while the GUI process is alive), so it is NOT autostarted here — doing
-- so would permanently break the jkoestinger.vpn bar widget, whose Proton
-- backend drives the `protonvpn` CLI. Launch the GUI manually when you want
-- its tray icon, and quit it again to get the widget working.
