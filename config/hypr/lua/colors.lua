-- Reads the colors wallust generates from your wallpaper.
-- Changing the wallpaper (SUPER+W) or theme re-generates the file and reloads Hyprland,
-- so borders follow the wallpaper automatically. Use them as C.color12, C.background, etc.

C = {
    background = "rgb(1e1e2e)", foreground = "rgb(cdd6f4)",
    color0 = "rgb(45475a)", color2 = "rgb(a6e3a1)", color10 = "rgb(94e2d5)",
    color12 = "rgb(89b4fa)", color15 = "rgb(bac2de)",
}

local f = io.open(HYPR .. "/wallust/wallust-hyprland.conf", "r")
if f then
    local text = f:read("a")
    f:close()
    for name, value in text:gmatch("%$(%w+)%s*=%s*(rgba?%b())") do
        C[name] = value
    end
end
