-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

hl.env("OMARCHY_PATH", "/usr/share/omarchy")
dofile("/usr/share/omarchy/default/hypr/bootstrap.lua")
hl.permission({
  binary = "/usr/(bin|local/bin)/hyprpm",
  type = "plugin",
  mode = "allow",
})

-- Load Omarchy defaults, replacing only its stock shell autostart.
require("default.hypr.helpers")
local require_optional = require("default.hypr.require_optional")

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

-- HyprMod managed settings
require("hyprland-gui")
