# README.md

## keyboard_backlight_daytime.sh

This script defines a set of colors, interpolates between them to create a smooth gradient, and then changes the keyboard backlight color to match the current time. It uses the [rogauracore](https://github.com/wroberts/rogauracore) library.

### Usage

```shell
./keyboard_backlight_daytime.sh [-h] [-t] [-s] [-c]
```

## rogauracore_brightness_minus.sh

decreases the brightness of the keyboard backlight by 1

## rogauracore_brightness_plus.sh

increases the brightness of the keyboard backlight by 1

#### Options

- `-h`: Display the help message
- `-t`: Test mode, print the color and time instead of changing the keyboard color
- `-s`: Use the color defined for that time instead of interpolating between colors
- `-c`: Set the colors to interpolate between, semicolon and comma separated. For example: `-c "red,255,0,0;blue,0,0,255"`

### Installation

1. Clone the repository
2. Navigate to the directory containing `keyboard_backlight_daytime.sh`
3. add a symlink in /usr/local/sbin:

```
cd /usr/local/sbin
ln -s /path/to/keyboard_backlight_daytime.sh .
```