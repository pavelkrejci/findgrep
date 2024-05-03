#!/usr/bin/python

import sys
import ipaddress
import argparse

def cidr_to_ip_list(cidr_range):
    ip_list = []
    network = ipaddress.ip_network(cidr_range)
    for ip in network:
        ip_list.append(str(ip))
    return ip_list

def read_cidr_from_file(filename):
    with open(filename, 'r') as file:
        return [line.strip() for line in file]

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file", help="File containing CIDR ranges")
    parser.add_argument("cidr_range", nargs='?', default=None, help="CIDR range")
    args = parser.parse_args()

    if args.file:
        cidr_ranges = read_cidr_from_file(args.file)
        for cidr_range in cidr_ranges:
            ip_list = cidr_to_ip_list(cidr_range)
            for ip in ip_list:
                print(ip)
    elif args.cidr_range:
        ip_list = cidr_to_ip_list(args.cidr_range)
        for ip in ip_list:
            print(ip)
    else:
        print("Usage: python script.py [-f <filename>] [CIDR_RANGE]")
        sys.exit(1)
