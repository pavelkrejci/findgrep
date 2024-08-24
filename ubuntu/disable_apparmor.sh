#!/bin/bash

usage()
{
	echo "$1"
	echo "Usage: `basename $0` <profile_name>"	
	echo "disable apparmor profile"
	echo
	exit 1
}

[ $# -eq 0 ] && usage

PROFILE="/etc/apparmor.d/$1"
[ ! -f "$PROFILE" ] && usage "Error: The file $PROFILE does not exist."

cd /etc/apparmor.d/disable
sudo ln -s "$PROFILE" 
sudo apparmor_parser -R "$PROFILE"

exit 0
