#!/bin/bash

case $1 in
    --poweroff)
        "$HOME/.config/niri/scripts/uptime.sh"
        "$HOME/.config/niri/scripts/notification.sh" logout
        systemctl poweroff --now
        ;;
    --reboot)
        "$HOME/.config/niri/scripts/uptime.sh"
        "$HOME/.config/niri/scripts/notification.sh" logout
        systemctl reboot --now
        ;;
    --logout)
        "$HOME/.config/niri/scripts/uptime.sh"
        "$HOME/.config/niri/scripts/notification.sh" logout
        niri msg action quit --skip-confirmation
        ;;
    --suspend)
        "$HOME/.config/niri/scripts/uptime.sh"
        "$HOME/.config/niri/scripts/notification.sh" logout
        systemctl suspend --now
        ;;
esac
