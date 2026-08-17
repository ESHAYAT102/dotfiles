hl.env("XCURSOR_THEME", "MacTahoe")

hl.config({
  cursor = {
    no_hardware_cursors = false,
  },
})

hl.gesture({
  fingers = 3,
  direction = "left",
  action = function()
    hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
  end,
})
hl.gesture({
  fingers = 3,
  direction = "right",
  action = function()
    hl.dispatch(hl.dsp.focus({ workspace = "-1" }))
  end,
})

hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "swaync-control-center" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "^(vicinae)$" }, blur = true, ignore_alpha = 0.5 })

o.window(
  {
    title =
    "^(Library|File Upload|Open File|Save File|Select a Folder|Open Folder|Upload(.*)|Save As|Select File|Select Folder|Choose File|Sign in - Google Accounts — Zen Browser|Task Manager - Brave|Choose files to send with Taildrop).*$",
  },
  {
    float = true,
    size = { 700, 500 },
    center = true,
  }
)
o.window("xdg-desktop-portal-gtk", { float = true, size = { 800, 600 }, center = true })
o.window({ title = "^(walker).*$" }, { float = true, size = { 300, 300 }, center = true })
o.window({ title = "^(Waypaper).*$" }, { float = true, size = { 900, 600 }, center = true })
o.window("org.localsend.localsend_app", { float = true, size = { 450, 500 }, center = true })
o.window({ title = "^(Voice Recorder).*$" }, {
  pin = true,
  no_blur = true,
  no_shadow = true,
  border_size = 0,
  opacity = "1 1",
})
o.window({ class = "[Ss]crcpy" }, { float = true, pin = true, center = true })
o.window({ class = "omacalc" }, { float = true, size = { 350, 500 }, center = true })
o.window({ title = "^Nexus — .*$" }, { float = true, size = { 900, 560 }, center = true })
o.window({ title = "^OpenCode Screenshot.*$" }, { float = true, size = { 1000, 560 }, center = true })

-- Keep window opacity consistent across app-specific Omarchy rules.
o.window(".*", { opacity = "0.9 0.8" })

-- Inhibit idle while a browser, video player, or media app is open. Gecko's
-- native Wayland idle inhibitor is unreliable on Omarchy, so forced rules are
-- needed. "always" keeps the inhibitor active even when the window loses focus
-- (e.g. switching to another window while a video plays). Use SUPER+L to lock
-- manually when stepping away.
o.window({ tag = "firefox-based-browser" }, { idle_inhibit = "always" })
o.window("^(vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|Celluloid)$", { idle_inhibit = "always" })

-- Border colors are themed by the active Omarchy theme (see
-- omarchy.current.theme.hyprland) rather than the legacy desktop-shell scheme.
