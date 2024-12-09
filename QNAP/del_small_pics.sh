#!/bin/sh


MAX=70000
echo "Searching and deleting *.jpg smaller than: $MAX bytes ..."
set -x
find . -iname '*.png' -exec rm -f '{}' \;
find . -size -${MAX}c -iname '*.jpg' -exec rm -f '{}' \;

exit 0

for i in `find . -size -20000c -iname '*.jpg' -o -iname '*.png'`
do
	echo Delete small picture `ls -la $i`
	rm -f $i

#	ffprobe -loglevel quiet $i && echo $i OK || {
#		echo Delete file $i
#		rm -f $i
#	}
done

#for i in recup_dir.4/f2*.mp4; do ffprobe recup_dir.4/f266043392.mp4 && echo OK || echo NOK; done
