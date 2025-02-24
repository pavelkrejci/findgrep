#!/bin/bash

#
set -x
/usr/bin/xrandr --output Virtual-1 --mode "800x600"
/usr/bin/xrandr --output Virtual-2 --mode "800x600"
sleep 1

/usr/bin/xrandr --output Virtual-1 --mode "1920x1200"
/usr/bin/xrandr --output Virtual-2 --mode "1440x2560"
xrandr --output Virtual-1 --primary --output Virtual-2 --left-of Virtual-1

