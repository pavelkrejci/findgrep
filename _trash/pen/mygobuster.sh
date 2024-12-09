#!/bin/bash

# Define usage function
usage() {
	BN=`basename $0`
    echo "Usage: $BN [-d|-h] <options> <URL>"
	echo "-d = fuzz directories"
	echo "-h = fuzz vhosts"
	echo "Options:"
	echo "-x <extensions> like php,html"
	echo "-c <cookies> like PHPSESSID=xxxxxxxxxxxxxxxx"
	echo "-b <Negative Status codes> like 403,404"
    exit 2
}

fuzz_dirs() {
	set -x
	gobuster dir -t 50 --wordlist ~/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt --url $URL $FILTER
	set +x
}

fuzz_vhosts() {
	set -x
	gobuster dns -t 50 --wordlist ~/SecLists/Discovery/DNS/subdomains-top1million-110000.txt -d $URL $FILTER
	set +x
}



#####################################
# main
#####################################

while getopts "dhx:c:b:" opt; do
	case "$opt" in
		d)
            DIRS=true
            ;;
		h)
            VHOSTS=true
            ;;
		c)
			FILTER="-c $OPTARG $FILTER"
			;;
		x)
			FILTER="-x $OPTARG $FILTER"
            ;;
		b)
			FILTER="-b $OPTARG $FILTER"
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
	fuzz_dirs
elif [ $VHOSTS ]; then
    echo "Vhosts option selected."
	fuzz_vhosts
fi


echo "No more options selected."

exit 0

