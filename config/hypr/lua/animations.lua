-- Hyprlust's animations: everything uses a smooth "easeOut" curve at speed 6.9,
-- windows pop in/out, workspaces slide.

-- A preset picked with SUPER+SHIFT+A replaces these; choosing "Hyprlust (default)" there removes it.
local preset = HYPR .. "/lua/animation-preset.lua"
local pf = io.open(preset, "r")
if pf then
    pf:close()
    dofile(preset)
    return
end

hl.config({ animations = { enabled = true } })

hl.curve("hlDefault", { type = "bezier", points = { {0, 1},     {0, 1}   } })
hl.curve("wind",      { type = "bezier", points = { {0.05, 0.69}, {0.1, 1} } })
hl.curve("winIn",     { type = "bezier", points = { {0.1, 1.1}, {0.1, 1}   } })
hl.curve("winOut",    { type = "bezier", points = { {0.3, 1},   {0, 1}     } })
hl.curve("easeOut",   { type = "bezier", points = { {0.16, 1},  {0.3, 1}   } })

local speed, curve = 6.9, "easeOut"

hl.animation({ leaf = "windows",     enabled = true, speed = speed, bezier = curve, style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = speed, bezier = curve, style = "popin 90%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = speed, bezier = curve, style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = speed, bezier = curve, style = "slide" })
hl.animation({ leaf = "fade",        enabled = true, speed = 10,    bezier = "hlDefault" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 10,    bezier = curve, style = "slide" })
hl.animation({ leaf = "layers",      enabled = true, speed = speed, bezier = curve, style = "slide" })
