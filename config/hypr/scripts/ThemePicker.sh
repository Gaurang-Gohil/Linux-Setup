#!/usr/bin/env bash
# Theme list + live preview in one window (opened by ThemeChanger.sh, SUPER+T).
# Writes the chosen theme name to the file given as $1 (empty if cancelled).
out="$1"
{ echo '🖼  Follow wallpaper colors'; wallust theme list | sed -e '1d' -e 's/^- //'; } | fzf --with-shell 'bash -c' \
    --prompt '  Theme ❯ ' --layout reverse --info inline-right --no-scrollbar \
    --header 'Enter: apply   Esc: cancel   type to search   ↑↓ / scroll / click to preview' \
    --preview "$HOME/.config/hypr/scripts/ThemePreview.sh {}" \
    --preview-window 'right,68%,border-left' > "$out"
