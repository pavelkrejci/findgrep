#!/bin/bash

# Script to cut an audio file to a specified length using ffmpeg
# Usage: ./mp3cut.sh input_file final_length output_file

# Function to display usage information
usage() {
    echo "Usage: $0 input_file final_length output_file"
    echo "  input_file: Path to the input audio file"
    echo "  final_length: Desired length of the output file in seconds"
    echo "  output_file: Path to the output audio file"
    exit 1
}

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it using: sudo apt install ffmpeg"
    exit 1
fi

# Check for exactly three arguments
if [ $# -ne 3 ]; then
    usage
fi

# Set input, final length, and output file variables
input_file="$1"
final_length="$2"
output_file="$3"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' does not exist"
    exit 1
fi

# Check if the input and output formats are the same
input_extension="${input_file##*.}"
output_extension="${output_file##*.}"
if [ "$input_extension" != "$output_extension" ]; then
    echo "Error: Input and output file formats must be the same"
    exit 1
fi

# Run the ffmpeg command to cut the audio file
ffmpeg -ss 0 -t "$final_length" -i "$input_file" -c copy "$output_file"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Successfully trimmed the audio file to $final_length seconds: $output_file created"
else
    echo "Failed to trim the audio file"
fi