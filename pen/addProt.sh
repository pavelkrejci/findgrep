#!/bin/bash
#

usage() {
	echo $1
	BN=`basename $0`
	echo "Usage: $BN -b <IP socket list.txt>"
	echo "- adds protocol to each line (format IP:port) based on port number:"
	echo "-  80 = http://"
	echo "- 443 = https://"
	echo "-   * = https://"
	echo "-b = both http and https for unknown ports"
	exit 2
}

while getopts "b" opt; do
	case "$opt" in
		b)
			MODE="b"
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

[ ! -r "$1" ] && usage "Error: Cannot read file $1"

#sed -e "s~\(^.*:80\)~http://\1~" -e "s~\(^.*:443\)~https://\1~" -e "/:\(80\|443\)/!s/^/prefix/" $1
sed -n -e "/:80$/s/^/http:\/\//p" -e "/:443$/s/^/https:\/\//p" -e "/:\(80\|443\)/!s/^/https:\/\//p" $1
exit 0

grep ":80" $1 | sed -e "s~^~http://~"
grep ":443" $1 | sed -e "s~^~https://~"
[ "$MODE" == "b" ] && grep -E -v ":80|:443" $1 | sed -e "s~^~http://~"
grep -E -v ":80|:443" $1 | sed -e "s~^~https://~"
