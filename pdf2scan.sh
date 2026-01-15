#!/bin/bash
#

INPUT="$1"
OUTPUT="$2"

if [ ! -f "$INPUT" ]; then
	echo "File $INPUT does not exist."	
	exit 2
fi
if [ -z "$OUTPUT" ]; then
	echo "Output file must be specified."
	exit 2
fi

pdftoppm -r 200 -png "$INPUT" page
for f in page-*.png; do
  convert "$f" -blur 0x0.6 -noise 1 -attenuate 0.15 -quality 60 "${f%.png}.jpg"
done
img2pdf page-*.jpg -o "$OUTPUT"

