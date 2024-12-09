#!/bin/sh

#set -x

while true 
do
	echo "Find bad video files ..."
	for i in `find . -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mov' -o -iname '*.mkv' -o -iname '*.mpg'`
	do
		ffprobe -loglevel quiet $i && echo $i OK || {
			echo Delete file $i
			rm -f $i
		}
	done
	echo "Sleeping 5 minutes ..."
	sleep 300
done

#for i in recup_dir.4/f2*.mp4; do ffprobe recup_dir.4/f266043392.mp4 && echo OK || echo NOK; done
