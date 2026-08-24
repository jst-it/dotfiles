-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Silent login placement: assign these windows to a workspace without
-- switching to it or stealing focus, same pattern Omarchy itself uses to
-- hide screen-share popups (default/hypr/apps/browser.lua).
-- Spotify (Electron/Xwayland) asks to be activated on launch, and Omarchy runs
-- with misc:focus_on_activate = true, so "silent" alone still lets it yank focus
-- to workspace 5 at login. no_initial_focus does NOT stop this -- that only
-- covers focus at map time, not the later activation request -- so the rule that
-- actually keeps the login quiet is suppress_event = "activatefocus".
o.window({ class = "^Spotify$" }, { workspace = "5 silent", no_initial_focus = true, suppress_event = "activatefocus" })
o.window({ class = "^org\\.omarchy\\.cliamp$" }, { workspace = "5 silent" })
o.window({ class = "^chrome-discord\\.com__channels_@me-Default$" }, { workspace = "4 silent" })
o.window({ class = "^chrome-x\\.com__-Default$" }, { workspace = "4 silent" })
o.window({ class = "^chrome-app\\.slack\\.com__client-Default$" }, { workspace = "6 silent" })
