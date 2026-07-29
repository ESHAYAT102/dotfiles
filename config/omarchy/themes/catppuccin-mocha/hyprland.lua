local mauve = "#cba6f7"
local surface0 = "#313244"
local base = "#1e1e2e"

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 4,
    border_size = 1,
    col = {
      active_border = "rgba(cba6f766)",
      inactive_border = "rgba(11111b00)",
    },
    resize_on_border = true,
    extend_border_grab_area = 15,
    allow_tearing = false,
    hover_icon_on_border = false,
  },
  group = {
    col = {
      border_active = mauve,
    },
    groupbar = {
      col = {
        inactive = base,
        active = surface0,
      },
    },
  },
  decoration = {
    rounding = 16,
    rounding_power = 6.0,
    active_opacity = 0.9,
    inactive_opacity = 0.7,
    shadow = {
      enabled = true,
      range = 12,
      render_power = 3,
      color = "rgba(00000066)",
    },
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
      noise = 0.05,
      new_optimizations = true,
    },
  },
  misc = {
    background_color = base,
  },
})

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

hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({
  name = "blur-with-ignore-alpha",
  match = { namespace = "^(walker|notifications|swayosd|waybar/swaync)$" },
  blur = true,
  ignore_alpha = 0.1,
})
