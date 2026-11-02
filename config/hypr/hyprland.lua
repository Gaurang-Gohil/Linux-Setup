-- ~/.config/hypr/hyprland.lua
-- JaKooLit's Hyprland-Dots + the Hyprlust look, converted to the Lua config format
-- that Hyprland 0.57+ requires (the old hyprland.conf format no longer loads).
--
-- The settings are split into files in ~/.config/hypr/lua/:
--   colors.lua      wallust colors (regenerated when you change wallpaper/theme)
--   env.lua         environment variables
--   monitors.lua    screen resolution / scale
--   settings.lua    look (gaps, borders, blur, rounding), input, misc behavior
--   animations.lua  animation curves (Hyprlust style)
--   autostart.lua   programs started at login (waybar, wallpaper, notifications...)
--   keybinds.lua    all keyboard shortcuts
--   rules.lua       window and layer rules (floating, opacity, blur...)
--   user.lua        YOUR own changes; loaded last, so it overrides everything above
--
-- Check for mistakes after editing:   Hyprland --verify-config
-- Apply changes:   hyprctl reload   (only hyprland.lua itself reloads automatically on save)

HOME        = os.getenv("HOME")
HYPR        = HOME .. "/.config/hypr"
scripts     = HYPR .. "/scripts"
userScripts = HYPR .. "/UserScripts"

mainMod = "SUPER"
term    = "kitty"
files   = "thunar"

-- dofile (not require) so `hyprctl reload` always re-reads every file
local function part(name)
    dofile(HYPR .. "/lua/" .. name .. ".lua")
end

part("colors")
part("env")
part("monitors")
part("settings")
part("animations")
part("autostart")
part("keybinds")
part("rules")
part("user")
