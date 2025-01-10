#!/bin/bash

#
set -x
#/usr/bin/xrandr --output Virtual-1 --mode "800x600"
#/usr/bin/xrandr --output Virtual-2 --mode "800x600"
#sleep 1
xrandr -q

/usr/bin/xrandr --output Virtual-1 --mode "1920x1080"
/usr/bin/xrandr --output Virtual-2 --mode "1920x1080"
xrandr --output Virtual-1 --primary --output Virtual-2 --right-of Virtual-1

exit 0
#nebo, kdyz ukazuje pouze nizke rozliseni, tak pridat rucne Full HD
#pavel@t16:~$ cvt 1920 1080 60
# 1920x1080 59.96 Hz (CVT 2.07M9) hsync: 67.16 kHz; pclk: 173.00 MHz
#Modeline "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
xrandr --newmode "1920x1080_60.00" 173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
xrandr --addmode DP-3-2 "1920x1080_60.00"
xrandr --output DP-3-2 --mode "1920x1080_60.00"
