#!/bin/bash

usage()
{
	echo "$1"
	echo "Usage: `basename $0` <profile_name>"	
	echo "enable apparmor profile"
	echo
	exit 1
}

[ $# -eq 0 ] && usage

PROFILE="/etc/apparmor.d/$1"
[ ! -f "$PROFILE" ] && usage "Error: The file $PROFILE does not exist."

sudo rm "/etc/apparmor.d/disable/$1"
sudo apparmor_parser -a "$PROFILE" && echo "Profile loaded"

exit 0
