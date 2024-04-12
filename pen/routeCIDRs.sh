#!/bin/bash
#

usage() {
	echo $1
	BN=`basename $0`
	echo "Usage: sudo $BN -a|-d <CIDR ranges list.txt> <gatewayIP>"
	echo "-a = add routes"
	echo "-d = delete routes"
	echo "-g = gateway IP"
	echo "-i = gateway interface"
	echo "- add route for all CIDRs from file via <gatewayIP>"
	exit 2
}

############################################
# OPTIONS
############################################
if [ $EUID -ne 0 ]; then
    echo "Error: This script was not run with sudo."
	usage
fi

MODE="add"
GW="via"
while getopts "adgi" opt; do
	case "$opt" in
		a)
			MODE="add"
            ;;
		d)
			MODE="delete"
			;;
		g)
			GW="via"
			;;
		i)
			GW="dev"	
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

[ -z "$2" ] && usage
[ ! -r "$1" ] && usage "Error: Cannot read file $1"
if [ "$GW" == "via" ]; then
	ping -q -c1 $2 || usage "Error: Cannot ping gateway $2"
fi

############################################
# MAIN
############################################

#set -x
while read cidr; do
	echo "$MODE range: $cidr"
	ip route $MODE $cidr $GW $2
done < $1
#set +x

exit 0
