-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- GDK_SCALE intentionally left unset: our monitors use fractional scale
-- (1.5, 1.5, 1), and forcing an integer GDK_SCALE disables GTK's automatic
-- fractional-scale negotiation, causing blurry rendering in GTK apps
-- (e.g. LibreOffice) that don't have their own scale-correction logic.

-- Layout: DP-2 sits to the left of DP-1 (center/front monitor), HDMI-A-1 is
-- mounted above DP-1, centered above it.

-- DP-2 (ASUS VG289) -- left monitor
hl.monitor({ output = "DP-2", mode = "3840x2160@60", position = "0x1080", scale = 1.5 })

-- DP-1 (ASUS PG27UCDM) -- center/front monitor, primary
hl.monitor({ output = "DP-1", mode = "3840x2160@240", position = "2560x1080", scale = 1.5 })

-- HDMI-A-1 -- mounted above DP-1, horizontally centered above it
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@100", position = "2880x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Pin workspaces 1/2/3 to left/center/top monitors so SUPER+1/2/3 always
-- lands on a specific monitor, regardless of hardware detection order.
hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1", default = true, persistent = true })

-- Workspace 6 (Slack) always on the center/front monitor -- not `default`,
-- since DP-1's default workspace is already 2; just pins where 6 lives.
hl.workspace_rule({ workspace = "6", monitor = "DP-1", persistent = true })
