#!/bin/bash

# Define usage function
usage() {
	BN=`basename $0`
    echo "Usage: $BN [-d|--dir] [-x extensions] <URL>"
    exit 2
}

fuzz_dirs() {
	gobuster dir --wordlist ~/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt --url $URL $FILTER
}


#####################################
# main
#####################################


# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -d|--dir)
            DIRS=true
            shift
            ;;
        -p|--params)
            PARAMS=true
            shift
            ;;
        -a|--all)
            ALL=true
            shift
            ;;
		-x)
			FILTER="-x $2 $FILTER"
			shift 2
			;;
		-fs)
			FILTER="-fs $2 $FILTER"
			shift 2
			;;
		-mc)
			FILTER="-mc $2 $FILTER"
			shift 2
			;;
        *)
			if [[ -z $URL ]]; then
				URL="$1"
            else
                echo "Unexpected argument: $1"
                usage
            fi
            shift
            ;;
    esac
done

# Check if URL
if [[ -z "$URL" ]]; then
    echo "Error: URL is required."
    usage
fi

if [[ $DIRS ]]; then
    echo "Directories option selected."
	fuzz_dirs
fi

echo "No more options selected."

exit 0

