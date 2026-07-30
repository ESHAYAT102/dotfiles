hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1.6,
  icc = os.getenv("HOME") .. "/.config/hypr/color/CMN141E.icc",
})
