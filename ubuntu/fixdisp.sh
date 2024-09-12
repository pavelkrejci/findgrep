#!/bin/bash

#
set -x
/usr/bin/xrandr --output Virtual-1 --mode "800x600"
/usr/bin/xrandr --output Virtual-2 --mode "800x600"
sleep 1

/usr/bin/xrandr --output Virtual-1 --mode "1920x1200"
/usr/bin/xrandr --output Virtual-2 --mode "2560x1440"
xrandr --output Virtual-1 --primary --output Virtual-2 --right-of Virtual-1

