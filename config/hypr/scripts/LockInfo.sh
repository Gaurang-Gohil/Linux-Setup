#!/usr/bin/env bash
# Small text bits for the lock screen (hyprlock.conf).
# Usage: LockInfo.sh media | battery | weather
case "$1" in
  media)
    st=$(playerctl status 2>/dev/null) || exit 0
    [ "$st" = "Playing" ] || [ "$st" = "Paused" ] || exit 0
    t=$(playerctl metadata title 2>/dev/null | cut -c1-40)
    a=$(playerctl metadata artist 2>/dev/null | cut -c1-30)
    icon=$'\uf04b'; [ "$st" = "Paused" ] && icon=$'\uf04c'
    t=${t//&/&amp;}; t=${t//</&lt;}; a=${a//&/&amp;}; a=${a//</&lt;}
    echo "$icon   $t${a:+  <span alpha='60%'>·  $a</span>}" ;;
  battery)
    for b in /sys/class/power_supply/BAT*; do
      [ -f "$b/capacity" ] || continue
      c=$(<"$b/capacity"); s=$(<"$b/status")
      icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
      i=${icons[$(( c >= 100 ? 9 : c / 10 ))]}
      [ "$s" = "Charging" ] && i="󰂄"
      echo "$i  $c%"; exit 0
    done ;;
  weather)
    f="$HOME/.cache/.weather_cache"; [ -f "$f" ] || exit 0
    echo "$(sed -n 2p "$f" | xargs)   $(sed -n 3p "$f" | cut -d'(' -f1 | xargs)" ;;
esac
