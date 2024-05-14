#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: sudo $BN <options> < -c <CIDR scopes file> | -f <IP addresses list file> >"
    echo "<options>:"
    echo "-n <x> = chunk size, number of IP addresses in single batch, default 10"
    echo "-T<x> = nmap agressiveness, default 4"
    echo "-r<rate> = --max-rate, default 400"
    echo "-p<port range>, default 1000 common ports, use -p- for full port range"
    echo "-a<chunk#> = continue mode, start with chunk number, not with the first one"
	exit 2
}


############################################
# OPTIONS
############################################
if [ $EUID -ne 0 ]; then
    echo "Error: This script was not run with sudo."
	usage
fi

CHUNK=10
T="-T4"
RATE="--max-rate 400"
PORTS=""
while getopts "a:c:f:n:T:r:p:" opt; do
	case "$opt" in
        a)
            AT=$OPTARG
            [[ $AT =~ ^[0-9]+$ ]] || usage "Error: -a argument '$AT' is not a number."
            ;;
		n)
            CHUNK=$OPTARG		
			;;
		T)
            T="-T$OPTARG"
            ;;
        r)
            RATE="--max-rate $OPTARG"
            ;;
        p)
            PORTS="-p$OPTARG"
            ;;
        f)
			MODE="f"
			FILE=$OPTARG
			[ ! -r "$FILE" ] && usage "Error: Cannot read file '$FILE'."
			;;
		c)
            MODE="c"
			FILE=$OPTARG
			[ ! -r "$FILE" ] && usage "Error: Cannot read file '$FILE'."
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


############################################
# MAIN
############################################
[ -z "$MODE" ] && usage

if [ "$MODE" == "c" ]; then
    rm chunk*.split
	$(dirname $0)/expandCIDR.py -f $FILE | /usr/bin/split -l $CHUNK -d -a4 --additional-suffix=.split - chunk
elif [ "$MODE" == "f" ]; then
    rm chunk*.split
    /usr/bin/split -l $CHUNK -d -a4 --additional-suffix=.split $FILE chunk
fi

for ch in chunk*.split; do 
    chw=${ch%.split}
    num="${ch//[^0-9]/}"
    #10# = interpret 0002 as decimal not octal
    if [[ -n "$AT" && 10#$AT -gt 10#$num ]]; then
        echo "Skipping $ch"
        continue
    fi
    CMD="/usr/bin/nmap $PORTS $RATE $T -n -Pn -sS -v -d3 -iL $ch -oX $chw.xml"
    echo $CMD
    $CMD >/dev/null 2>&1
    echo "Chunk $ch finished."
    mv $ch $chw.done
done

exit 0
