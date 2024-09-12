#!/bin/bash
#
#

while getopts "y" opt; do
	case "$opt" in
		y)
			MODE=y
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

if [ "$MODE" != "y" ]; then
	systemctl --user status -l --no-pager plasma-plasmashell.service

	if pgrep plasmashell; then
		echo -n "The shell is still running. Do you really want to restart the service plasma-plasmashell.service? [y/n]:"
		read a
		[ "$a" != "y" ] && exit 2
	fi
fi

echo go to restart ...

systemctl --user restart plasma-plasmashell.service

exit 0


#set -x
#kquitapp5 plasmashell
#plasmashell --replace &>/dev/null &

#/usr/bin/startplasma-x11
