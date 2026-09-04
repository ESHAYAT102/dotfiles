local function bind(keys, description, command, options)
  hl.unbind(keys)
  o.bind(keys, description, command, options)
end

bind("SUPER + Q", "Close window", hl.dsp.window.close())
hl.unbind("SUPER + T")

-- Disable stock Omarchy web app keybindings
hl.unbind("SUPER + SHIFT + A")
hl.unbind("SUPER + SHIFT + ALT + A")
hl.unbind("SUPER + SHIFT + C")
hl.unbind("SUPER + SHIFT + E")
hl.unbind("SUPER + SHIFT + ALT + E")
hl.unbind("SUPER + SHIFT + Y")
hl.unbind("SUPER + SHIFT + ALT + G")
hl.unbind("SUPER + SHIFT + CTRL + G")
hl.unbind("SUPER + SHIFT + P")
hl.unbind("SUPER + SHIFT + S")
hl.unbind("SUPER + SHIFT + X")
hl.unbind("SUPER + SHIFT + ALT + X")
bind("SUPER + T", "Telegram", { launch = "Telegram" })
bind("SUPER + ALT + T", "Toggle clock", "omarchy-shell esh.clock toggle")
bind("SUPER + F", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
bind("SUPER + SHIFT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind("SUPER + CTRL + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

bind("SUPER + Z", "Toggle Omanote", "omarchy-shell shell toggle b.omanote")

bind("SUPER + CTRL + G", "Toggle window grouping", hl.dsp.group.toggle())

bind("SUPER + period", "Emoji picker", "omarchy-menu-emoji")
bind("SUPER + CTRL + E", "Emoji picker", "omarchy-menu-emoji")
bind(
  "SUPER + comma",
  "Clear all notifications permanently",
  "omarchy-shell esh.notification-center clear"
)
bind("SUPER + CTRL + S", "Toggle screensaver", "omarchy-toggle-screensaver")

bind("CTRL + F1", "Apple Display brightness down", "omarchy-cmd-apple-display-brightness -5000")
bind("CTRL + F2", "Apple Display brightness up", "omarchy-cmd-apple-display-brightness +5000")
bind("SHIFT + CTRL + F2", "Apple Display full brightness", "omarchy-cmd-apple-display-brightness +60000")
bind("SUPER + PRINT", "Screenshot", "omarchy-capture-screenshot")
bind("PRINT", "Screenshot fullscreen", "omarchy capture screenshot fullscreen copy")
bind("SHIFT + PRINT", "Screenshot selector", "omarchy screenshot")
bind("CTRL + PRINT", "Color picking", "pkill hyprpicker || hyprpicker -a")
bind("ALT + PRINT", "Extract text", "omarchy-capture-text")

bind("SUPER + A", "Notification Center", "omarchy-shell esh.notification-center toggle")
bind("SUPER + ALT + W", "Open Weather", "omarchy-notification-weather")
bind("SUPER + CTRL + T", "Open Tailscale", "omarchy-shell shell toggle omarchy.tailscale")
bind("SUPER + XF86AudioMute", "Switch audio output", "omarchy-audio-output-switch", { locked = true })

bind("SUPER + K", "Toggle key bindings", "omarchy-keybindings-toggle")

bind("SUPER + L", "Lock screen", "omarchy-system-lock")
bind("SUPER + SHIFT + L", "Screensaver", "omarchy-launch-screensaver")
bind("SUPER + RETURN", "Terminal", [[uwsm app -- $TERMINAL --working-directory="$(omarchy-cmd-terminal-cwd)"]])

bind("code:248", "Agent", "omarchy-agent")

bind("SUPER + SHIFT + RETURN", "Alternative Terminal", "terax")
bind("SUPER + E", "Yazi", "uwsm app -- $TERMINAL -e yazi")
bind("SUPER + SHIFT + E", "File manager", "uwsm app -- nautilus --new-window")
bind("SUPER + W", "Browser", "zen-browser")
bind("SUPER + SHIFT + W", "Private Browser", "zen-browser --private-window")
bind("SUPER + R", "Activity", "uwsm app -- $TERMINAL -e btop")
bind("SUPER + SHIFT + R", "Mission Center", "flatpak run io.missioncenter.MissionCenter")
bind(
  "SUPER + O",
  "Obsidian",
  [[omarchy-launch-or-focus obsidian "uwsm app -- obsidian -disable-gpu --enable-wayland-ime"]]
)
bind("SUPER + D", "Discord", { launch = "discord" })
bind("SUPER + S", "Music", "spotify")
bind("SUPER + SHIFT + M", "kew", "uwsm app -- $TERMINAL -e kew")
bind("SUPER + ALT + M", "Cliamp", "uwsm app -- $TERMINAL -e cliamp")
bind("SUPER + ALT + S", "Share", "localsend")
bind("SUPER + I", "Settings", "omarchy-menu toggle setup")
bind("SUPER + ALT + SPACE", "Confetti", "omarchy-shell esh.confetti fire")
bind("SUPER + X", "Dictation", "voxtype record toggle")

local repeat_locked = { locked = true, repeating = true }
bind("ALT + XF86AudioRaiseVolume", nil, "omarchy-audio-output-volume raise", repeat_locked)
bind("ALT + XF86AudioLowerVolume", nil, "omarchy-audio-output-volume lower", repeat_locked)
-- This HP keyboard reports Alt + volume keys as Alt + F6/F7.
bind("ALT + F6", nil, "omarchy-audio-output-volume lower", repeat_locked)
bind("ALT + F7", nil, "omarchy-audio-output-volume raise", repeat_locked)
-- This HP keyboard reports Alt + brightness keys as Alt + F3/F4.
bind("ALT + F3", nil, "omarchy-brightness-display 1%-", repeat_locked)
bind("ALT + F4", nil, "omarchy-brightness-display +1%", repeat_locked)
bind("SUPER + PAGE_UP", nil, "omarchy-brightness-display +5%", repeat_locked)
bind("SUPER + PAGE_DOWN", nil, "omarchy-brightness-display 5%-", repeat_locked)
bind("SUPER + ALT + PAGE_UP", nil, "omarchy-brightness-display +1%", repeat_locked)
bind("SUPER + ALT + PAGE_DOWN", nil, "omarchy-brightness-display 1%-", repeat_locked)

bind(
  "SUPER + ALT + B",
  "Open Battery",
  "omarchy-shell shell toggle omarchy.power"
)

-- Herdr tab switching
bind("CTRL + ALT + TAB", "Herdr next tab", "herdr-tab-next")
bind("CTRL + ALT + SHIFT + TAB", "Herdr previous tab", "herdr-tab-prev")

bind("SUPER + SLASH", "Settings", "omarchy-menu toggle setup")
