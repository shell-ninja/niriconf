#!/bin/bash

#### Advanced Niri WM Installation Script by ####
#### Shell Ninja ( https://github.com/shell-ninja ) ####


# --------------- color defination
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;1;35m"
cyan="\e[1;36m"
orange="\e[1;38;5;214m"
end="\e[1;0m"

# --------------- color defination (hex for gum)
red_hex="#FF0000"       # Bright red
green_hex="#00FF00"     # Bright green
yellow_hex="#FFFF00"    # Bright yellow
blue_hex="#0000FF"      # Bright blue
magenta_hex="#FF00FF"   # Bright magenta (corrected spelling)
cyan_hex="#00FFFF"      # Bright cyan
orange_hex="#FFAF00"    # Approximation for color code 214 in ANSI (orange)

# -------------- log directory
dir="$(dirname "$(realpath "$0")")"
source "$dir/interaction_fn.sh"
log_dir="$dir/Logs"
log="$log_dir"/niriconf-$(date +%d-%m-%y).log
mkdir -p "$log_dir"
touch "$log"

# ---------------- creating a cache directory..
cache_dir="$dir/.cache"
cache_file="$cache_dir/user-cache"
shell_cache="$cache_dir/shell"
pkgman_cache="$cache_dir/pkgman"

# --------------- sourcing the interaction prompts
if [[  "$dir/interaction_fn.sh" ]]; then
    source "$dir/interaction_fn.sh"
fi

if [[ ! -d "$cache_dir" ]]; then
    mkdir -p "$cache_dir"
fi

# installing git and gum if these are not installed...
packages=(
    git
    gum
)

for pkg in "${packages[@]}"; do

    if sudo pacman -Q "$pkg" &> /dev/null; then
        printf "${magenta}[ Skip ] ${end} Skipping $pkg, it's already installed...\n"
    else
        printf "${green}=>${end} Installing $pkg...\n"
        if sudo pacman -S --noconfirm "$pkg" &> /dev/null; then
            printf "${cyan}::${end} Successfully installed ${cyan}$pkg${end}...\n"
        fi
    fi

done

sleep 1 && clear && fn_welcome && sleep 1

# starting the main script prompt...
. /etc/os-release
msg act "Starting the main scripts for ${cyan}$NAME${end}..." && sleep 2
clear

# =================================================== #
# =========  functions to ask user prompts  ========= #
# =================================================== #

if [[ -f "$cache_file" ]]; then
    source "$cache_file"

    # Check if Nvidia prompt has no value set
    if [[ -z "$install_browser" ]]; then
        msg err "User prompt was not given properly. Please run the script again..."

        fn_ask "Would you like to run the script agaain?" "Yes, sure." "No, close it."

        if [[ $? -eq 0 ]]; then
            gum spin --spinner dot --title "Starting the script again.." -- sleep 3
            rm -f "$cache_file"
            "$dir/start.sh"
        else
            fn_exit "Exiting the script here. Goodbye."
        fi
    else
        msg skp "Cache file is there. Skipping prompts..." && sleep 1
    fi
else
    touch "$cache_file"
    # Initialize default options and their values
    declare -A options=(
        ["setup_for_bluetooth"]=""
        ["install_vs_code"]=""
        ["install_browser"]=""
    )

    # Write initial options to the cache file
    initialize_cache_file() {
        > "$cache_file"
        for key in "${!options[@]}"; do
            echo "$key=''" >> "$cache_file"
        done
    }

    initialize_cache_file

    msg att "Choose prompts. Press 'ESC' to skip"
    fn_ask_prompts 

    echo
    echo

    touch "$shell_cache"
    # Initialize default options and their values
    declare -A shell_options=(
        ["install_fish"]=""
        ["install_zsh"]=""
        ["setup_bash"]=""
    )

    # Write initial options to the cache file
    initialize_shell_cache() {
        > "$shell_cache"
        for key in "${!shell_options[@]}"; do
            echo "$key=''" >> "$shell_cache"
        done
    }

    initialize_shell_cache

    msg att "Choose prompts. Press 'ESC' to skip"
    fn_shell
fi


source "$cache_file"
source "$shell_cache"


# ====================================== #
# =========  script execution  ========= #
# ====================================== #

scripts_dir="$dir/scripts"
chmod +x "$scripts_dir"/* 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")

clear


# ================================= #
# =========  run scripts  ========= #
# ================================= #

# -------------- AUR helper and other repositories.
aur=$(command -v yay || command -v paru)
if [[ -n "$aur" ]]; then
    msg dn "AUR helper $aur was located... Moving on" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
    sleep 1
else
    
    if hostnamectl | grep -q 'Chassis: vm'; then
        msg att "Virtual machine was detected, 'Yay' will be installed."

        touch "$cache_dir/aur"
        echo "yay" > "$cache_dir/aur"
    else
        touch "$cache_dir/aur"
        msg ask "Which AUR helper would you like to install?"
        # msg att "If you are in a virtual machine, please choose ${cyan}'yay'${end}"
        choice=$(gum choose \
            --cursor.foreground "#00FFFF" \
            --item.foreground "#fff" \
            --selected.foreground "#00FF00" \
            "paru" "yay"
        )

        if [[ "$choice" == "paru" ]]; then
            echo "paru" > "$cache_dir/aur"
        elif [[ "$choice" == "yay" ]]; then
            echo "yay" > "$cache_dir/aur"
        fi
    fi

    "$scripts_dir/00-repo.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
fi


# ---------------- Installing hyprland and other packages
"$scripts_dir/2-niri.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")

"$scripts_dir/3-other_packages.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
"$scripts_dir/6-fonts.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")

# only for installing browser
if [[ "$install_browser" =~ ^[Yy]$ ]]; then
    touch "$cache_dir/browser"
    if [[ "$pkgman" == "pacman" ]]; then
        msg ask "Choose a browser: "
        choice=$(gum choose \
            --cursor.foreground "#00FFFF" \
            --item.foreground "#fff" \
            --selected.foreground "#00FF00" \
            "Brave" "Google_Chrome" "Chromium" "Firefox" "Vivaldi" "Zen Browser" "Skip"
        )
        echo "$choice" > "$cache_dir/browser"
    fi

    "$scripts_dir/7-browser.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
else
    msg skp "Skipping installing browser.."
fi

"$scripts_dir/9-sddm.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
"$scripts_dir/10-xdg_dp.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")


# ---------------- Scripts with user agreement
if [[ "$install_vs_code" =~ ^[Yy]$ ]]; then
    "$scripts_dir/8-vs_code.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
fi


# if [[ "$have_nvidia" =~ ^[Yy]$ ]]; then
#     "$scripts_dir/nvidia.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
# fi


if [[ "$setup_for_bluetooth" =~ ^[Yy]$ ]]; then
    "$scripts_dir/bluetooth.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
fi


if [[ "$install_zsh" =~ ^[Yy]$ ]]; then
    "$scripts_dir/zsh.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
fi


if [[ "$setup_bash" =~ ^[Yy]$ ]]; then
    "$scripts_dir/bash.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
fi


if [[ "$install_fish" =~ ^[Yy]$ ]]; then
    "$scripts_dir/fish.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
fi


# ----------------- Uninstall some packages
"$scripts_dir/11-uninstall.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")


# ---------------- Themes and dotfiles (hyprconf)

sleep 1 && clear

# msg ask "Choose which config you want to setup: " && sleep 1
# msg att "The 'hyprconf' config will change colors according to the current wallpaper using ${cyan}pywal${end}, inspired by JaKooLit's cofig." && echo
# msg att "The 'hyprconf-v2' config hase some pre-configured themes and color pallets, inspired by HyDE."
#
# choice=$(gum choose \
#     --limit=1 \
#     --cursor.foreground "#00FFFF" \
#     --item.foreground "#fff" \
#     --selected.foreground "#00FF00" \
#     "hyprconf" "hyprconf-v2"
# )
# touch "$cache_dir/dotfiles"
# echo "$choice" > "$cache_dir/dotfiles"
# sleep 1 && clear

"$scripts_dir/themes.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
"$dir/dotfiles/setup.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")


# ----------------- check if laptop or not
if [[ -d "/sys/class/power_supply/BAT0" ]]; then
    system="laptop"
else
    system="desktop"
fi

"$scripts_dir/${system}.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")

sleep 1 && clear


# =================================== #
# =========  final checkup  ========= #
# =================================== #

gum spin --spinner dot \
         --title "Starting final checkup.." \
         sleep 3
clear

"$scripts_dir/12-final.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")


# =================================== #
# =========  system reboot  ========= #
# =================================== #

msg dn "Congratulations! The script completes here." && sleep 2
msg att "Need to reboot the system."

fn_ask "Would you like to reboot now?" "Reboot" "No, skip"
if [[ $? -eq 0 ]]; then
    clear
    # rebooting the system in 3 seconds
    for second in 3 2 1; do
        printf ":: Rebooting the system in ${second}s\n" && sleep 1 && clear
    done
        systemctl reboot --now
else
    msg nt "Ok, but make sure to reboot the system." && sleep 1
    msg dn "Happy coding..."
    exit 0
fi

# =========______  Script ends here  ______========= #
