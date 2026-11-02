-- Programs started once when Hyprland starts (not on reload).

hl.on("hyprland.start", function()
    -- wallpaper daemon (swww was renamed to awww); it restores the last wallpaper itself
    hl.exec_cmd("awww-daemon")

    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    hl.exec_cmd(scripts .. "/Polkit.sh")       -- password prompts for apps that need root
    hl.exec_cmd("swaync")                      -- notifications
    hl.exec_cmd("waybar")                      -- top bar
    hl.exec_cmd("nm-applet --indicator")       -- wifi tray icon
    hl.exec_cmd("blueman-applet")              -- bluetooth tray icon
    hl.exec_cmd("hypridle")                    -- screen off / lock when idle
    hl.exec_cmd("qs -c overview")              -- desktop overview (SUPER+A), needs quickshell
    hl.exec_cmd("wl-paste --type text --watch cliphist store")   -- clipboard history
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- JaKooLit's first-login setup: sets the wallpaper, wallust colors and GTK/icon/cursor themes.
    -- It only runs once (creates ~/.config/hypr/.initial_startup_done).
    hl.exec_cmd(HYPR .. "/initial-boot.sh")
end)
