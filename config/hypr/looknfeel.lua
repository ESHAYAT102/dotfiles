hl.env("XCURSOR_THEME", "MacTahoe")

if hl.plugin.scrolloverview ~= nil then
	hl.config({
		plugin = {
			scrolloverview = {
				gesture_distance = 300,
				scale = 0.5,
				workspace_gap = 100,
				layout = "vertical",
				wallpaper = 0,
				blur = false,
				shadow = {
					enabled = false,
				},
			},
		},
	})
end

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
			size = 8,
			passes = 2,
			noise = 0.05,
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
hl.layer_rule({ match = { namespace = "swaync-control-center" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "^(vicinae)$" }, blur = true, ignore_alpha = 0.5 })

o.window(
	{
		title = "^(Library|File Upload|Open File|Save File|Select a Folder|Open Folder|Upload(.*)|Save As|Select File|Select Folder|Choose File|Sign in - Google Accounts — Zen Browser|Task Manager - Brave|Choose files to send with Taildrop).*$",
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
o.window("localsend", { size = { 400, 500 } })
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
o.window({ title = "^OpenCode Screenshot$" }, { float = true, size = { 1000, 700 }, center = true })

-- Keep window opacity consistent across app-specific Omarchy rules.
o.window(".*", { opacity = "0.9 0.8" })
