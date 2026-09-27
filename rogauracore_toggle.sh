#!/bin/bash

# This script toggles the keyboard backlight off/on via the kernel LED
# interface (UPower D-Bus). Bind it to a hotkey of your choice, e.g. via
# xbindkeys.

# The flag makes a manual "off" survive repeated scheduled runs of
# keyboard_backlight_daytime.sh. /run/user/$UID is a per-boot tmpfs,
# so the flag is cleared on boot and the next scheduled run relights
# the keyboard after a fresh start.
FLAG="/run/user/$UID/kbd_backlight_off"

KBD_DBUS="--system --dest org.freedesktop.UPower --object-path /org/freedesktop/UPower/KbdBacklight --method"
current=$(gdbus call $KBD_DBUS org.freedesktop.UPower.KbdBacklight.GetBrightness | tr -d '(),')
max=$(gdbus call $KBD_DBUS org.freedesktop.UPower.KbdBacklight.GetMaxBrightness | tr -d '(),')

if [ "$current" -gt 0 ]; then
    gdbus call $KBD_DBUS org.freedesktop.UPower.KbdBacklight.SetBrightness 0
    touch "$FLAG"
else
    gdbus call $KBD_DBUS org.freedesktop.UPower.KbdBacklight.SetBrightness "$max"
    rm -f "$FLAG"
fi
