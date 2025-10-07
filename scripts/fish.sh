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
    _______      __  
   / ____(_)____/ /_ 
  / /_  / / ___/ __ \
 / __/ / (__  ) / / /
/_/   /_/____/_/ /_/ 
                              
'
}

clear && display_text
printf " \n \n"

###------ Startup ------###

dir="$(dirname "$(realpath "$0")")"

parent_dir="$(dirname "$dir")"
source "$parent_dir/interaction_fn.sh"

cache_dir="$parent_dir/.cache"

# install script dir
source "$parent_dir/scripts/1-global_script.sh"

log_dir="$parent_dir/Logs"
log="$log_dir/fish-$(date +%d-%m-%y).log"

# skip installed cache
installed_cache="$parent_dir/.cache/installed_packages"

if [[ -f "$log" ]]; then
    errors=$(grep "ERROR" "$log")
    last_installed=$(grep "thefuck" "$log" | awk {'print $2'})
    if [[ -z "$errors" && "$last_installed" == "DONE" ]]; then
        msg skp "Skipping this script. No need to run it again..."
        sleep 1
        exit 0
    fi
else
    mkdir -p "$log_dir"
    touch "$log"
fi

# required packages
_packages=(
    bat
    curl
    eza
    fastfetch
    figlet
    fish
    fzf
    git
    rsync
    starship
    thefuck
    zoxide
)


# checking already installed packages 
for skipable in "${_packages[@]}"; do
    skip_installed "$skipable"
done

to_install=($(printf "%s\n" "${_packages[@]}" | grep -vxFf "$installed_cache"))

printf "\n\n"

# Instlling main packages...
for shell in "${to_install[@]}"; do
    install_package "$shell"
done

if [[ ! "$SHELL" == "$(which fish)" ]]; then
    msg act "Changing shell to fish.."
    chsh -s "$(which fish)"
fi

sleep 1 && clear
