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

### kernel LED class note

On kernel >= 6.11 ASUS laptops expose `asus::kbd_backlight` as a LED class
device (`/sys/class/leds/asus::kbd_backlight/brightness`, values 0-3, driver
`asus-nb-wmi`). If that brightness is 0 the keyboard stays dark no matter which
color rogauracore writes to the MCU - that is why the script writes `3` there
once per boot (marker file: `/run/kbd_backlight_initialized`). While an
off-flag `/run/user/<uid>/kbd_backlight_off` exists (written by
`rogauracore_toggle.sh`) that write is skipped.