#!/bin/bash

# Define usage function
usage() {
	BN=`basename $0`
    echo "Usage: $BN [-d|-h] [-x extensions] <URL>"
	echo "-d = fuzz directories"
	echo "-h = fuzz vhosts"
    exit 2
}

fuzz_dirs() {
	gobuster dir --wordlist ~/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt --url $URL $FILTER
}

fuzz_vhosts() {
	gobuster dns --wordlist ~/SecLists/Discovery/DNS/subdomains-top1million-110000.txt -d $URL $FILTER
}



#####################################
# main
#####################################

while getopts "dhx:" opt; do
	case "$opt" in
		d)
            DIRS=true
            ;;
		h)
            VHOSTS=true
            ;;
		x)
			FILTER="-x $OPTARG $FILTER"
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
URL="$1"

# Check if URL
if [ -z "$URL" ]; then
    echo "Error: URL is required."
    usage
fi

if [ $DIRS ]; then
    echo "Directories option selected."
	set -x
	fuzz_dirs
	set +x
elif [ $VHOSTS ]; then
    echo "Vhosts option selected."
	set -x
	fuzz_vhosts
	set +x
fi


echo "No more options selected."

exit 0

