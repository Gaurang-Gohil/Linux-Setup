-- Built-in screen: 1920x1200 at its highest refresh rate (144Hz).
-- scale 1 = everything at normal size. Try 1.25 if text feels too small.
hl.monitor({ output = "eDP-1", mode = "highrr", position = "auto", scale = 1 })

-- Any other monitor you plug in (HDMI etc.): best resolution, placed automatically
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
