#!/usr/bin/env bash

## Copyright (C) 2020-2023 Aditya Shakya <adi1090x@gmail.com>

DIR="$HOME/.config/i3"
rofi_command="rofi -theme $DIR/rofi/themes/powermenu.rasi"
uptime=$(uptime -p | sed -e 's/up //g')

# Options
shutdown=""
reboot=""
lock=""
suspend=""
logout=""

# Get user confirmation 
get_confirmation() {
	rofi -dmenu -i
}

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

chosen="$(echo -e "$options" | $rofi_command -p "UP - $uptime" -dmenu -selected-row 2)"
case $chosen in
    $shutdown)
		systemctl poweroff
        ;;
    $reboot)
		systemctl reboot
        ;;
    $lock)
        i3lock -c 000000
        ;;
    $suspend)
		systemctl suspend
        ;;
    $logout)
		i3-msg exit
        ;;
esac
