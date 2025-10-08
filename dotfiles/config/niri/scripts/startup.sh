#!/bin/bash

scripts_dir="$HOME/.config/niri/scripts"
wallpaper="$HOME/.config/niri/.cache/current_wallpaper.png"

# Transition config
FPS=120
TYPE="any"
DURATION=1
BEZIER=".28,.58,.99,.37"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

if [[ -f "$wallpaper" ]]; then
    swww-daemon &
    swww img $wallpaper $SWWW_PARAMS
else
    "$scripts_dir/Wallpaper.sh"
fi

# if openbangla keyboard is installed, the
if [[ -d "/usr/share/openbangla-keyboard" ]]; then
    fcitx5 &> /dev/null
fi


"$scripts_dir/wallcache.sh"
"$scripts_dir/pywal.sh"
"$scripts_dir/default_browser.sh"
