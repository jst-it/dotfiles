-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Hey (app.hey.com) not used -- disable the default Calendar/Email binds.
hl.unbind("SUPER + SHIFT + C")
hl.unbind("SUPER + SHIFT + E")
hl.unbind("SUPER + SHIFT + ALT + E")

-- Numpad workspace switching: mirrors SUPER + <number row> using physical
-- numpad key codes (code:N), so it works regardless of Num Lock state -
-- keysyms like KP_1 would otherwise change to KP_End etc. with Num Lock off.
o.bind("SUPER + code:87", "Switch to workspace 1 (numpad)", hl.dsp.focus({ workspace = "1" }))
o.bind("SUPER + code:88", "Switch to workspace 2 (numpad)", hl.dsp.focus({ workspace = "2" }))
o.bind("SUPER + code:89", "Switch to workspace 3 (numpad)", hl.dsp.focus({ workspace = "3" }))
o.bind("SUPER + code:83", "Switch to workspace 4 (numpad)", hl.dsp.focus({ workspace = "4" }))
o.bind("SUPER + code:84", "Switch to workspace 5 (numpad)", hl.dsp.focus({ workspace = "5" }))
o.bind("SUPER + code:85", "Switch to workspace 6 (numpad)", hl.dsp.focus({ workspace = "6" }))
o.bind("SUPER + code:79", "Switch to workspace 7 (numpad)", hl.dsp.focus({ workspace = "7" }))
o.bind("SUPER + code:80", "Switch to workspace 8 (numpad)", hl.dsp.focus({ workspace = "8" }))
o.bind("SUPER + code:81", "Switch to workspace 9 (numpad)", hl.dsp.focus({ workspace = "9" }))
o.bind("SUPER + code:90", "Switch to workspace 10 (numpad)", hl.dsp.focus({ workspace = "10" }))

-- Swap the ENTIRE half the focused window belongs to with the other half,
-- moving it (and everything on the other side, as a unit, preserving its
-- internal split) across - unlike SUPER+SHIFT+LEFT/RIGHT (directional
-- neighbor swap), which shrinks a half-screen window into a small sub-slot
-- when the other side has more than one window. Native dwindle "swapsplit"
-- has no direction param (it swaps whatever split the focused window
-- belongs to), so LEFT and RIGHT are functionally identical - both bound
-- for muscle memory either way.
o.bind("SUPER + SHIFT + CTRL + LEFT", "Swap window's half with the other side", hl.dsp.layout("swapsplit"))
o.bind("SUPER + SHIFT + CTRL + RIGHT", "Swap window's half with the other side", hl.dsp.layout("swapsplit"))

-- Make the focused window fill the entire half of the screen it's already
-- on (top/bottom or left/right), pushing its sibling out to split with
-- whatever's on the other side. Native dwindle dispatcher, verified live:
-- absorbs the sibling's space and relocates it to the other side; already
-- being solo in a half (or only 2 windows total) is a clean no-op.
o.bind("SUPER + M", "Maximize window in its half", hl.dsp.layout("movetoroot"))

-- Rotate all tiled windows on the active workspace one slot around the
-- stack (see ~/.local/bin/omarchy-rotate-windows). Works for any window
-- count/layout shape - degrades to a plain swap at 2 windows, no-ops at
-- 0/1.
o.bind("SUPER + BRACKETRIGHT", "Rotate windows forward", "omarchy-rotate-windows forward")
o.bind("SUPER + BRACKETLEFT", "Rotate windows reverse", "omarchy-rotate-windows reverse")

-- Keybindings menu (SUPER+K): use a wrapper that relabels numpad keysyms
-- (e.g. "KP_END" -> "NUM1") for display, without forking the package-owned
-- omarchy-menu-keybindings. See
-- ~/.local/bin/omarchy-menu-keybindings-relabeled.
hl.unbind("SUPER + K")
o.bind("SUPER + K", "Keybindings", "omarchy-menu-keybindings-relabeled")

-- Proton VPN: toggle connect/disconnect (fastest server)
o.bind("SUPER + SHIFT + V", "Toggle Proton VPN", "omarchy-protonvpn-toggle")

-- Chromium profiles
-- SUPER + SHIFT + RETURN is the default Omarchy "Browser" binding; override it
-- with a wrapper (~/.local/bin/omarchy-launch-browser-personal) that opens the
-- Personal profile when Chromium is the default browser, and otherwise falls
-- back to the normal default-browser launcher — so this stays correct even if
-- the system default browser changes later.
hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + SHIFT + RETURN", "Chromium (Personal)", "omarchy-launch-browser-personal")
o.bind("SUPER + SHIFT + U", "Chromium (School)", { launch = "chromium --profile-directory='Profile 2' --class=Chromium-School" })

-- Discord
o.bind("SUPER + D", "Discord", { launch = "omarchy-launch-webapp https://discord.com/channels/@me" })

-- Slack (capstone project) -- SUPER+S/SHIFT+S/ALT+S/CTRL+S are all already
-- taken by defaults (scratchpad, Google Maps, move-to-scratchpad, Share).
-- Uses ~/.local/bin/omarchy-launch-slack (not a plain launch-or-focus
-- webapp bind) so repeated presses focus the existing window instead of
-- spawning a new one. Workspace 6 is just the default landing spot (passive
-- window rule in hyprland.lua) -- this no longer force-pins the window there.
o.bind("SUPER + SHIFT + L", "Slack", { launch = "omarchy-launch-slack" })

-- TickTick (native AUR app, ~/usr/bin/ticktick, window class "TickTick")
o.bind("SUPER + SHIFT + T", "TickTick", { launch = "ticktick", focus = "^ticktick$" })

-- Screen recording quick-actions: act on whatever recording most recently
-- finished, since the save-toast can only left-click (open) or be dismissed
-- (right-click) - it has no room for extra mouse gestures.
--
-- Deliberately NOT on PRINT: that key already carries bare/SUPER/ALT/
-- SUPER+CTRL bindings, so stacking another modifier on top (e.g.
-- CTRL+ALT+PRINT) races the already-bound ALT+PRINT screenrecord toggle -
-- if PRINT registers before CTRL fully does, Hyprland fires ALT+PRINT
-- instead. F-keys have zero bindings at any modifier level, so there's no
-- shorter combo they can misfire into.
o.bind("SUPER + F9", "Open last recording in Nautilus", "omarchy-screenrecord-open-last")
o.bind("SUPER + F10", "Copy last recording to clipboard", "omarchy-screenrecord-copy-last")

-- Outer window gap size (gaps_in stays fixed at whatever looknfeel.lua
-- sets it to - only gaps_out moves). Live-adjust via hyprctl eval (not
-- persisted to disk - a Hyprland reload/restart falls back to
-- looknfeel.lua's default, gaps_out=10, which the reset binding also
-- restores). `repeating = true` so holding PAGE_UP/PAGE_DOWN keeps
-- adjusting instead of requiring repeated presses. See
-- ~/.local/bin/omarchy-gaps-adjust and ~/.local/bin/omarchy-gaps-reset.
o.bind("SUPER + PAGE_UP", "Decrease window gaps", "omarchy-gaps-adjust -1", { repeating = true })
o.bind("SUPER + PAGE_DOWN", "Increase window gaps", "omarchy-gaps-adjust +1", { repeating = true })
o.bind("SUPER + SHIFT + PAGE_DOWN", "Reset window gaps to default", "omarchy-gaps-reset")

-- Toggle window borders on/off. See ~/.local/bin/omarchy-borders-toggle.
o.bind("SUPER + F11", "Toggle window borders", "omarchy-borders-toggle")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
