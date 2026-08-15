local active_border_color = "rgba(cba6f780)"
local inactive_border_color = "rgba(595959aa)"

hl.config({
  cursor = {
    no_hardware_cursors = false,
  },
  decoration = {
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
      noise = 0.05,
      new_optimizations = true,
    },
    rounding = 16,
    rounding_power = 6.0,
  },

  general = {
    gaps_in = 2,
    gaps_out = 4,
    border_size = 1,
    resize_on_border = true,
    extend_border_grab_area = 15,
    allow_tearing = false,
    hover_icon_on_border = false,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})

-- Translucent frosted windows so the blur behind them is visible.
o.window(".*", { opacity = "0.85 0.7" })

hl.curve("snappy", { type = "bezier", points = { { 0.25, 0.46 }, { 0.45, 0.94 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("slide", { type = "bezier", points = { { 0.165, 0.84 }, { 0.44, 1 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "overshot", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "snappy", style = "popin 85%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "snappy" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "smooth", style = "slidefade 20%" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "smooth", style = "popin 85%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "snappy", style = "popin 85%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "overshot", style = "slidefade 15%" })
