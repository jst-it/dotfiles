-- Change the default Omarchy look'n'feel.

-- Put the cursor (and therefore initial focus/workspace) on the center
-- monitor at startup instead of whatever Hyprland picks by default.
hl.config({
  cursor = {
    default_monitor = "DP-1",
  },
})

-- Re-apply the outer window gap (gaps_out) from persisted state on every
-- config load - including `hyprctl reload` and Hyprland startup after a
-- reboot. This file loads after Omarchy's defaults (which set gaps_out=10
-- every time, e.g. on theme switch), so this always runs last and wins.
-- gaps_in intentionally stays untouched at the default. Written by
-- ~/.local/bin/omarchy-gaps-adjust; cleared by ~/.local/bin/omarchy-gaps-reset.
do
  local path = (os.getenv("HOME") or "") .. "/.local/state/omarchy/gaps-out"
  local f = io.open(path, "r")
  if f then
    local gaps_out = tonumber(f:read("*a"))
    f:close()
    if gaps_out then
      hl.config({ general = { gaps_out = gaps_out } })
    end
  end
end

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
