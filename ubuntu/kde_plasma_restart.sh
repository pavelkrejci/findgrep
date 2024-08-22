#!/bin/bash
#
#
systemctl --user status -l --no-pager plasma-plasmashell.service

if pgrep plasmashell; then
	echo -n "The shell is still running. Do you really want to restart the service plasma-plasmashell.service? [y/n]:"
	read a
	[ "$a" != "y" ] && exit 2
fi

echo go to restart ...

systemctl --user restart plasma-plasmashell.service

exit 0


#set -x
#kquitapp5 plasmashell
#plasmashell --replace &>/dev/null &

#/usr/bin/startplasma-x11
