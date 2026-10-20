local function bind(keys, description, command, options)
  hl.unbind(keys)
  o.bind(keys, description, command, options)
end

bind("SUPER + Q", "Close window", hl.dsp.window.close())
hl.unbind("SUPER + T")
bind("ALT + SPACE", "Vicinae", "vicinae toggle")

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
hl.unbind("SUPER + C")
hl.unbind("SUPER + V")
bind("SUPER + V", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")
bind("SUPER + T", "Telegram", { launch = "Telegram" })
bind("SUPER + ALT + T", "Toggle clock", "omarchy-shell esh.clock toggle")
bind("SUPER + F", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
bind("SUPER + SHIFT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind("SUPER + CTRL + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

bind("SUPER + Z", "Toggle Omanote", "omarchy-shell shell toggle b.omanote")

bind("SUPER + CTRL + G", "Toggle window grouping", hl.dsp.group.toggle())

bind("SUPER + period", "Emoji picker", "omarchy-menu-emoji")
bind("SUPER + CTRL + E", "Emoji picker", "omarchy-menu-emoji")

local function delete_to_boundary(boundary, delete_key)
  return function()
    hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL + SHIFT", key = boundary }))
    hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = delete_key }))
  end
end

bind("ALT + BACKSPACE", "Delete text to start", delete_to_boundary("HOME", "BACKSPACE"))
bind("ALT + DELETE", "Delete text to end", delete_to_boundary("END", "DELETE"))

bind(
  "SUPER + comma",
  "Clear all notifications permanently",
  "omarchy-shell esh.notification-center clear"
)
bind("SUPER + CTRL + S", "Toggle screensaver", "omarchy-toggle-screensaver")
bind("SUPER + CTRL + A", "Audio Plus", "omarchy-shell shell toggle rtome85.audio-plus")

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

bind("code:248", "AI", "uwsm app -- $TERMINAL -e codex --yolo")

bind("SUPER + E", "Yazi", "uwsm app -- $TERMINAL -e yazi")
bind("SUPER + SHIFT + E", "File manager", "uwsm app -- nautilus --new-window")
bind("SUPER + W", "Browser", "zen-browser")
bind("SUPER + SHIFT + W", "Private Browser", "zen-browser --private-window")
bind("SUPER + SHIFT + R", "Activity", "uwsm app -- $TERMINAL -e btop")
bind(
  "SUPER + O",
  "Obsidian",
  [[omarchy-launch-or-focus obsidian "obsidian"]]
)
bind("SUPER + D", "Discord", { launch = "discord" })
bind("SUPER + C", "Code editor", "zeditor")
bind("SUPER + N", "Neovim", "uwsm app -- $TERMINAL -e nvim")
bind("SUPER + SHIFT + S", "Music", "sonora")
bind("SUPER + S", "Spotify", "spotify")
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

bind("CTRL + ALT + TAB", "Herdr next tab", "herdr-tab-next")
bind("CTRL + ALT + SHIFT + TAB", "Herdr previous tab", "herdr-tab-prev")

bind("SUPER + SLASH", "Keybinds", "omarchy-keybindings-toggle")

bind("SUPER + grave", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
bind("SUPER + SHIFT + grave", "Move window to scratchpad",
  hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

o.bind("XF86Display", "Mission Control",
  "omarchy-shell shell toggle io.github.andyweiboan.missioncontrol '{}'")

-- Closing the lid should not lock, suspend, or change displays.
hl.unbind("switch:on:Lid Switch")

-- Caelestia-only overrides. Personal bindings come from
-- ESHAYAT102/dotfiles/config/hypr/bindings.lua and are loaded before this file.
local function caelestia_bind(keys, description, command, options)
  hl.unbind(keys)
  o.bind(keys, description, command, options)
end

local caelestia_repeat_locked = { locked = true, repeating = true }

caelestia_bind("SUPER + V", "Caelestia clipboard",
  "$HOME/.local/bin/caelestia-clipboard-toggle")
caelestia_bind("SUPER + CTRL + V", "Caelestia clipboard",
  "$HOME/.local/bin/caelestia-clipboard-toggle")
caelestia_bind("SUPER + period", "Caelestia emoji picker",
  "$HOME/.local/bin/caelestia-launcher-type '>emoji '")
caelestia_bind("SUPER + CTRL + E", "Caelestia emoji picker",
  "$HOME/.local/bin/caelestia-launcher-type '>emoji '")
caelestia_bind("SUPER + comma", "Clear all Caelestia notifications",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call notifs clear")
caelestia_bind("SUPER + CTRL + comma", "Toggle Caelestia Do Not Disturb",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call notifs toggleDnd")
caelestia_bind("SUPER + ESCAPE", "Caelestia power menu",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call drawers toggle session")
caelestia_bind("XF86PowerOff", "Caelestia power menu",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call drawers toggle session", { locked = true })
caelestia_bind("SUPER + CTRL + I", "Toggle Caelestia Keep Awake",
  "bash -lc '$HOME/.local/bin/caelestia-keep-awake-toggle'")
caelestia_bind("SUPER + CTRL + W", "Wi-Fi panel",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call drawers togglePanel network")
caelestia_bind("SUPER + CTRL + B", "Bluetooth panel",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call drawers togglePanel bluetooth")
caelestia_bind("SUPER + CTRL + A", "Audio panel",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call drawers togglePanel audio")
caelestia_bind("SUPER + ALT + W", "Caelestia weather",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call drawers openDashboardTab weather")
caelestia_bind("SUPER + CTRL + T", "Tailscale panel",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call drawers togglePanel tailscale")
caelestia_bind("SUPER + K", "Keybindings",
  "$HOME/.local/bin/caelestia-launcher-type '>keybindings '")
caelestia_bind("SUPER + SLASH", "Keybindings",
  "$HOME/.local/bin/caelestia-launcher-type '>keybindings '")
caelestia_bind("SUPER + L", "Lock screen",
  "$HOME/.config/omarchy/bridges/caelestia/caelestia-lock")
caelestia_bind("switch:on:Lid Switch", "Lock on lid close (Caelestia)",
  "bash -lc 'if omarchy-hw-laptop-closed && ! omarchy-hw-external-monitors; then $HOME/.config/omarchy/bridges/caelestia/caelestia-lock >/dev/null 2>&1; fi; omarchy-hyprland-monitor-clamshell'",
  { locked = true })
caelestia_bind("SUPER + CTRL + L", "Toggle workspace layout",
  "caelestia-workspace-layout-toggle")
caelestia_bind("SUPER + I", "Settings",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call nexus open")
caelestia_bind("SUPER + ALT + SPACE", "Confetti",
  "$HOME/.local/bin/caelestia-confetti fire")

caelestia_bind("ALT + XF86AudioRaiseVolume", nil,
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call audio raise", caelestia_repeat_locked)
caelestia_bind("ALT + XF86AudioLowerVolume", nil,
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call audio lower", caelestia_repeat_locked)
caelestia_bind("ALT + F6", nil,
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call audio lower", caelestia_repeat_locked)
caelestia_bind("ALT + F7", nil,
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call audio raise", caelestia_repeat_locked)
caelestia_bind("ALT + F3", nil,
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call brightness set 1%-", caelestia_repeat_locked)
caelestia_bind("ALT + F4", nil,
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call brightness set +1%", caelestia_repeat_locked)
caelestia_bind("SUPER + PAGE_UP", nil,
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call brightness set +5%", caelestia_repeat_locked)
caelestia_bind("SUPER + PAGE_DOWN", nil,
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call brightness set 5%-", caelestia_repeat_locked)
caelestia_bind("SUPER + ALT + PAGE_UP", nil,
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call brightness set +1%", caelestia_repeat_locked)
caelestia_bind("SUPER + ALT + PAGE_DOWN", nil,
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call brightness set 1%-", caelestia_repeat_locked)
caelestia_bind("SUPER + ALT + B", "Battery panel",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call drawers togglePanel battery")

for _, keys in ipairs({
  "XF86AudioNext", "XF86AudioPause", "XF86AudioPlay", "XF86AudioPrev",
  "XF86Eject", "SHIFT + XF86AudioMute", "SHIFT + XF86AudioPause",
  "SHIFT + XF86AudioPlay", "ALT + XF86AudioPlay", "ALT + SHIFT + XF86AudioPlay",
  "SUPER + CTRL + Delete", "SUPER + CTRL + ALT + Delete"
}) do
  hl.unbind(keys)
end
o.bind("XF86AudioNext", "Next track",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call mpris next", { locked = true })
o.bind("XF86AudioPause", "Pause",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call mpris playPause", { locked = true })
o.bind("XF86AudioPlay", "Play",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call mpris playPause", { locked = true })
o.bind("XF86AudioPrev", "Previous track",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call mpris previous", { locked = true })
caelestia_bind("XF86Display", "Caelestia dashboard",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call drawers openDashboardTab dashboard")

for _, keys in ipairs({
  "SUPER + SPACE", "SUPER + CTRL + SPACE", "SUPER + SHIFT + SPACE",
  "SUPER + SHIFT + CTRL + SPACE", "SUPER + CTRL + C", "SUPER + CTRL + O",
  "SUPER + CTRL + H", "SUPER + CTRL + D", "SUPER + CTRL + P",
  "SUPER + CTRL + R", "SUPER + CTRL + Z", "SUPER + CTRL + N",
  "SUPER + CTRL + PERIOD", "SUPER + SHIFT + CTRL + A",
  "SUPER + SHIFT + CTRL + R", "SUPER + CTRL + ALT + D",
  "SUPER + CTRL + ALT + E", "SUPER + CTRL + ALT + R",
  "SUPER + CTRL + ALT + T", "SUPER + CTRL + ALT + B",
  "SUPER + CTRL + ALT + W", "SUPER + CTRL + ALT + Z",
  "SUPER + SHIFT + BACKSPACE", "SUPER + CTRL + BACKSPACE",
  "SUPER + CTRL + ALT + F", "SUPER + ALT + K", "SUPER + CTRL + K",
  "SUPER + CTRL + Q", "XF86Calculator"
}) do
  hl.unbind(keys)
end
caelestia_bind("SUPER + BACKSPACE", "Toggle window transparency",
  "omarchy-hyprland-window-transparency-toggle")
o.bind("SUPER + SPACE", "Caelestia launcher",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call drawers toggle launcher")
o.bind("SUPER + CTRL + SPACE", "Wallpaper picker",
  "$HOME/.local/bin/caelestia-launcher-type '>wallpaper '")

for _, keys in ipairs({
  "XF86AudioRaiseVolume", "XF86AudioLowerVolume", "XF86AudioMute",
  "XF86AudioMicMute", "XF86MonBrightnessUp", "XF86MonBrightnessDown"
}) do
  hl.unbind(keys)
end
o.bind("XF86AudioRaiseVolume", "Volume up",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call audio raise", caelestia_repeat_locked)
o.bind("XF86AudioLowerVolume", "Volume down",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call audio lower", caelestia_repeat_locked)
o.bind("XF86AudioMute", "Mute",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call audio toggleMute", { locked = true })
o.bind("XF86AudioMicMute", "Mute microphone",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call audio toggleMicMute", { locked = true })
o.bind("XF86MonBrightnessUp", "Brightness up",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call brightness set +5%", caelestia_repeat_locked)
o.bind("XF86MonBrightnessDown", "Brightness down",
  "qs -p $HOME/.local/share/caelestia-shell/qs ipc call brightness set 5%-", caelestia_repeat_locked)
caelestia_bind("SUPER + A", "Sidebar", hl.dsp.global("caelestia:sidebar"))
caelestia_bind("SUPER + U", "Utilities", hl.dsp.global("caelestia:utilities"))
