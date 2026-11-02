#!/usr/bin/env bash
# Scrolling "title – artist" for the waybar media module (custom/media).
# Long names slide along like a ticker; short ones stay still. Prints one JSON line per tick.
export LC_ALL=C.UTF-8
width=32          # visible characters
tick=0.35         # seconds per step
pos=0; last=""

json() { jq -cn --arg t "$1" --arg tt "$2" --arg c "$3" '{text:$t, tooltip:$tt, class:$c}'; }
esc()  { local s=${1//&/&amp;}; s=${s//</&lt;}; printf '%s' "${s//>/&gt;}"; }

while true; do
    status=$(playerctl status 2>/dev/null)
    if [[ -z "$status" || "$status" == "Stopped" ]]; then
        json "" "" "stopped"; last=""; sleep 1; continue
    fi
    title=$(playerctl metadata title 2>/dev/null); artist=$(playerctl metadata artist 2>/dev/null)
    text=$title; [[ -n "$artist" ]] && text="$title – $artist"
    [[ "$text" != "$last" ]] && { pos=0; last=$text; }

    if (( ${#text} <= width )); then
        shown=$text
    else
        loop="$text     •     "
        doubled="$loop$loop"
        shown=${doubled:pos:width}
        pos=$(( (pos + 1) % ${#loop} ))
    fi

    if [[ "$status" == "Playing" ]]; then icon=$'\uf04b'; cls="playing"; else icon=$'\uf04c'; cls="paused"; fi   # nerd-font play / pause
    tip="$text
Tap / click: next   •   2-finger tap: previous   •   3-finger tap: play/pause   •   scroll: volume"
    json "$icon  $(esc "$shown")" "$(esc "$tip")" "$cls"
    sleep "$tick"
done
