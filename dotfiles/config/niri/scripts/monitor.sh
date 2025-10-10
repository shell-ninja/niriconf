#!/bin/bash

config_file="$HOME/.config/niri/config.kdl"

display() {
    cat << "EOF"
   __  ___          _ __             ____    __          
  /  |/  /__  ___  (_) /____  ____  / __/__ / /___ _____ 
 / /|_/ / _ \/ _ \/ / __/ _ \/ __/ _\ \/ -_) __/ // / _ \
/_/  /_/\___/_//_/_/\__/\___/_/   /___/\__/\__/\_,_/ .__/
                                                  /_/    
EOF
}


gum spin \
    --spinner minidot \
    --spinner.foreground "#dceabf" \
    --title.foreground "#dceabf" \
    --title "Setting up for your Monitor" -- \
    sleep 2

clear

monitor_name=$(wlr-randr | grep "^[^ ]" | awk '{print $1}')
monitor_resolution=$(wlr-randr | awk '/current/ {print $1}')

display
refresh_rate=$(gum choose \
    --header "󰍹 Choose the refresh rate for your '$monitor_name' monitor:" \
    "59.951 Hz (≈60Hz)" "74.973 Hz (≈75Hz)" "119.880 Hz (≈120Hz)" \
    "143.855 Hz (≈144Hz)" "164.997 Hz (≈165Hz)" "239.760 Hz (≈240Hz)"
)

rate_value=$(echo "$refresh_rate" | awk '{print $1}')

sed -i "s/output .*/output \"${monitor_name}\" {/" "$config_file"
sed -i "s/mode .*/mode \"${monitor_resolution}@${rate_value}\"/" "$config_file"
