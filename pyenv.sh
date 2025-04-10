#!/bin/bash


usage() {
	BN=`basename $0`
	echo "$1"
	echo "Usage: $BN <options> [<path to python environment>]"
    echo "<options>:"
    echo "-c <env> = crate environment"
    echo "-e <env> = use environment"
	echo "The default path is $DEFPYENV"
	exit 2
}


MODE=""
DEFPYENV=.venv

while getopts "ce" opt; do
	case "$opt" in
		c)
			MODE="c"
			PYENV=$OPTARG
			;;
		e)
			MODE="e"
			PYENV=$OPTARG
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
PYENV="${1:-$DEFPYENV}"

[ -z "$MODE" ] && usage "Action must be specified."
[ -z "$PYENV" ] && usage "Error: Path to python environment must be specified."

#####################################################
# MAIN
#set -x
if [ "$MODE" == "c" ]; then
	if [ -d "$PYENV" ]; then
		echo "The directory $PYENV already exists. Do you really want to recreate it? [y/n]:"
		read a
		[ "$a" != "y" ] && exit 1
	fi
	python3 -m venv $PYENV
fi
if [ "$MODE" == "e" ]; then
	source $PYENV/bin/activate
	exec "$SHELL" -i
fi

