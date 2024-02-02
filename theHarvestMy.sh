#!/bin/bash
#
usage() {
	BN=`basename $0`
	echo "Usage: $BN <domain name>"
	echo "theHarvester enumeration from pre-selected sources"
	exit 2
}

[ -z "$1" ] && usage
TARGET="$1"

while read source; do 
	theHarvester -d "${TARGET}" -b $source -f "${source}_${TARGET}"
done <<EOF
baidu
bufferoverun
crtsh
hackertarget
otx
projectdiscovery
rapiddns
sublist3r
threatcrowd
trello
urlscan
vhost
virustotal
zoomeye
EOF

cat *.json | jq -r '.hosts[]' 2>/dev/null | cut -d':' -f 1 | sort -u > "${TARGET}_theHarvester.txt"
