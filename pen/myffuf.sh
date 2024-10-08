#!/bin/bash

# Define usage function
usage() {
	BN=`basename $0`
    echo "Usage: $BN [-e|--etchosts] [-s|--subdomains] [-v|--vhosts] [-e|--extensions] [-d|--dirs] [-f|--files] [-p|--params] [-a|--all] [-fs <size>] [-mc <code>] [-b <cookies>] <IP:PORT> <URL>"
    exit 2
}

#set URL to /etc/hosts, only for private URLs
entry_etc_hosts() {
	#set -x
	sudo sh -c "sed -i \"/.*$1/d\" /etc/hosts; echo \"$2 $1\" >>/etc/hosts"
}

#2 fuzz for subdomains
fuzz_subdomains() {
	#ffuf -ic -w ~/SecLists/Discovery/DNS/subdomains-top1million-20000.txt:FUZZ -u http://$IP:$PORT/ -H "Host: FUZZ.$URL" -mc all $FILTER
	ffuf -ic -w ~/SecLists/Discovery/DNS/subdomains-top1million-20000.txt:FUZZ -u http://$IP:$PORT/ -H "Host: FUZZ.$URL" $FILTER
#	gobuster vhost -w ~/SecLists/Discovery/DNS/subdomains-top1million-20000.txt -u $URL --append-domain

}

#3 fuzz for vhosts
fuzz_vhosts() {
	ffuf -ic -w ~/SecLists/Discovery/DNS/subdomains-top1million-20000.txt:FUZZ -u http://$IP:$PORT/ -H "Host: FUZZ.$URL" $FILTER
}

fuzz_extensions() {
	#4 subdomains/vhosts found, fuzz for extensions
	for subdomain in "" test. archive. faculty.; do
		echo $subdomain
		#add subdomain into /etc/hosts, only for private URLs
		sudo sh -c "sed -i \"/.*$subdomain$URL/d\" /etc/hosts; echo \"$IP $subdomain$URL\" >>/etc/hosts"
		ffuf -ic -w ~/SecLists/Discovery/Web-Content/web-extensions.txt -u http://$subdomain$URL:$PORT/indexFUZZ
	done
}

fuzz_dirs() {
	#5 page fuzzing scan
	EXTENSIONS=.php,.php7,.phps
	for subdomain in test. archive. faculty.; do
		set -x
		ffuf -ic -w ~/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt:FUZZ -u http://$subdomain$URL:$PORT/FUZZ http://test.academy.htb:$PORT/FUZZ -recursion -recursion-depth 1 -e $EXTENSIONS -v -mc 200
		#ffuf -ic -w ~/SecLists/Discovery/Web-Content/dsstorewordlist.txt:FUZZ -u http://$subdomain$URL:$PORT/FUZZ -recursion -recursion-depth 1 -e $EXTENSIONS -v -mc 200
		set +x
	done
}

fuzz_params() {
	#longer
	WORDLIST=~/SecLists/Discovery/Web-Content/raft-large-words-lowercase.txt
	#shorter
	#WORDLIST=~/SecLists/Discovery/Web-Content/burp-parameter-names.txt
	set -x
	ffuf -w $WORDLIST:FUZZ -u http://$IP:$PORT/$URL?FUZZ=key $FILTER
	set +x
	#TODO
#	ffuf -w $WORDLIST:FUZZ -u http://$IP:$PORT/$URL -X POST -d 'FUZZ=key' -H 'Content-Type: application/x-www-form-urlencoded' $FILTER
}

fuzz_files() {
	#longer
	WORDLIST=~/SecLists/Discovery/Web-Content/raft-large-files-lowercase.txt
	#shorter
	#WORDLIST=~/SecLists/Discovery/Web-Content/raft-small-files-lowercase.txt
	ffuf -w $WORDLIST:FUZZ -u http://$IP:$PORT/$URL/FUZZ $FILTER
#	ffuf -w $WORDLIST:FUZZ -u http://$IP:$PORT/$URL -X POST -d 'FUZZ=key' -H 'Content-Type: application/x-www-form-urlencoded' $FILTER
}


#####################################
# main
#####################################


# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -e|--etchosts)
            ETCHOSTS=true
            shift
            ;;
        -v|--vhosts)
            VHOSTS=true
            shift
            ;;
        -s|--subdomains)
            SUBDOMAINS=true
            shift
            ;;
        -e|--extensions)
            EXTENSIONS=true
            shift
            ;;
        -d|--dirs)
            DIRS=true
            shift
            ;;
        -f|--files)
            FILES=true
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
		-fs)
			FILTER="-fs $2 $FILTER"
			shift 2
			;;
		-b)
			FILTER="-b $2 $FILTER"
			shift 2
			;;
		-mc)
			FILTER="-mc $2 $FILTER"
			shift 2
			;;
        *)
            # Handle IP:PORT parameters
            if [[ -z $IP ]]; then
                IP="$(echo $1 | cut -d':' -f1)"
                PORT="$(echo $1 | cut -d':' -f2)"
			elif [[ -z $URL ]]; then
				URL="$1"
            else
                echo "Unexpected argument: $1"
                usage
            fi
            shift
            ;;
    esac
done

# Check if IP:PORT parameters are provided
if [[ -z "$IP" || -z "$PORT" || -z "$URL" ]]; then
    echo "Error: IP:PORT and URL are required."
    usage
fi

# Display IP:PORT parameters
echo "IP:$IP PORT:$PORT URL:$URL"

if [[ $ETCHOSTS ]]; then
    echo "Set entry to /etc/hosts: $IP $URL"
	entry_etc_hosts $URL $IP
fi

if [[ $SUBDOMAINS ]]; then
    echo "Subdomains option selected."
	fuzz_subdomains
fi

# Perform actions based on options
if [[ $VHOSTS ]]; then
    echo "Vhosts option selected."
	fuzz_vhosts
fi


if [[ $EXTENSIONS ]]; then
    echo "Extensions option selected."
	fuzz_extensions
fi

if [[ $DIRS ]]; then
    echo "Directories option selected."
	fuzz_dirs
fi

if [[ $FILES ]]; then
    echo "Files option selected."
	fuzz_files
fi

if [[ $PARAMS ]]; then
    echo "Parameters option selected."
	fuzz_params
fi

if [[ $ALL ]]; then
    echo "All option selected."
	fuzz_subdomains
	fuzz_vhosts
	fuzz_extensions
	fuzz_dirs
	fuzz_params
fi


exit 0

