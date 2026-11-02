#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##

# GDK BACKEND. Change to either wayland or x11 if having issues
BACKEND=wayland

# Check if rofi or yad is running and kill them if they are
if pidof rofi > /dev/null; then
  pkill rofi
fi

if pidof yad > /dev/null; then
  pkill yad
fi

# Launch yad with calculated width and height
GDK_BACKEND=$BACKEND yad \
    --center \
    --title="KooL Quick Cheat Sheet" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
"ESC" "close this app" "" " = " "SUPER KEY (Windows Key Button)" "(SUPER KEY)" \
" SHIFT K" "Searchable Keybinds" "(Search all Keybinds via rofi)" \
" SHIFT E" "KooL Hyprland Settings Menu" "" \
"" "" "" \
" enter" "Terminal" "(kitty)" \
" SHIFT enter" "DropDown Terminal" " Q to close" \
" B" "Launch Browser" "(Default browser)" \
" A" "Desktop Overview" "(AGS - if opted to install)" \
" (tap)" "Application Launcher" "(rofi-wayland)" \
" E" "Open File Manager" "(Thunar)" \
" S" "Show/hide scratchpad" "(SHIFT U sends a window there)" \
" T" "Global theme switcher" "(rofi)" \
" Q" "close active window" "(not kill)" \
" Shift Q " "kills an active window" "(kill)" \
" ALT mouse scroll up/down   " "Desktop Zoom" "Desktop Magnifier" \
" V" "Clipboard Manager" "(cliphist)" \
" W" "Choose wallpaper" "(Wallpaper Menu)" \
" Shift W" "Choose wallpaper effects" "(imagemagick + awww)" \
"CTRL ALT W" "Random wallpaper" "(via awww)" \
" CTRL ALT B" "Hide/UnHide Waybar" "waybar" \
" CTRL B" "Choose waybar styles" "(waybar styles)" \
" ALT B" "Choose waybar layout" "(waybar layout)" \
" ALT R" "Reload Waybar swaync Rofi" "CHECK NOTIFICATION FIRST!!!" \
" N" "Launch Notification Panel" "swaync Notification Center" \
" Print" "screenshot" "(grim)" \
" Shift Print" "screenshot region" "(grim + slurp)" \
" Shift S" "screenshot region" "(swappy)" \
" CTRL Print" "screenshot timer 5 secs " "(grim)" \
" CTRL SHIFT Print" "screenshot timer 10 secs " "(grim)" \
"ALT Print" "Screenshot active window" "active window only" \
" P" "power-menu" "(wlogout)" \
" L" "screen lock" "(hyprlock)" \
"CTRL ALT Del" "Hyprland Exit" "(NOTE: Hyprland Will exit immediately)" \
" F" "Fullscreen" "Toggles to full screen" \
" D" "Fake Fullscreen" "Toggles to fake full screen" \
" SHIFT L" "Toggle Dwindle | Master Layout" "Hyprland Layout" \
" ALT O" "Toggle Blur" "normal or less blur" \
" CTRL O" "Toggle Opaque ON or OFF" "on active window only" \
" Shift A" "Animations Menu" "Choose Animations via rofi" \
" CTRL R" "Rofi Themes Menu" "Menu themes with preview" \
" SHIFT G" "Gamemode! All animations OFF or ON" "toggle" \
" SHIFT A" "Animation presets" "pick and apply" \
" ." "Rofi Emoticons" "Emoticon" \
" H" "Launch this Quick Cheat Sheet" "" \
"" "" "" \
"More tips:" "https://github.com/JaKooLit/Hyprland-Dots/wiki" ""\
