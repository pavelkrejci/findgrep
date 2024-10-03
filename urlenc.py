#!/usr/bin/python
import urllib.parse
import sys
import argparse

# Define argument parser
parser = argparse.ArgumentParser(description='URL encode or decode content from a file or stdin.')
parser.add_argument('filename', nargs='?', type=str, help='The file to read from (reads from stdin if missing)')
parser.add_argument('-d', '--decode', action='store_true', help='Switch to decode the input instead of encoding')

# Parse arguments
args = parser.parse_args()

# Read input from file or stdin
if args.filename:
    try:
        with open(args.filename, 'r') as file:
            input_data = file.read()
    except FileNotFoundError:
        print(f"Error: File '{args.filename}' not found.", file=sys.stderr)
        sys.exit(1)
else:
    input_data = sys.stdin.read().strip()

# Perform encoding or decoding based on the switch
if args.decode:
    result = urllib.parse.unquote(input_data)
else:
    result = urllib.parse.quote(input_data)

# Print the result
print(result)

