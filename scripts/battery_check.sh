#!/bin/bash

while true; do
    bat_status=$(cat /sys/class/power_supply/BAT0/status)
    bat_level=$(cat /sys/class/power_supply/BAT0/capacity)

    if [ "$bat_status" = "Discharging" ]; then
        if [ "$bat_level" -le 10 ]; then
            notify-send -u critical "BATTERY CRITICAL: $bat_level%" "Connect charger immediately."
        elif [ "$bat_level" -le 20 ]; then
            notify-send -u critical "BATTERY LOW: $bat_level%" "Plug in your charger."
        fi
    fi
    sleep 60
done
