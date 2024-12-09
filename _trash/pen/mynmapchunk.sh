#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: sudo $BN <options> < -c <CIDR scopes file> | -f <IP addresses list file> >"
    echo "<options>:"
    echo "-U = UDP mode"
    echo "-n <x> = chunk size, number of IP addresses in single batch, default 10"
    echo "-T<x> = nmap agressiveness, default 4"
    echo "-R<x> = max-rtt-timeout in ms"
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
#40ms was used for full TCP port scan, together with T4
#RTT="--max-rtt-timeout=40ms"
RTT="--max-rtt-timeout=100ms"
RATE="--max-rate 200"
PORTS=""
while getopts "Ua:c:f:n:T:R:r:p:" opt; do
	case "$opt" in
        U)
            UDP=1
            PORTS="-p53,67,68,69,123,137,138,139,161,162,443,500,514,520,1194,1900,4500,5060,5061"
            ;;
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
		R)
            RTT="--max-rtt-timeout=${OPTARG}ms"
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
    if [ -z "$UDP" ]; then
        CMD="/usr/bin/nmap -n -Pn -sS --disable-arp-ping --reason $PORTS $RATE $T $RTT -v -d3 -iL $ch -oX $chw.xml"
    else
        CMD="/usr/bin/nmap -n -Pn -sU --disable-arp-ping --reason $PORTS $RATE $T $RTT -v -d3 -iL $ch -oX $chw.xml"
    fi
    echo $CMD
    $CMD >/dev/null 2>&1
    echo "Chunk $ch finished."
    mv $ch $chw.done
done

exit 0
