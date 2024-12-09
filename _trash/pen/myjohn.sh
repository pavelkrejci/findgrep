#!/bin/bash

# Default wordlist path (you can modify this path)
WORDLIST="~/SecLists/Passwords/Leaked-Databases/rockyou.txt"
WORDLIST=$(eval echo "$WORDLIST")

# Function to show usage
usage() {
  echo "Usage: $0 [-i input_file] [-t hashcat|john] [-w wordlist]"
  echo "  -i input_file : Path to the shadow file or similar file with password hashes."
  echo "  -t tool       : Choose either 'hashcat' or 'john'."
  echo "  -w wordlist   : (Optional) Path to the wordlist for cracking (default: $WORDLIST)."
  exit 1
}

# Parse command line options
while getopts ":i:t:w:" opt; do
  case $opt in
    i) INPUT_FILE="$OPTARG" ;;
    t) TOOL="$OPTARG" ;;
    w) WORDLIST="$OPTARG" ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
  esac
done

# Validate input file
if [[ -z "$INPUT_FILE" || ! -f "$INPUT_FILE" ]]; then
  echo "Error: Input file is required and must exist."
  usage
fi

# Validate tool selection
if [[ "$TOOL" != "hashcat" && "$TOOL" != "john" ]]; then
  echo "Error: You must choose either 'hashcat' or 'john' as the cracking tool."
  usage
fi

# Check if wordlist exists
if [[ ! -f "$WORDLIST" ]]; then
  echo "Error: Wordlist not found at '$WORDLIST'."
  usage
fi

# Output file paths
HASHCAT_OUTPUT="hashcat_hashes.txt"
JOHN_OUTPUT="john_hashes.txt"

# Preprocess the input file
echo "Preprocessing $INPUT_FILE for $TOOL..."

# Clear old output files if they exist
rm -f "$HASHCAT_OUTPUT" "$JOHN_OUTPUT"

# Process the file to extract hashes
grep -v '^[^:]*:[!*]:' "$INPUT_FILE" | while IFS=: read -r username hash rest; do
  # Ignore empty or disabled password hashes
  if [[ $hash == "" || $hash == "!" || $hash == "*" ]]; then
    continue
  fi

  # Output for Hashcat: hash only
  echo "$hash" >> "$HASHCAT_OUTPUT"
  
  # Output for John the Ripper: full line with username
  echo "$username:$hash" >> "$JOHN_OUTPUT"
done

# Determine which tool to run and execute the cracking
if [[ "$TOOL" == "hashcat" ]]; then
  echo "Running Hashcat..."
  HASH_TYPE=$(head -n 1 "$HASHCAT_OUTPUT" | grep -oP '\$\d+')

  case $HASH_TYPE in
    "\$6") HASH_MODE=1800 ;;  # SHA-512
    "\$5") HASH_MODE=7400 ;;  # SHA-256
    "\$1") HASH_MODE=500 ;;   # MD5
    *) echo "Unknown hash type: $HASH_TYPE. Aborting."; exit 1 ;;
  esac

  # Run hashcat with the extracted hashes and wordlist
  hashcat -m "$HASH_MODE" -a 0 "$HASHCAT_OUTPUT" "$WORDLIST"

elif [[ "$TOOL" == "john" ]]; then
  echo "Running John the Ripper..."
  # Run John with the wordlist and prepared hashes
  john --wordlist="$WORDLIST" "$JOHN_OUTPUT"
fi

echo "Cracking process finished. You can check cracked passwords with the following command:"
if [[ "$TOOL" == "hashcat" ]]; then
  echo "  hashcat --show $HASHCAT_OUTPUT"
elif [[ "$TOOL" == "john" ]]; then
  echo "  john --show $JOHN_OUTPUT"
fi

