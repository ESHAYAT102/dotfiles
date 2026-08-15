-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

hl.env("OMARCHY_PATH", "/usr/share/omarchy")
dofile("/usr/share/omarchy/default/hypr/bootstrap.lua")
hl.permission({
  binary = "/usr/(bin|local/bin)/hyprpm",
  type = "plugin",
  mode = "allow",
})

-- Load Omarchy defaults (including stock keybindings), replacing only its
-- stock shell autostart with hypr/autostart.lua below.
require("default.hypr.helpers")
local require_optional = require("default.hypr.require_optional")

require("default.hypr.bindings.media")
require("default.hypr.bindings.clipboard")
require("default.hypr.bindings.tiling")
require("default.hypr.bindings.utilities")
require("default.hypr.bindings.voxtype")
require_optional.module("default.hypr.bindings.applications")

require("default.hypr.envs")
require("default.hypr.looknfeel")
require("default.hypr.input")
require("default.hypr.windows")
require_optional.module("omarchy.current.theme.hyprland")

require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("default.hypr.toggles")

-- HyprMod managed settings (loaded only if HyprMod's module is installed).
require_optional.module("hyprland-gui")
