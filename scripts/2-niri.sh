#!/bin/bash

#### Advanced Niri WM Installation Script by ####
#### Shell Ninja ( https://github.com/shell-ninja ) ####

# color defination
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;1;35m"
cyan="\e[1;36m"
orange="\e[1;38;5;214m"
end="\e[1;0m"

display_text() {
    gum style \
        --border rounded \
        --align center \
        --width 60 \
        --margin "1" \
        --padding "1" \
        '
        _   __ _        _ 
       / | / /(_)_____ (_)
      /  |/ // // ___// / 
     / /|  // // /   / /  
    /_/ |_//_//_/   /_/   
                          
'
}

clear && display_text
printf " \n \n"

###------ Startup ------###

# install script dir
dir="$(dirname "$(realpath "$0")")"
source "$dir/1-global_script.sh"

parent_dir="$(dirname "$dir")"
source "$parent_dir/interaction_fn.sh"

# log directory
log_dir="$parent_dir/Logs"
log="$log_dir/niri-$(date +%d-%m-%y).log"

# skip installed cache
cache_dir="$parent_dir/.cache"
installed_cache="$cache_dir/installed_packages"

mkdir -p "$log_dir"
touch "$log"

aur_helper=$(command -v yay || command -v paru) # find the aur helper

_niri=(
    niri
    wlr-randr
)

# checking already installed packages 
for skipable in "${_niri[@]}"; do
    skip_installed "$skipable"
done

to_install=($(printf "%s\n" "${_niri[@]}" | grep -vxFf "$installed_cache"))

printf "\n\n"

# Instlling main packages...
for niri_pkgs in "${to_install[@]}"; do
    install_package "$niri_pkgs"

    if sudo pacman -Q "$niri_pkgs" &>/dev/null; then
        echo "[ DONE ] - $niri_pkgs was installed successfully!\n" 2>&1 | tee -a "$log" &>/dev/null
    else
        echo "[ ERROR ] - Sorry, could not install $niri_pkgs!\n" 2>&1 | tee -a "$log" &>/dev/null
    fi
done

sleep 1 && clear
