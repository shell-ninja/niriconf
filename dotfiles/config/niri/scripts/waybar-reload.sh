#!/bin/bash


case "$1" in
    --reload)
        killall waybar
        waybar &
        sleep 0.3
        ;;
    --toggle)
        killall waybar || waybar &
        sleep 0.5
        ;;
esac

