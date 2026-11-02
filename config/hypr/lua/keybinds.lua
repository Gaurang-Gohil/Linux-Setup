-- Keyboard shortcuts. SUPER = the Windows key.  SUPER+H shows JaKooLit's cheat sheet.
-- Same shortcuts as JaKooLit's dots, plus Hyprlust's "tap SUPER alone = app launcher".

local function bind(keys, action, desc, opts)
    opts = opts or {}
    opts.description = desc
    hl.bind(keys, action, opts)
end
local function run(cmd) return hl.dsp.exec_cmd(cmd) end
local function notify(title, body)
    hl.exec_cmd(string.format("notify-send -e -u low %q %q", title, body))
end
local M = mainMod

----------------------------------------------------------------------- apps & menus
bind(M .. " + SUPER_L", run("pkill rofi || rofi -show drun -modi drun,filebrowser,run,window"), "app launcher (tap SUPER)", { release = true })
bind(M .. " + B",       run('xdg-open "https://"'),                       "open default browser")
bind(M .. " + Return",  run(term),                                       "terminal")
bind(M .. " + E",       run(files),                                      "file manager")
bind(M .. " + T",       run(scripts .. "/ThemeChanger.sh"),              "global theme switcher (wallust)")
bind(M .. " + H",       run(scripts .. "/KeyHints.sh"),                  "help / cheat sheet")
bind(M .. " + ALT + R", run(scripts .. "/Refresh.sh"),                   "refresh bar and menus")
bind(M .. " + period",  run(scripts .. "/RofiEmoji.sh"),                 "emoji menu")
bind(M .. " + CTRL + S", run("rofi -show window"),                       "window switcher")
bind(M .. " + V",       run(scripts .. "/ClipManager.sh"),               "clipboard history")
bind(M .. " + ALT + C", run(userScripts .. "/RofiCalc.sh"),              "calculator")
bind(M .. " + CTRL + R", run(scripts .. "/RofiThemePicker.sh"),          "rofi (menu) themes with preview")
bind(M .. " + SHIFT + K", run(scripts .. "/KeyBindsLive.sh"),            "search keybinds")
bind(M .. " + SHIFT + E", run(scripts .. "/Kool_Quick_Settings.sh"),     "quick settings menu")
bind(M .. " + SHIFT + A", run(scripts .. "/Animations.sh"),             "animation presets")
bind(M .. " + SHIFT + M", run(userScripts .. "/RofiBeats.sh"),           "online music")
bind(M .. " + N",         run("swaync-client -t -sw"),                   "notification panel")
bind(M .. " + A",       run(scripts .. "/OverviewToggle.sh"),            "desktop overview (needs quickshell)")

----------------------------------------------------------------------- wallpaper & bar
bind(M .. " + W",          run(userScripts .. "/WallpaperSelect.sh"),    "select wallpaper")
bind(M .. " + SHIFT + W",  run(userScripts .. "/WallpaperEffects.sh"),   "wallpaper effects")
bind("CTRL + ALT + W",     run(userScripts .. "/WallpaperRandom.sh"),    "random wallpaper")
bind(M .. " + CTRL + ALT + B", run("pkill -SIGUSR1 waybar"),             "show/hide waybar")
bind(M .. " + CTRL + B",   run(scripts .. "/WaybarStyles.sh"),           "waybar styles menu")
bind(M .. " + ALT + B",    run(scripts .. "/WaybarLayout.sh"),           "waybar layout menu")

----------------------------------------------------------------------- session
bind(M .. " + L",           run(scripts .. "/LockScreen.sh"),            "lock screen")
bind(M .. " + P",           run(scripts .. "/Wlogout.sh"),               "power menu")
bind("CTRL + ALT + Delete", hl.dsp.exit(),                               "exit Hyprland")

----------------------------------------------------------------------- windows
bind(M .. " + Q",           hl.dsp.window.close(),                       "close window")
bind(M .. " + SHIFT + Q",   run(scripts .. "/KillActiveProcess.sh"),     "kill active process")
bind(M .. " + F",           hl.dsp.window.fullscreen(),                  "fullscreen")
bind(M .. " + D",           hl.dsp.window.fullscreen({ mode = "maximized" }), "fake fullscreen (maximize, bar stays visible)")
bind(M .. " + SHIFT + I",   hl.dsp.layout("togglesplit"),                "toggle split (dwindle)")
bind(M .. " + CTRL + O",    hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }), "toggle window transparency")

bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end, "cycle windows")

-- master layout helpers
bind(M .. " + I",            hl.dsp.layout("addmaster"),      "add master")
bind(M .. " + CTRL + D",     hl.dsp.layout("removemaster"),   "remove master")
bind(M .. " + CTRL + Return", hl.dsp.layout("swapwithmaster"), "swap with master")

-- SUPER+J / SUPER+K: next / previous window (works in both layouts)
local function is_master() return hl.get_config("general:layout") == "master" end
bind(M .. " + J", function()
    if is_master() then hl.dispatch(hl.dsp.layout("cyclenext")) else hl.dispatch(hl.dsp.window.cycle_next()) end
end, "next window")
bind(M .. " + K", function()
    if is_master() then hl.dispatch(hl.dsp.layout("cycleprev")) else hl.dispatch(hl.dsp.window.cycle_next({ prev = true })) end
end, "previous window")

-- SUPER+ALT+L: switch master <-> dwindle layout
bind(M .. " + SHIFT + L", function()
    local new = is_master() and "dwindle" or "master"
    hl.config({ general = { layout = new } })
    notify("Layout", new)
end, "toggle master/dwindle layout")

-- focus / move / swap / resize with arrow keys
for _, d in ipairs({ "left", "right", "up", "down" }) do
    bind(M .. " + " .. d,          hl.dsp.focus({ direction = d }),       "focus " .. d)
    bind(M .. " + CTRL + " .. d,   hl.dsp.window.move({ direction = d }), "move window " .. d)
    bind(M .. " + ALT + " .. d,    hl.dsp.window.swap({ direction = d }), "swap window " .. d)
end
bind(M .. " + SHIFT + left",  hl.dsp.window.resize({ x = -50, y = 0,   relative = true }), "resize left",  { repeating = true })
bind(M .. " + SHIFT + right", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }), "resize right", { repeating = true })
bind(M .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), "resize up",    { repeating = true })
bind(M .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }), "resize down",  { repeating = true })

-- mouse: SUPER + left-drag moves, SUPER + right-drag resizes
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "move window" })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "resize window" })

-- groups (tabbed windows)
bind(M .. " + G",           hl.dsp.group.toggle(),                         "toggle group")
bind(M .. " + CTRL + Tab",  hl.dsp.group.next(),                           "next window in group")
bind(M .. " + CTRL + K",    hl.dsp.window.move({ into_group = "l" }),      "move into group (left)")
bind(M .. " + CTRL + L",    hl.dsp.window.move({ into_group = "r" }),      "move into group (right)")
bind(M .. " + CTRL + H",    hl.dsp.window.move({ out_of_group = true }),   "move out of group")

----------------------------------------------------------------------- workspaces
for i = 1, 10 do
    local key = "code:" .. (9 + i)   -- code:10 = key 1 ... code:19 = key 0 (works on any keyboard layout)
    bind(M .. " + " .. key,            hl.dsp.focus({ workspace = i }),                       "workspace " .. i)
    bind(M .. " + SHIFT + " .. key,    hl.dsp.window.move({ workspace = i }),                 "move to workspace " .. i)
    bind(M .. " + CTRL + " .. key,     hl.dsp.window.move({ workspace = i, follow = false }), "move silently to workspace " .. i)
end
bind(M .. " + Tab",                  hl.dsp.focus({ workspace = "m+1" }),   "next workspace")
bind(M .. " + SHIFT + Tab",          hl.dsp.focus({ workspace = "m-1" }),   "previous workspace")
bind(M .. " + comma",                hl.dsp.focus({ workspace = "e-1" }),   "previous workspace")
bind(M .. " + mouse_down",           hl.dsp.focus({ workspace = "e+1" }),   "next workspace")
bind(M .. " + mouse_up",             hl.dsp.focus({ workspace = "e-1" }),   "previous workspace")
bind(M .. " + SHIFT + bracketleft",  hl.dsp.window.move({ workspace = "-1" }), "move to previous workspace")
bind(M .. " + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1" }), "move to next workspace")
bind(M .. " + CTRL + bracketleft",   hl.dsp.window.move({ workspace = "-1", follow = false }), "move silently to previous workspace")
bind(M .. " + CTRL + bracketright",  hl.dsp.window.move({ workspace = "+1", follow = false }), "move silently to next workspace")
bind(M .. " + S",                    hl.dsp.workspace.toggle_special(),     "show/hide scratchpad")
bind(M .. " + SHIFT + U",            hl.dsp.window.move({ workspace = "special" }), "move window to scratchpad")
bind(M .. " + CTRL + F9",            hl.dsp.workspace.move({ monitor = "l" }), "move workspace to left monitor")
bind(M .. " + CTRL + F10",           hl.dsp.workspace.move({ monitor = "r" }), "move workspace to right monitor")
bind(M .. " + CTRL + F11",           hl.dsp.workspace.move({ monitor = "u" }), "move workspace to upper monitor")
bind(M .. " + CTRL + F12",           hl.dsp.workspace.move({ monitor = "d" }), "move workspace to lower monitor")

----------------------------------------------------------------------- dropdown terminal
-- SUPER+SHIFT+Return: a kitty that slides down from the top; press again to hide it.
-- (Replaces JaKooLit's Dropterminal.sh, which used commands removed in Hyprland 0.57.)
bind(M .. " + SHIFT + Return", function()
    if #hl.get_windows({ class = "kitty-dropterm" }) == 0 then
        hl.exec_cmd(term .. " --class kitty-dropterm")
    else
        hl.dispatch(hl.dsp.workspace.toggle_special("dropterm"))
    end
end, "dropdown terminal")

----------------------------------------------------------------------- toggles
-- SUPER+ALT+O: light / full blur
local light_blur = false
bind(M .. " + ALT + O", function()
    light_blur = not light_blur
    hl.config({ decoration = { blur = { size = light_blur and 2 or 6, passes = light_blur and 1 or 3 } } })
    notify("Blur", light_blur and "light" or "full")
end, "toggle blur strength")

-- SUPER+SHIFT+G: game mode (no animations, blur, gaps or transparency; wallpaper stopped)
local game_mode = false
local opaque_rule = hl.window_rule({
    name = "gamemode-opaque", enabled = false,
    match = { class = ".*" }, opacity = "1 override 1 override 1 override",
})
bind(M .. " + SHIFT + G", function()
    game_mode = not game_mode
    if game_mode then
        hl.config({
            animations = { enabled = false },
            decoration = { rounding = 0, shadow = { enabled = false }, blur = { enabled = false } },
            general    = { gaps_in = 0, gaps_out = 0, border_size = 1 },
        })
        opaque_rule:set_enabled(true)
        hl.exec_cmd("awww kill")
        notify("Game mode", "enabled")
    else
        hl.exec_cmd("awww-daemon")
        hl.dispatch(hl.dsp.reload_config())   -- restores every normal setting
        notify("Game mode", "disabled")
    end
end, "toggle game mode")

-- SUPER+ALT+scroll: zoom in / out
local function zoom(factor)
    local z = tonumber(hl.get_config("cursor:zoom_factor")) or 1
    z = math.max(1, math.max(1, z) * factor)
    hl.config({ cursor = { zoom_factor = z } })
end
bind(M .. " + ALT + mouse_down", function() zoom(2.0) end, "zoom in")
bind(M .. " + ALT + mouse_up",   function() zoom(0.5) end, "zoom out")

----------------------------------------------------------------------- screenshots
bind(M .. " + Print",               run(scripts .. "/ScreenShot.sh --now"),    "screenshot")
bind(M .. " + SHIFT + Print",       run(scripts .. "/ScreenShot.sh --area"),   "screenshot (area)")
bind(M .. " + CTRL + Print",        run(scripts .. "/ScreenShot.sh --in5"),    "screenshot in 5s")
bind(M .. " + CTRL + SHIFT + Print", run(scripts .. "/ScreenShot.sh --in10"),  "screenshot in 10s")
bind("ALT + Print",                 run(scripts .. "/ScreenShot.sh --active"), "screenshot active window")
bind(M .. " + SHIFT + S",           run(scripts .. "/ScreenShot.sh --swappy"), "screenshot and edit (swappy)")
-- laptop keyboards without a Print key
bind(M .. " + F6",          run(scripts .. "/ScreenShot.sh --now"),    "screenshot")
bind(M .. " + SHIFT + F6",  run(scripts .. "/ScreenShot.sh --area"),   "screenshot (area)")
bind(M .. " + CTRL + F6",   run(scripts .. "/ScreenShot.sh --in5"),    "screenshot in 5s")
bind(M .. " + ALT + F6",    run(scripts .. "/ScreenShot.sh --in10"),   "screenshot in 10s")
bind("ALT + F6",            run(scripts .. "/ScreenShot.sh --active"), "screenshot active window")

----------------------------------------------------------------------- media / laptop keys
local held   = { locked = true, repeating = true }   -- works on lock screen, repeats when held
local locked = { locked = true }
bind("XF86AudioRaiseVolume",        run(scripts .. "/Volume.sh --inc"),          "volume up",   held)
bind("XF86AudioLowerVolume",        run(scripts .. "/Volume.sh --dec"),          "volume down", held)
bind("ALT + XF86AudioRaiseVolume",  run(scripts .. "/Volume.sh --inc-precise"),  "volume up (fine)",   held)
bind("ALT + XF86AudioLowerVolume",  run(scripts .. "/Volume.sh --dec-precise"),  "volume down (fine)", held)
bind("XF86AudioMute",               run(scripts .. "/Volume.sh --toggle"),       "mute",          locked)
bind("XF86AudioMicMute",            run(scripts .. "/Volume.sh --toggle-mic"),   "mute mic",      locked)
bind("XF86AudioPause",              run(scripts .. "/MediaCtrl.sh --pause"),     "pause",         locked)
bind("XF86AudioPlay",               run(scripts .. "/MediaCtrl.sh --pause"),     "play",          locked)
bind("XF86AudioNext",               run(scripts .. "/MediaCtrl.sh --nxt"),       "next track",    locked)
bind("XF86AudioPrev",               run(scripts .. "/MediaCtrl.sh --prv"),       "previous track", locked)
bind("XF86AudioStop",               run(scripts .. "/MediaCtrl.sh --stop"),      "stop",          locked)
bind("XF86MonBrightnessUp",         run(scripts .. "/Brightness.sh --inc"),      "brightness up",   held)
bind("XF86MonBrightnessDown",       run(scripts .. "/Brightness.sh --dec"),      "brightness down", held)
bind("XF86KbdBrightnessUp",         run(scripts .. "/BrightnessKbd.sh --inc"),   "keyboard light up",   held)
bind("XF86KbdBrightnessDown",       run(scripts .. "/BrightnessKbd.sh --dec"),   "keyboard light down", held)
bind("XF86Sleep",                   run("systemctl suspend"),                    "sleep",         locked)
bind("XF86RFKill",                  run(scripts .. "/AirplaneMode.sh"),          "airplane mode", locked)

-- touchpad on/off key
local touchpad = "asue1213:00-04f3:3283-touchpad"
local touchpad_on = true
bind("XF86TouchpadToggle", function()
    touchpad_on = not touchpad_on
    hl.device({ name = touchpad, enabled = touchpad_on })
    notify("Touchpad", touchpad_on and "enabled" or "disabled")
end, "toggle touchpad")
