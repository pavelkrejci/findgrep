#!/usr/bin/env bash
# Install a given certificate into Kubuntu/Ubuntu trusted store

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <certificate-file>"
    exit 1
fi

CERT_FILE="$1"

if [ ! -f "$CERT_FILE" ]; then
    echo "Error: file '$CERT_FILE' not found."
    exit 1
fi

# Ensure the file has .crt extension (required by update-ca-certificates)
BASENAME=$(basename "$CERT_FILE")
if [[ "$BASENAME" != *.crt ]]; then
    echo "Note: renaming '$CERT_FILE' to '$CERT_FILE.crt'"
    cp "$CERT_FILE" "${CERT_FILE}.crt"
    CERT_FILE="${CERT_FILE}.crt"
fi

sudo cp "$CERT_FILE" /usr/local/share/ca-certificates/
echo "Updating system certificate store..."
sudo update-ca-certificates

echo "✅ Certificate installed. Restart your browser to apply."

