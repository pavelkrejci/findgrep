#!/bin/sh

#set -x

for i in `find . -size +100000000c -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mov' -o -iname '*.mkv' -o -iname '*.mpg'`
do
	mpv $i
	while 
		read -p "Delete/move/none $i [d/m/n]:" a
		if [ $a == "d" ]
		then
			echo Deleting $i
			rm -f $i
			break
		fi
		if [ $a == "m" ]
		then
			echo Moving $i
			mv $i /home/knoppix/suplik/UNDEL/
			break
		fi
		if [ $a == "n" ]
		then
			break
		fi
	do
		:
	done
done

#for i in recup_dir.4/f2*.mp4; do ffprobe recup_dir.4/f266043392.mp4 && echo OK || echo NOK; done
