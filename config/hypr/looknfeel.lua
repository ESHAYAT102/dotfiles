hl.env("XCURSOR_THEME", "MacTahoe")

hl.config({
  cursor = {
    no_hardware_cursors = false,
  },

  general = {
    gaps_in = 2,
    gaps_out = 4,
    border_size = 1,
    resize_on_border = true,
    extend_border_grab_area = 15,
    allow_tearing = false,
    hover_icon_on_border = false,
  },

  decoration = {
    rounding = 16,
    rounding_power = 6.0,
    blur = {
      enabled = true,
      size = 5,
      passes = 2,
      noise = 0.02,
      new_optimizations = true,
    },
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
hl.layer_rule({
  match = { namespace = "^(omarchy-.*|omapager|esh-orbit|omadock)$" },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.55,
})

o.window(
  {
    title =
    "^(Library|File Upload|Open File|Save File|Select a Folder|Open Folder|Upload(.*)|Save As|Select File|Select Folder|Choose File|Choose an app icon|Sign in - Google Accounts — Zen Browser|Task Manager - Brave|Choose files to send with Taildrop).*$",
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

o.window(".*", { opacity = "0.9 0.8" })
