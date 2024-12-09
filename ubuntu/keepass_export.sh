#!/bin/bash

usage()
{
	echo "$1"
	echo "Usage: `basename $0` <dbname> <entry_name> <target_dir>"
	echo "Open KeePassXC database and export all attachments from <entry_name> into <target_dir>. The attachment names must be listed in the Notes field."
	echo
	exit 1
}

[ $# -eq 0 ] && usage

# Variables
DB_PATH="$1"
ENTRY_NAME="$2"
OUTPUT_DIR="$3"

[ -r "$DB_PATH" ] || usage "Error: $DB_PATH does not exist."
[ -d "$OUTPUT_DIR" ] || usage "Error: Directory $OUTPUT_DIR does not exist."

#echo -n "Password:"
#read -s DB_PASSWORD
DB_PASSWORD="TODO"

ATTACHMENTS=$(expect -c "
spawn \"keepassxc-cli show -a \"Notes\" \"$DB_PATH\" \"$ENTRY_NAME\" &>/dev/null\"
expect \"Enter password\"
send \"$DB_PASSWORD\r\"
set output \"\"
expect {
	append output $expect_out(buffer)
}
puts \$output
exit
")

exit 0
# Loop through each attachment and export
for ATTACHMENT in $ATTACHMENTS; do
    # Extract attachment file name
    FILE_NAME=$(basename "$ATTACHMENT")
	echo $FILE_NAME

    # Download and save attachment
#    keepassxc-cli attach export "$DB_PATH" "$ENTRY_NAME" "$ATTACHMENT" > "$OUTPUT_DIR/$FILE_NAME"
done

echo "All attachments have been exported to $OUTPUT_DIR"

exit 0
