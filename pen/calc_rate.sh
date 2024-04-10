#!/bin/bash
#
usage() {
	BN=`basename $0`
	echo "Usage: $BN <file.cap> [<tcpdump filter>]"
	echo "calculate packet rate in the whole (filtered) file.cap"
	exit 2
}

your_capture_file="$1"
filter="$2"

if [ ! -r "$your_capture_file" ]; then
	echo "Error: File '$your_capture_file' cannot be read."
	usage
fi

start_time=$(date -d "$(tcpdump -r $your_capture_file -n -tttt $filter 2>/dev/null | head -1 | awk '{print $1,$2}')" +%s)
end_time=$(date -d "$(tcpdump -r $your_capture_file -n -tttt $filter 2>/dev/null | tail -1 | awk '{print $1,$2}')" +%s)
duration=$(echo "$end_time - $start_time" | bc)

#echo $start_time, $end_time, $duration
num=$(tcpdump -r $your_capture_file -n $filter 2>/dev/null | wc -l)
rate=$(echo "$num / $duration" | bc)
echo "Total: $num packets per $duration seconds = $rate"
