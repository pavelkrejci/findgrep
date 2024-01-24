#!/bin/bash

usage() {
	bn=`basename $0`
	echo "Usage:"
	echo "$bn <file.csr> <file.crt>"
	exit 2
}

if [ -z "$2" ]; then
	usage
fi
openssl ca -config ~/CA/ca.conf -key pom.uscat -create_serial -cert ~/CA/CA-RSA2048-Krejci.pem -keyfile ~/CA/CA-RSA2048-Krejci.key -in $1 -out $2
