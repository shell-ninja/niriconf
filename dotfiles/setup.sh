#!/bin/bash

# Advanced niri wm Installation Script by
# Shell Ninja ( https://github.com/shell-ninja )

# color defination
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;1;35m"
cyan="\e[1;36m"
orange="\x1b[38;5;214m"
end="\e[1;0m"

if command -v gum &> /dev/null; then

display_text() {
    gum style \
        --border rounded \
        --align center \
        --width 60 \
        --margin "1" \
        --padding "1" \
'
    _   __ _        _                      ____
   / | / /(_)_____ (_)_____ ____   ____   / __/
  /  |/ // // ___// // ___// __ \ / __ \ / /_  
 / /|  // // /   / // /__ / /_/ // / / // __/  
/_/ |_//_//_/   /_/ \___/ \____//_/ /_//_/     
                                               
'
}

else
display_text() {
    cat << "EOF"
   __ __                            ___
  / // /_ _____  ___________  ___  / _/
 / _  / // / _ \/ __/ __/ _ \/ _ \/ _/ 
/_//_/\_, / .__/_/  \__/\___/_//_/_/   
     /___/_/                              

EOF
}
fi

clear && display_text
printf " \n \n"

###------ Startup ------###

# finding the presend directory and log file
dir="$(dirname "$(realpath "$0")")"
# log directory
log_dir="$dir/Logs"
log="$log_dir"/dotfiles.log
mkdir -p "$log_dir"
touch "$log"

# message prompts
msg() {
    local actn=$1
    local msg=$2

    case $actn in
        act)
            printf "${green}=>${end} $msg\n"
            ;;
        ask)
            printf "${orange}??${end} $msg\n"
            ;;
        dn)
            printf "${cyan}::${end} $msg\n\n"
            ;;
        att)
            printf "${yellow}!!${end} $msg\n"
            ;;
        nt)
            printf "${blue}\$\$${end} $msg\n"
            ;;
        skp)
            printf "${magenta}[ SKIP ]${end} $msg\n"
            ;;
        err)
            printf "${red}>< Ohh sheet! an error..${end}\n   $msg\n"
            sleep 1
            ;;
        *)
            printf "$msg\n"
            ;;
    esac
}


# Directories ----------------------------
niri_dir="$HOME/.config/niri"
scripts_dir="$niri_dir/scripts"
fonts_dir="$HOME/.local/share/fonts"

msg act "Now setting up the pre installed Niri WM configuration..." && sleep 1

mkdir -p ~/.config
dirs=(
    btop
    dunst
    fastfetch
    fish
    gtk-3.0
    gtk-4.0
    niri 
    kitty
    Kvantum
    menus
    nvim
    nwg-look
    qt5ct
    qt6ct
    rofi
    swaync
    waybar
    wlogout
    xsettingsd
    yazi
    dolphinrc
    kwalletmanagerrc
    kwalletrc
)

# Paths
backup_dir="$HOME/.temp-back"
wallpapers_backup="$backup_dir/Wallpaper"
hypr_cache_backup="$backup_dir/.cache"
hypr_config_backup="$backup_dir/configs.conf"
wallpapers="$HOME/.config/niri/Wallpapers"
niri_cache="$HOME/.config/niri/.cache"

# Ensure backup directory exists
mkdir -p "$backup_dir"

sleep 1

####################################################################

#_____ if OpenBangla Keyboard is installed
keyboard_path="/usr/share/openbangla-keyboard"

if [[ -d "$keyboard_path" ]]; then
    msg act "Setting up things for OpenBangla-Keyboard..."

    # Add fcitx5 environment variables to /etc/environment if not already present
    if ! grep -q "GTK_IM_MODULE=fcitx" /etc/environment; then
        printf "\nGTK_IM_MODULE=fcitx\n" | sudo tee -a /etc/environment 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log") &> /dev/null
    fi

    if ! grep -q "QT_IM_MODULE=fcitx" /etc/environment; then
        printf "QT_IM_MODULE=fcitx\n" | sudo tee -a /etc/environment 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log") &> /dev/null
    fi

    if ! grep -q "XMODIFIERS=@im=fcitx" /etc/environment; then
        printf "XMODIFIERS=@im=fcitx\n" | sudo tee -a /etc/environment 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log") &> /dev/null
    fi

fi

####################################################################

sleep 1

# creating symlinks
cp -a "$dir/config"/* "$HOME/.config/"
mv "$HOME/.config/fastfetch" "$HOME/.local/share/"
mkdir -p "$HOME/.local/bin" && mv "$HOME/.config/niri/scripts/monitor.sh" "$HOME/.local/bin/monitor"

sleep 1

if [[ -d "$scripts_dir" ]]; then
    # make all the scripts executable...
    chmod +x "$scripts_dir"/* 2>&1 | tee -a "$log"
    chmod +x "$HOME/.config/fish/functions"/* 2>&1 | tee -a "$log"
    msg dn "All the necessary scripts have been executable..."
    sleep 1
else
    msg err "Could not find necessary scripts.."
fi

# Install Fonts
msg act "Installing some fonts..."
if [[ ! -d "$fonts_dir" ]]; then
	mkdir -p "$fonts_dir"
fi

cp -r "$dir/extras/fonts" "$fonts_dir"
msg act "Updating font cache..."
sudo fc-cache -fv 2>&1 | tee -a "$log" &> /dev/null

### Setup extra files and dirs

# dolphinstaterc
if [[ -f "$HOME/.local/state/dolphinstaterc" ]]; then
    mv "$HOME/.local/state/dolphinstaterc" "$HOME/.local/state/dolphinstaterc.back"
fi

# konsole
if [[ -d "$HOME/.local/share/konsole" ]]; then
    mv "$HOME/.local/share/konsole" "$HOME/.local/share/konsole.back"
fi

cp -r "$dir/local/state/dolphinstaterc" "$HOME/.local/state/"
cp -r "$dir/local/share/konsole" "$HOME/.local/share/"

clear && sleep 1

# Asking if the user wants to download more wallpapers
msg ask "Would you like to add more ${green}Wallpapers${end}? ${blue}[ y/n ]${end}..."
read -r -p "$(echo -e '\e[1;32mSelect: \e[0m')" wallpaper

printf " \n"

# =========  wallpaper section  ========= #

if [[ "$wallpaper" =~ ^[Y|y]$ ]]; then
    url="https://github.com/shell-ninja/Wallpapers/archive/refs/heads/main.zip"

    target_dir="$HOME/.cache/wallpaper-cache"
    zip_path="$target_dir.zip"
    msg act "Downloading some wallpapers..."
    
    # Download the ZIP silently with a progress bar
    curl -L "$url" -o "$zip_path"

    if [[ -f "$zip_path" ]]; then
        mkdir -p "$target_dir"
        unzip "$zip_path" "wallpaper-cache-main/*" -d "$target_dir" > /dev/null
        mv "$target_dir/wallpaper-cache-main/"* "$target_dir" && rmdir "$target_dir/wallpaper-cache-main"
        rm "$zip_path"
    fi

    # copying the wallpaper to the main directory
    if [[ -d "$HOME/.cache/wallpaper-cache" ]]; then
        cp -r "$HOME/.cache/wallpaper-cache"/* ~/.config/niri/Wallpapers/ &> /dev/null
        rm -rf "$HOME/.cache/wallpaper-cache" &> /dev/null
        msg dn "Wallpapers were downloaded successfully..." 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log") & sleep 0.5
    else
        msg err "Sorry, could not download more wallpapers. Going forward with the limited wallpapers..." 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log") && sleep 0.5
    fi
fi

# =========  wallpaper section  ========= #

if [[ -d "$HOME/.config/niri/Wallpapers" ]]; then

    if [[ -d "$HOME/.config/niri/.cache" ]]; then
        wallName=$(cat "$HOME/.config/niri/.cache/.wallpaper")
        wallpaper=$(find "$HOME/.config/niri/Wallpapers" -type f -name "$wallName.*" | head -n 1)
    else
        mkdir -p "$HOME/.config/niri/.cache"
        wallCache="$HOME/.config/niri/.cache/.wallpaper"

        touch "$wallCache"      

        if [ -f "$HOME/.config/niri/Wallpapers/linux.jpg" ]; then
            echo "linux" > "$wallCache"
            wallpaper="$HOME/.config/niri/Wallpapers/linux.jpg"
        fi
    fi

    # setting the default wallpaper
    ln -sf "$wallpaper" "$HOME/.config/niri/.cache/current_wallpaper.png"
fi

msg act "Generating colors and other necessary things..."
"$HOME/.config/niri/scripts/wallcache.sh" &> /dev/null
"$HOME/.config/niri/scripts/pywal.sh" &> /dev/null


# setting default themes, icon and cursor
gsettings set org.gnome.desktop.interface gtk-theme 'TokyoNight'
gsettings set org.gnome.desktop.interface icon-theme 'TokyoNight'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'

crudini --set ~/.config/Kvantum/kvantum.kvconfig General theme "Dracula"
crudini --set ~/.config/kdeglobals Icons Theme "TokyoNight"


msg dn "Script execution was successful! Now logout and log back in and enjoy your customization..." && sleep 1

# === ___ Script Ends Here ___ === #
