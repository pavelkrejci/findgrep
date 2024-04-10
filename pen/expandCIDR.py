#!/usr/bin/python

import sys
import ipaddress

def cidr_to_ip_list(cidr_range):
    ip_list = []
    network = ipaddress.ip_network(cidr_range)
    for ip in network:
        ip_list.append(str(ip))
    return ip_list

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py CIDR_RANGE")
        sys.exit(1)

    cidr_range = sys.argv[1]
    ip_list = cidr_to_ip_list(cidr_range)
    for ip in ip_list:
        print(ip)

