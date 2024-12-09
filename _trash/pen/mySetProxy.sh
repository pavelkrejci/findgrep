#!/bin/bash
#

usage() {
	echo $1
	BN=`basename $0`
	echo "Usage: $BN <proxy>"
	echo "e.g. <proxy> = http://127.0.0.1:8081"
	echo "by default use http://127.0.0.1:8080"
	echo "example: mysslscan.sh -n efp.rb.cz 90.182.101.1:443"
	exit 2
}

if [ -z "$1" ]; then
	P="http://127.0.0.1:8080"
else
	P="$1"
fi

export http_proxy="$P"
export https_proxy="$P"
export ftp_proxy="$P"

set | grep "proxy="

