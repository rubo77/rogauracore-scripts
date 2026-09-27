#!/bin/bash

# This script decreases the brightness of the keyboard backlight by 1

# Define the path to the temporary file
temp_file="/var/tmp/rogauracore_brightness"

# Check if the temporary file exists
if [ ! -f "$temp_file" ]; then
    # Call rogauracore brightness 0 and store "0" in the temp file
    echo "0" > "$temp_file"
fi

# Read the number from the temp file
number=$(cat "$temp_file")
echo "current brightness: $number"
# decrease it by 1 and set the brightness
if [ "$number" -gt "0" ]; then
    new_number=$((number - 1))
    echo set brightness to "$new_number"
    rogauracore brightness "$new_number"
    echo "$new_number" > "$temp_file"
fi
