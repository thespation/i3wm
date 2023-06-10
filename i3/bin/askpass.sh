#!/usr/bin/env bash

## Copyright (C) 2020-2023 Aditya Shakya <adi1090x@gmail.com>

rofi -dmenu \
     -password \
     -i \
     -no-fixed-num-lines \
     -p "Senha de root: " \
     -theme ~/.config/i3/rofi/themes/askpass.rasi &
