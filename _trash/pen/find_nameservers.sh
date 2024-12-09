#!/bin/bash

# Check for input domain
if [ $# -eq 0 ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

domain=$1

# Function to follow CNAME chain (Modified)
follow_cname() {
  cname_target=$(dig +short $1 | grep -oP '(?<=CNAME ).*' | head -1)
  if [ -n "$cname_target" ]; then
    follow_cname "$cname_target"
  else
    echo $1
  fi
}

# Get authoritative nameservers 
while true; do
  domain=$(follow_cname $domain) # Find the final domain
  echo $domain

  ns_records=$(dig NS $domain)

  # Check if any NS records found
  if [ -n "$ns_records" ]; then
    echo "Authoritative Nameservers:"
    echo "$ns_records"
    break 
  fi
done
