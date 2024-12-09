#!/bin/bash

#global functions include
. `dirname $0`/functions.sh

usage() {
    BN=`basename $0`
    echo "$1"
    echo "Usage: $BN <options> <nmap xml output file>"
    echo "- parse open sockets (port state='open')"
    echo "<options>:"
    echo "-i = live IPs only, no ports, DEFAULT"
    echo "-c = IP/port as CSV format"
    echo "-s = sort IP addresses"
    exit 2
}

############################################
# OPTIONS
############################################
MODE="i"
SORT="0"
while getopts "ics" opt; do
    case "$opt" in
        i)
            MODE="i"
            ;;
        c)
            MODE="c"
            ;;
        s)
            SORT="1"
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

FILE="$1"
[ ! -r "$FILE" ] && usage "Error: Cannot read file '$FILE'."
[ ! -x "$XMLS" ] && usage "Error: XML parser $XMLS not found."

############################################
# MAIN
############################################
if [ "$MODE" == "i" ]; then
    #echo "List of live IPs:"
    #fixXML nmaprun $FILE | $XMLS sel --recover -T -t -m "//address[../ports/port[state/@state='open']]" -v "@addr" -n
    #fixXML nmaprun $FILE | $XMLS sel --recover -T -t -m "//host[ports/port/state/@state='open']" -v "address/@addr" -n
    #both above cause memory overflow
    #this is SAX stream parser
    fixXML nmaprun $FILE | /usr/bin/python  <(cat <<EOF
import xml.sax
import sys

class MyHandler(xml.sax.ContentHandler):
    def __init__(self):
        self.in_target_element = False
        self.in_host_element = False
        self.addr = ""

    def startElement(self, name, attrs):
        if name == "host":
            self.in_host_element = True
        elif self.in_host_element and name == "state" and attrs.get("state") == "open":
            #print(attrs.get("state"))
            self.in_target_element = True
        elif self.in_host_element and name == "address":
            self.addr=attrs.get("addr")
        #print(name)

    def endElement(self, name):
        if name == "host":
            if self.in_target_element:
                print(self.addr)
            self.in_host_element = False
            self.in_target_element = False

xml.sax.parse(sys.stdin, MyHandler())
EOF
) | sortIP $SORT

elif [ "$MODE" == "c" ]; then
    #   fixXML nmaprun $FILE | $XMLS sel --recover -T -t -m "//host/address[../ports/port[state/@state='open']]" -v "@addr" -m "../ports/port[state/@state='open']" -o "," -v "@portid" -n
    #this is usable for bigger XML files >0.5GB
    fixXML nmaprun $FILE | /usr/bin/python  <(cat <<EOF
import xml.sax
import sys

class MyHandler(xml.sax.ContentHandler):
    def __init__(self):
        self.in_open = False
        self.in_host_element = False
        self.addr = ""
        self.ports = ""
        self.portid=""

    def startElement(self, name, attrs):
        if name == "host":
            self.in_host_element = True
        elif self.in_host_element and name == "port":
            self.portid=attrs.get("portid")
        elif self.in_host_element and name == "state" and attrs.get("state") == "open":
# remove this to print in format <addr:port1,port2,port3>
            print("%s,%s" % (self.addr,self.portid))
            sys.stdout.flush()
            self.ports += "," + self.portid
            self.in_open = True
        elif self.in_host_element and name == "address":
            self.addr=attrs.get("addr")
            self.ports=""
            self.portid=""

    def endElement(self, name):
        if name == "host":
# use this to print in format <addr:port1,port2,port3>
#            if self.in_open:
#                print("%s%s" % (self.addr,self.ports))
#            sys.stdout.flush()
            self.in_host_element = False
            self.in_open = False

xml.sax.parse(sys.stdin, MyHandler())
EOF
) | sortIP $SORT
fi

exit 0
