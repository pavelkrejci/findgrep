#!/bin/bash

# Usage:
#   ./img2pdf.sh -o output.pdf img1.jpg img2.png img3.jpeg ...

# Default output
output="output.pdf"

# Parse arguments
if [ "$1" == "-o" ]; then
    output="$2"
    shift 2
fi

# Check we have at least one input image
if [ $# -lt 1 ]; then
    echo "Usage: $0 -o output.pdf image1 [image2 ...]"
    exit 1
fi

# Convert images to a single PDF
convert -resample 300 "$@" "$output"

echo "Created PDF: $output"

