-- Window rules: which apps float, how transparent they are, etc.
-- Step 1 gives apps a tag by class/title; step 2 applies settings per tag.

local function rule(match, effects)
    effects.match = match
    hl.window_rule(effects)
end

----------------------------------------------------------------------- 1. tags
local tags = {
    browser = { class = {
        "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$",
        "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$", "^(chrome-.+-Default)$", "^([Cc]hromium)$",
        "^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$", "^(Brave-browser(-beta|-dev|-unstable)?)$",
        "^([Tt]horium-browser|[Cc]achy-browser)$", "^(zen-alpha|zen)$", "^(org.gnome.Epiphany)$" } },
    notif        = { class = { "^(swaync-control-center|swaync-notification-window|swaync-client|class)$" } },
    KooL_Cheat   = { title = { "^(KooL Quick Cheat Sheet)$" } },
    KooL_Settings = { title = { "^(KooL Hyprland Settings)$" } },
    ["KooL-Settings"] = { class = { "^(nwg-displays|nwg-look)$" } },
    terminal     = { class = { "^(Alacritty|kitty|kitty-dropterm)$" } },
    email        = { class = { "^([Tt]hunderbird|org.mozilla.Thunderbird)$", "^(eu.betterbird.Betterbird)$", "^(org.gnome.Evolution)$" } },
    projects     = { class = { "^(codium|codium-url-handler|VSCodium)$", "^(VSCode|code|Code|code-url-handler)$",
                               "^(jetbrains-.+)$", "^(dev.zed.Zed|antigravity)$" } },
    screenshare  = { class = { "^(com.obsproject.Studio)$" } },
    im           = { class = { "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$", "^([Ff]erdium)$", "^([Ww]hatsapp-for-linux)$",
                               "^(ZapZap|com.rtosta.zapzap)$", "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$",
                               "^(teams-for-linux)$", "^(im.riot.Riot|Element)$" } },
    games        = { class = { "^(gamescope)$", "^(steam_app_\\d+)$" } },
    gamestore    = { class = { "^([Ss]team)$", "^(com.heroicgameslauncher.hgl)$" }, title = { "^([Ll]utris)$" } },
    ["file-manager"] = { class = { "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$", "^(app.drey.Warp)$" } },
    wallpaper    = { class = { "^([Ww]aytrogen)$" } },
    multimedia   = { class = { "^([Aa]udacious)$" } },
    multimedia_video = { class = { "^([Mm]pv|vlc)$" } },
    settings     = { title = { "^(ROG Control)$", "(Kvantum Manager)" }, class = {
        "^(wihotspot(-gui)?)$", "^([Bb]aobab|org.gnome.[Bb]aobab)$", "^(gnome-disks)$",
        "^(file-roller|org.gnome.FileRoller)$", "^(nm-applet|nm-connection-editor|blueman-manager)$",
        "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$", "^(qt5ct|qt6ct)$",
        "(xdg-desktop-portal-gtk)", "^(org.kde.polkit-kde-authentication-agent-1)$", "^([Rr]ofi)$",
        "^(btrfs-assistant)$", "^(timeshift-gtk)$" } },
    viewer       = { class = { "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$",
                               "^(evince)$", "^(eog|org.gnome.Loupe|imv-dir)$" } },
}
for tag, m in pairs(tags) do
    for _, c in ipairs(m.class or {}) do rule({ class = c }, { tag = "+" .. tag }) end
    for _, t in ipairs(m.title or {}) do rule({ title = t }, { tag = "+" .. tag }) end
end

----------------------------------------------------------------------- 2. per-tag settings
local big = "(monitor_w*0.7) (monitor_h*0.7)"

-- floating + centered
for _, t in ipairs({ "KooL_Cheat", "KooL-Settings", "settings", "viewer", "wallpaper" }) do
    rule({ tag = t }, { float = true, center = true })
end
rule({ tag = "KooL_Cheat" }, { size = "(monitor_w*0.65) (monitor_h*0.9)" })
rule({ tag = "settings" },   { size = big })
rule({ tag = "wallpaper" },  { size = big })

-- transparency: "active inactive" (Hyprlust values)
local opacity = {
    browser = "1 1", projects = "0.9 0.8", im = "0.94 0.86", multimedia = "0.94 0.86",
    ["file-manager"] = "0.9 0.8", terminal = "0.8 0.7", settings = "0.8 0.7",
    viewer = "0.82 0.75", wallpaper = "0.9 0.7",
}
for t, o in pairs(opacity) do rule({ tag = t }, { opacity = o }) end
rule({ class = "^(gedit|org.gnome.TextEditor|mousepad)$" }, { opacity = "0.8 0.7" })
rule({ class = "^(deluge|seahorse)$" },                     { opacity = "0.9 0.8" })

-- video & games: no blur, fully opaque
rule({ tag = "multimedia_video" }, { no_blur = true, opacity = "1 1" })
rule({ tag = "multimedia" },       { no_blur = true })
rule({ tag = "games" },            { no_blur = true, fullscreen = true })

-- don't let the screen sleep while something is fullscreen (videos, games)
rule({ fullscreen = true }, { idle_inhibit = "fullscreen" })

----------------------------------------------------------------------- 3. individual apps / dialogs
rule({ class = "([Zz]oom|onedriver|onedriver-launcher)" },   { float = true })
rule({ class = "(org.gnome.Calculator|qalculate-gtk|[Qq]alculate-gtk)" }, { float = true })
rule({ class = "^(mpv|com.github.rafostar.Clapper)$" },      { float = true })
rule({ class = "^([Ff]erdium)$" },   { float = true, center = true, size = "(monitor_w*0.6) (monitor_h*0.7)" })
rule({ class = "^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$" }, { center = true, size = "(monitor_w*0.6) (monitor_h*0.7)" })
rule({ class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, { center = true })
rule({ title = "^(Keybindings)$" },  { center = true })
rule({ title = "^(Authentication Required)$" }, { float = true, center = true })
rule({ class = "(codium|codium-url-handler|VSCodium)", title = "negative:(.*codium.*|.*VSCodium.*)" }, { float = true })
rule({ class = "^(com.heroicgameslauncher.hgl)$", title = "negative:(Heroic Games Launcher)" }, { float = true })
rule({ class = "^([Ss]team)$", title = "negative:^([Ss]team)$" }, { float = true })
-- Thunar dialogs (copy progress etc.) float; the main Thunar window stays tiled
rule({ class = "([Tt]hunar)", title = "negative:(.*[Tt]hunar.*)" }, { float = true, center = true })

-- file pickers and save dialogs
local dialog = "(monitor_w*0.7) (monitor_h*0.6)"
rule({ title = "^(Add Folder to Workspace)$" }, { float = true, center = true, size = dialog })
rule({ title = "^(Save As)$" },                 { float = true, center = true, size = dialog })
rule({ initial_title = "(Open Files)" },        { float = true, size = dialog })
rule({ title = "^(Preview)$" },                 { float = true, size = "(monitor_w*0.6) (monitor_h*0.8)" })
rule({ title = "^(SDDM Background)$" },         { float = true, center = true, size = "(monitor_w*0.16) (monitor_h*0.12)" })
rule({ class = "^(yad)$" },                     { float = true, center = true, size = "(monitor_w*0.2) (monitor_h*0.2)" })
rule({ class = "^(hyprland-donate-screen)$" },  { float = true, center = true })

-- picture-in-picture video: small, pinned in the top-right corner on every workspace
rule({ title = "^(Picture-in-Picture)$" }, {
    float = true, pin = true, keep_aspect_ratio = true, opacity = "0.95 0.75",
    size = "(monitor_w*0.3) (monitor_h*0.3)", move = "(monitor_w*0.69) (monitor_h*0.07)",
})

-- dropdown terminal (SUPER+SHIFT+Return)
rule({ class = "^(kitty-dropterm)$" }, {
    float = true, workspace = "special:dropterm",
    size = "(monitor_w*0.75) (monitor_h*0.6)", move = "(monitor_w*0.125) (monitor_h*0.05)",
})

-- global theme picker (SUPER+T): one floating window, list + live preview
rule({ class = "^(theme-picker)$" }, { float = true, center = true, size = "(monitor_w*0.72) (monitor_h*0.72)" })
rule({ class = "^(effect-picker)$" }, { float = true, center = true, size = "(monitor_w*0.8) (monitor_h*0.75)" })
rule({ class = "^(waybar-style-picker)$" }, { float = true, center = true, size = "(monitor_w*0.3) (monitor_h*0.55)" })

-- Browsers and Slack may bring themselves to the front when activated (e.g. a link opened
-- from another app jumps to the browser; finishing a browser sign-in jumps back to Slack).
-- Other apps still can't steal focus (misc.focus_on_activate = false).
rule({ tag = "browser" }, { focus_on_activate = true })
rule({ class = "^([Ss]lack)$" }, { focus_on_activate = true })

rule({ class = "^(jetbrains-.*)$" }, { no_initial_focus = true })

----------------------------------------------------------------------- 4. layer rules (bars, menus, popups)
local function layer(ns, effects)
    effects.match = { namespace = ns }
    hl.layer_rule(effects)
end
layer("waybar",                     { blur = true, blur_popups = true, ignore_alpha = 0.55 })
layer("rofi",                       { blur = true, ignore_alpha = 0 })
layer("notifications",              { blur = true })
layer("swaync-control-center",      { blur = true, ignore_alpha = 0, animation = "popin 80%" })
layer("swaync-notification-window", { blur = true, ignore_alpha = 0, animation = "slide" })
layer("logout_dialog",              { blur = true })
layer("gtk-layer-shell",            { blur = true, ignore_alpha = 0 })
layer("quickshell:overview",        { blur = true, ignore_alpha = 0.5 })
