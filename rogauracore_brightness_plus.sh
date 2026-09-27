#!/bin/bash

# This script increases the brightness of the keyboard backlight by 1

# Define the path to the temporary file
temp_file="/var/tmp/rogauracore_brightness"

# Check if the temporary file exists
if [ ! -f "$temp_file" ]; then
    # Call rogauracore brightness 3 and store "3" in the temp file
    echo 3 > "$temp_file"
fi

# Read the number from the temp file
number=$(cat "$temp_file")
echo "current brightness: $number"
# If the number is smaller than 3, increase it by 1 and set the brightness
if [ "$number" -lt "3" ]; then
    new_number=$((number + 1))
    echo set brightness to "$new_number"
    rogauracore brightness "$new_number"
    echo "$new_number" > "$temp_file"

fi
