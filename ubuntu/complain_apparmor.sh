#!/bin/bash

usage()
{
	echo "$1"
	echo "Usage: `basename $0` -0|-1"
	echo "switch all apparmor profiles into complain mode"
	echo
	exit 1
}

while getopts "01" opt; do
	case "$opt" in
		0)
			MODE=0
            ;;
		1)
			MODE=1
			;;
        \?)
            echo "Error: Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Error: Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

/var/lib/snapd/apparmor/profiles

PROFILE="/etc/apparmor.d/$1"
[ ! -f "$PROFILE" ] && usage "Error: The file $PROFILE does not exist."

cd /etc/apparmor.d/disable
sudo ln -s "$PROFILE" 
sudo apparmor_parser -R "$PROFILE"

exit 0
