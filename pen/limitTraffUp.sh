#!/bin/bash
# Delete all tc qdisc rules

MYPATH=`dirname $0`
usage() {
	BN=`basename $0`
	echo "Usage: sudo $0 <command> <interface> <rate p/s> <avg packet size> <IP list file>"
	echo "<command> = set, clear, list"
	echo "BEWARE: sudo needed !!!!"
	exit 2
}


if [ $EUID -ne 0 ]; then
    echo "Error: This script was not run with sudo."
	usage
fi

############################################################################
## MAIN
############################################################################
cmd="$1"
interface="$2"
IPlist="$5"

if [ "$cmd" == "clear" -o "$cmd" == "list" ]; then
	[ -z "$interface" ] && usage
elif [ "$cmd" == "set" ]; then
	[ -z "$5" ] && usage
else
	usage
fi

echo "_______________________ CURRENT STATE _________________________"
tc qdisc show dev $interface
tc class show dev $interface
tc filter show dev $interface
[ "$cmd" == "list" ] && exit 0

echo "Deleting qdisc rules for interface $interface"
tc qdisc del dev "$interface" root

echo "_______________________ CLEARED STATE _________________________"
tc qdisc show dev $interface
tc class show dev $interface
tc filter show dev $interface

[ "$cmd" == "clear" ] && exit 0

echo "_______________________ CONFIGURE ______________________"
#HZ jiffy
HZ=`getconf CLK_TCK`
# Maximum rate in packets per second
max_packet_rate="$3"
# Average packet size in bytes
average_packet_size="$4"
# Calculate the maximum rate in bits per second
max_rate=$(( max_packet_rate * average_packet_size * 8 ))
# Calculate the burst size in bytes
burst_size=$(( max_rate / 8 / HZ ))
#this is minimal value which works - to match big size packets on MTU edge
[ $burst_size -lt 1600 ] && burst_size=1600
# Latency in milliseconds
latency=$(( 1000 / max_packet_rate * 2 ))

echo "TBF queuing discipline will be set on interface $network_interface with the following parameters:"
echo "  - Packet rate: $max_packet_rate p/s"
echo "  - Average packet size: $average_packet_size bytes"
echo "  - Rate: $max_rate bits/second"
echo "  - HZ: $HZ hertz"
echo "  - Burst: $burst_size bytes"
echo "  - Latency: $latency ms"

set -x
# Step 1: Root qdisc is prio with 3 bands
tc qdisc add dev "$interface" root handle 1: prio bands 3

# Step 2: Create a class under the root qdisc
#tc class add dev "$interface" parent 1: classid 1:1 htb rate 100Mbit

# Step 4: Add a TBF qdisc to the TBF class
#tc qdisc add dev "$interface" parent 1:1 tbf rate ${rate}mbit burst ${rate}mbit latency 50ms peakrate ${rate}mbit minburst 1540
# Set the TBF queuing discipline with calculated parameters
tc qdisc add dev "$interface" parent 1:1 handle 2: tbf rate ${max_rate}bps burst ${burst_size} latency ${latency}ms
#tc qdisc add dev "$interface" parent 1:1 tbf rate ${rate}mbit burst 10kb latency 50ms peakrate ${rate}mbit minburst 1540
#example: tc qdisc add dev $interface parent 1:1 tbf rate ${rate}mbit burst 5kb latency 70ms peakrate ${rate}mbit minburst 1540
#
# Attach pfifo queuing discipline to the class within tbf for basic FIFO queuing
tc qdisc add dev "$interface" parent 2:1 pfifo limit $max_packet_rate
set +x

while read cidr; do
	echo add range: $cidr
	# Step 5: Add a filter to the class
	tc filter add dev "$interface" protocol ip parent 1: prio 1 u32 match ip dst $cidr flowid 2:1
#	while read target_ip; do
#		echo addr: $target_ip
#	done < <($MYPATH/expandCIDR.py $cidr)
done <$IPlist

echo "_______________________ FINAL _________________________"
tc qdisc show dev $interface
tc class show dev $interface
tc filter show dev $interface

exit 0

