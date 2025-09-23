#!/bin/bash

FILE=`mktemp -p /tmp snip.sh.XXXXXXXX.png`
#/usr/bin/maim -f png -s | /usr/bin/xclip -selection clipboard -t image/png
/usr/bin/maim -f png -s $FILE && spectacle -E $FILE

rm -f $FILE
