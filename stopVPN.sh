#!/bin/bash
#
#sudo openvpn --config ~/HTB-academy-regular.ovpn
#
LIST=`pgrep -alf vpn`
NUM=`echo "$LIST" | wc -l`

while [ $NUM -gt 1 ] ; do
	echo "$LIST" | grep -v "/usr/bin/sudo"
	echo -n "Type PID to kill [Ctrl-D to exit]: "
	if read pid; then
		sudo kill $pid
	else
		exit 0
	fi
	LIST=`pgrep -alf vpn`
	NUM=`echo "$LIST" | wc -l`
done

echo "No more VPNs found."
