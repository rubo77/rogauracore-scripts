#!/bin/bash

# defines a set of colors, interpolates between them to create a smooth gradient
# and then changes the keyboard backlight color to match the current time
# uses https://github.com/wroberts/rogauracore

# options for the program: -h=help, -t=test
while getopts ":s:c:ht" opt; do
    case ${opt} in
        h )
            echo "Usage: $0 [-h] [-t] [-s]"
            echo "  -h: Display this help message"
            echo "  -t: Test mode, print the color and time instead of changing the keyboard color"
            echo "  -s: use the color defined for that time instead of interpolating between colors"
            echo "  -c: set the colors to interpolate between, semicolon and comma separated"
            echo "      e.g. -c \"red,255,0,0;blue,0,0,255\""
            exit 0
            ;;
        t )
            test_mode=true
            ;;
        s )
            set_time_color=$OPTARG
            ;;
        c )
            IFS=';' read -r -a custom_colors <<< "$OPTARG"
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            exit 1
            ;;
    esac
done

# Define colors
colors=(
    "red,255,20,22"
    "orange,255,165,0"
    "yellow,250,235,54"
    "white,255,255,255"
    "green,121,255,20"
    "blue,72,125,255"
    "indigo,75,54,157"
    "violet,112,54,157"
    "brown,150,75,0"
)

if [ "$custom_colors" != "" ]; then
    colors=("${custom_colors[@]}")
    echo "Colors set to: ${colors[@]}"
fi

# Function to interpolate between two colors
interpolate_color() {
    local start_color="$1"
    local end_color="$2"
    local steps="$3"

    start_color_name=$(echo "$start_color" | cut -d',' -f1)

    start_r=$(echo "$start_color" | cut -d',' -f2)
    start_g=$(echo "$start_color" | cut -d',' -f3)
    start_b=$(echo "$start_color" | cut -d',' -f4)

    end_r=$(echo "$end_color" | cut -d',' -f2)
    end_g=$(echo "$end_color" | cut -d',' -f3)
    end_b=$(echo "$end_color" | cut -d',' -f4)

    for ((i = 0; i <= steps; i++)); do
        curr_r=$(echo "scale=0; $start_r + ($end_r - $start_r) * $i / $steps" | bc)
        curr_g=$(echo "scale=0; $start_g + ($end_g - $start_g) * $i / $steps" | bc)
        curr_b=$(echo "scale=0; $start_b + ($end_b - $start_b) * $i / $steps" | bc)
        echo -n "$start_color_name,"
        printf "%02X%02X%02X\n" "$curr_r" "$curr_g" "$curr_b"
    done
}

# Interpolate colors
steps=10
interpolated_colors=()
for ((i = 0; i < ${#colors[@]} - 1; i++)); do
    interpolated_colors+=($(interpolate_color "${colors[$i]}" "${colors[$i+1]}" "$steps"))
done
# add the last color interpolated to the first color
interpolated_colors+=($(interpolate_color "${colors[${#colors[@]}-1]}" "${colors[0]}" "$steps"))

current_hour=$(date +"%H")
current_minute=$(date +"%M")
if [ "$set_time_color" != "" ]; then
    current_hour=$(echo "$set_time_color" | cut -d':' -f1)
    current_minute=$(echo "$set_time_color" | cut -d':' -f2)
fi

num_colors=${#colors[@]}
spread_factor=0.455 # this is fine adjusted to fit to spread over 24 hours
factor=$(echo "scale=5; $spread_factor * ($num_colors)" | bc)

for ((i = 0; i < ${#interpolated_colors[@]}; i++)); do
    color=$(echo "${interpolated_colors[$i]}"| cut -d',' -f2)
    start_color=$(echo "${interpolated_colors[$i]}"| cut -d',' -f1)
    hour_decimal=$(echo "scale=2; $i / $factor" | bc)
    hour=$(echo "$hour_decimal" | cut -d'.' -f1)
    if [ "$hour" = "" ]; then
        hour="00"
    elif [ "$hour" -lt 10 ]; then
        hour="0$hour"
    fi

    minute_decimal=$(echo "$hour_decimal" | cut -d'.' -f2)
    minute=$(echo "scale=0; $minute_decimal * 60 / 100" | bc)
    if [ "$minute" = "" ]; then
        minute="00"
    elif [ "$minute" -lt 10 ]; then
        minute="0$minute"
    fi

    # if the current time is before $hour:$minute, fire and exit!
    if [ "$test_mode" = true ]; then
        r_hex=$(echo "$color" | cut -c1-2)
        g_hex=$(echo "$color" | cut -c3-4)
        b_hex=$(echo "$color" | cut -c5-6)

        r=$(printf "%d" 0x$r_hex)
        g=$(printf "%d" 0x$g_hex)
        b=$(printf "%d" 0x$b_hex)
        echo -e "\033[38;2;${r};${g};${b}mColor: $start_color (#$color), Time: $hour:$minute\033[0m"
    else
        if [ "$current_hour" -lt "$hour" ] || ([ "$current_hour" -eq "$hour" ] && [ "$current_minute" -lt "$minute" ]); then
            echo "Color: #$color, Time: $hour:$minute"
            # kernel >= 6.11 gates the keyboard light through the LED class
            # (asus-nb-wmi): brightness 0 keeps it dark regardless of MCU color.
            # Relight it once per boot only: the marker lives in /run (tmpfs,
            # cleared on boot), so manual Fn-key/F2/F3 changes are not overridden
            # by later runs of this script. The optional off-flag can be set
            # by rogauracore_toggle.sh.
            kbd_led=/sys/class/leds/asus::kbd_backlight/brightness
            kbd_led_marker=/run/kbd_backlight_initialized
            if [ -w "$kbd_led" ] && [ ! -f "$kbd_led_marker" ] \
               && ! compgen -G "/run/user/*/kbd_backlight_off" > /dev/null; then
                echo 3 > "$kbd_led"
                touch "$kbd_led_marker"
            fi
            rogauracore single_static $color
            break
        fi
    fi
done
if [ "$test_mode" = true ]; then
    echo "final color: ${colors[$num_colors-1]}"
fi
