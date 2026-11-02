#!/usr/bin/env bash
# Shows one wallpaper-effect preview image in fzf's preview pane (used by WallpaperEffects.sh).
# Usage: EffectPreview.sh <preview-dir> <effect name>
dir="$1"; name="$2"
img="$dir/$(printf "%s" "$name" | md5sum | cut -c1-10).png"
[ -f "$img" ] || { echo "No preview for $name"; exit 0; }
cols=${FZF_PREVIEW_COLUMNS:-80}; lines=${FZF_PREVIEW_LINES:-30}
echo "  $name"
# kitty graphics: draw the image to fill the pane below the title line
kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no \
    --place="${cols}x$((lines - 1))@0x1" "$img" | sed '$d' | sed $'$s/$/\e[m/'
