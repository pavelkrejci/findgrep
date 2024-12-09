#!/bin/bash

function usage()
{
    exec 1>&2
	echo "usage:" `basename $0` "[-a|-m|-p <port>[,<port-range>]] <IP>"
	echo "     without option specified all Assistant/Manager known SSL ports are scanned"
    echo "     -a = only Assistant ports are scanned"
    echo "     -m = only Manager ports are scanned"
    echo "     -p = example of port form: -100,200-1024,T:3000-4000,U:60000-"
	exit -1
}

ASSI="443,1017,1403,1526,1527,2000,2001,2004,2011,2013,2022,2112,2221,2653,3043,3046,4444,5001,5003,5004,5005,5010,5012,5100,5200,5301,5302,5443,7001,7004,7777,7778,9000,9001,9230,9980,12345,18443"
MGR="123,443,1017,1100,1102,1401,1526,1527,2000,2001,2004,2011,2013,2022,2221,2653,3043,3046,4444,5001,5004,5005,5010,5012,5100,5200,5301,5302,5443,7001,7004,7777,7778,9000,9001"
#BOTH="123,443,1017,1100,1102,1401,1403,1526,1527,2000,2001,2004,2011,2013,2022,2112,2221,2653,3043,3046,4444,5001,5003,5004,5005,5010,5012,5100,5200,5301,5302,5443,7001,7004,7777,7778,9000,9001,9230,9980,12345,18443"

PORTS="$ASSI,$MGR"

while getopts "amp:" opt 2>/dev/null
do       
    case $opt in
        a) PORTS=$ASSI
        ;;
        m) PORTS=$MGR
        ;;
        p) PORTS=$OPTARG
        ;;
        \?) usage
        ;;
    esac
done
shift $((OPTIND -1))

[ -z "$1" ] && usage

#echo ports=$PORTS
#echo IP=$1

nmap --script ssl-enum-ciphers -p $PORTS $1

