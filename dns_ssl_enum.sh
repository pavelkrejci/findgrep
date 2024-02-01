#!/bin/bash
#
#
#from https://academy.hackthebox.com/module/144/section/1252

usage() {
	BN=`basename $0`
	echo "Usage: $BN <domain name>"
	echo "active subdomain enumeration from SSL certificate"
	exit 2
}

[ -z "$1" ] && usage
TARGET="$1"

TARGET="$1"
PORT=443

openssl s_client -ign_eof 2>/dev/null <<<$'HEAD / HTTP/1.0\r\n\r' -connect "${TARGET}:${PORT}" | openssl x509 -noout -text | grep 'DNS' | sed -e 's|DNS:|\n|g' -e 's|^\*.*||g' | tr -d ',' | sort -u
