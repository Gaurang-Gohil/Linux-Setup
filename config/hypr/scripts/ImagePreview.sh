#!/usr/bin/env bash
# Shows <dir>/<name>.png in fzf's preview pane (kitty graphics), with <name> as the title.
# Usage: ImagePreview.sh <dir> <name>
img="$1/$2.png"; title="$2"
[ -f "$img" ] || { echo "  No preview yet"; exit 0; }
cols=${FZF_PREVIEW_COLUMNS:-80}; lines=${FZF_PREVIEW_LINES:-30}; top=0
[ -n "$title" ] && { echo "  $title"; top=1; }
kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no \
    --place="${cols}x$((lines - top))@0x${top}" "$img" | sed '$d' | sed $'$s/$/\e[m/'
