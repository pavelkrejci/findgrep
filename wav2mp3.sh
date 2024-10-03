#!/bin/bash

# Script to convert WAV to MP3 using ffmpeg
# Usage: ./wav2mp3.sh input.wav output.mp3 [bitrate]

# Function to display usage information
usage() {
	echo $1
	echo "Run the conversion to mp3 with enhanced speech processing"
    echo "Usage: $0 input.wav output.mp3 [bitrate]"
    echo "  input.wav: Path to the input WAV file"
    echo "  output.mp3: Path to the output MP3 file"
    echo "  bitrate: Optional MP3 bitrate (default: 192k)"
    exit 1
}

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    usage "Error: ffmpeg is not installed. Please install it using: sudo apt install ffmpeg"
fi

# Check for at least two arguments
if [ $# -lt 2 ]; then
    usage "Error: Too few arguments"
fi

# Check if the input file exists and is a WAV file
if [ ! -f "$1" ]; then
    usage "Error: Input file '$1' does not exist"
fi

# Set input and output file variables
input_file="$1"
output_file="$2"
bitrate="${3:-192k}"  # Default bitrate is 192k if not provided

# Check if the output file has .mp3 extension
if [[ ${output_file##*.} != "mp3" ]]; then
    usage "Error: Output file must have a .mp3 extension"
fi

# Run the conversion using ffmpeg
echo "Converting $input_file to $output_file with bitrate $bitrate..."
#ffmpeg -i "$input_file" -vn -ar 44100 -ac 2 -b:a "$bitrate" "$output_file"
#ffmpeg -i "$input_file" -vn -ar 44100 -ac 2 -b:a "$bitrate" -filter:a "volume=2dB" "$output_file"
#ffmpeg -i "$input_file" -vn -ar 44100 -ac 2 -b:a "$bitrate" -af "loudnorm,volume=2dB" "$output_file"
# Run the conversion with enhanced speech processing
echo "Processing $input_file for optimal speech clarity, converting to $output_file with bitrate $bitrate..."

ffmpeg -i "$input_file" \
    -vn -ar 44100 -ac 2 -b:a "$bitrate" \
    -af "loudnorm,afftdn,highpass=f=150,acompressor=threshold=-20dB:ratio=4:attack=5:release=50,equalizer=f=1000:t=q:w=1:g=3,equalizer=f=3000:t=q:w=1:g=3,volume=2dB" \
    "$output_file"



# Check if the conversion was successful
if [ $? -eq 0 ]; then
    echo "Conversion successful: $output_file created"
else
    echo "Error: Conversion failed"
    exit 1
fi

