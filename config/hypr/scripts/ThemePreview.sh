#!/usr/bin/env bash
# Draws a mock desktop in a wallust theme's colors (used by ThemeChanger.sh's preview pane).
# Usage: ThemePreview.sh <theme-name>
# Reads the palette with a throwaway wallust config, so your real colors are never touched.

theme="$1"
[ -z "$theme" ] && exit 0
if [[ "$theme" == 🖼* ]]; then
    printf '\n  Unlock the theme: colors come from your wallpaper again,\n  and change every time you change wallpaper (SUPER+W).\n\n  Picking any other theme in this list locks that theme,\n  so it stays even when you change wallpaper.\n'
    exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/templates"
echo '{{background}} {{foreground}} {{color0}} {{color1}} {{color2}} {{color3}} {{color4}} {{color5}} {{color6}} {{color7}} {{color8}} {{color9}} {{color10}} {{color11}} {{color12}} {{color13}} {{color14}} {{color15}}' > "$tmp/templates/pal"
printf '[templates]\npal = { template = "pal", target = "%s/out" }\n' "$tmp" > "$tmp/wallust.toml"
wallust theme -d "$tmp" -s -q --no-hooks -- "$theme" >/dev/null 2>&1
[ -s "$tmp/out" ] || { echo "No preview for $theme"; exit 0; }
read -r BG FG C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12 C13 C14 C15 < "$tmp/out"

W=${FZF_PREVIEW_COLUMNS:-70}

rgb() { local h=${1#\#}; printf '%d;%d;%d' 0x${h:0:2} 0x${h:2:2} 0x${h:4:2}; }
fg()  { printf '\e[38;2;%sm' "$(rgb "$1")"; }
bg()  { printf '\e[48;2;%sm' "$(rgb "$1")"; }
R=$'\e[0m'
BGc=$(bg "$BG")

# one full-width line on the theme background; text may contain color codes
line() {
    local text="$1" plain
    plain=$(printf '%s' "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local pad=$(( W - ${#plain} )); (( pad < 0 )) && pad=0
    printf '%s%s%s%*s%s\n' "$BGc" "$(fg "$FG")" "$text" "$pad" "" "$R"
}
blank() { line ""; }

# ---- title
blank
BOLD=$'\e[1m'; NOBOLD=$'\e[22m'
line "  $(fg "$C12")${BOLD}${theme}${NOBOLD}$(fg "$FG")"
blank

# ---- top bar mock (accent = color12, like your borders)
bar="  $(bg "$C0")$(fg "$C12")  ● ● ●  $(bg "$C12")$(fg "$BG") 1 $(bg "$C0")$(fg "$FG") 2  3  4 ${BGc}  $(bg "$C0")$(fg "$C10")  ${BGc}  $(bg "$C0")$(fg "$FG") 95% │ 12:56 ${BGc}"
line "$bar"
blank

# ---- terminal mock
line "  $(fg "$C10")$USER$(fg "$FG")@$(fg "$C12")$(cat /etc/hostname)$(fg "$FG") $(fg "$C4")~/projects$(fg "$C13") ❯$(fg "$FG") ls"
line "  $(fg "$C4")docs/  $(fg "$C2")build.sh*  $(fg "$FG")notes.md  $(fg "$C5")photo.png  $(fg "$C1")old.tar.gz"
line "  $(fg "$C10")$USER$(fg "$FG")@$(fg "$C12")$(cat /etc/hostname)$(fg "$FG") $(fg "$C4")~/projects$(fg "$C13") ❯$(fg "$FG") git status"
line "  $(fg "$C2")modified:   $(fg "$FG")main.py    $(fg "$C1")deleted:   $(fg "$FG")old.txt"
blank

# ---- code mock
line "  $(fg "$C8")# greet a user$(fg "$FG")"
line "  $(fg "$C5")def $(fg "$C4")greet$(fg "$FG")(name: $(fg "$C6")str$(fg "$FG")) -> $(fg "$C6")None$(fg "$FG"):"
line "      $(fg "$C5")if $(fg "$FG")name $(fg "$C5")== $(fg "$C2")\"\"$(fg "$FG"):"
line "          name = $(fg "$C2")\"world\"$(fg "$FG")   $(fg "$C8")# default$(fg "$FG")"
line "      $(fg "$C4")print$(fg "$FG")($(fg "$C3")f\"Hello, {name}!\"$(fg "$FG"), count=$(fg "$C11")3$(fg "$FG"))"
blank

# ---- palette: color0-7 and color8-15
row() { local s="  " c; for c in "$@"; do s+="$(bg "$c")      ${BGc} "; done; line "$s"; }
row "$C0" "$C1" "$C2" "$C3" "$C4" "$C5" "$C6" "$C7"
row "$C0" "$C1" "$C2" "$C3" "$C4" "$C5" "$C6" "$C7"
blank
row "$C8" "$C9" "$C10" "$C11" "$C12" "$C13" "$C14" "$C15"
row "$C8" "$C9" "$C10" "$C11" "$C12" "$C13" "$C14" "$C15"
blank
line "  $(fg "$C8")background $BG   foreground $FG   accent $C12$(fg "$FG")"
for _ in $(seq 1 20); do blank; done
