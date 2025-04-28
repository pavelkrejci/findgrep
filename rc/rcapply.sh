#!/bin/bash

# Validate input parameters
if [ -z "$3" ]; then
    echo "Usage: `basename $0` <public.pem> <username> <target_home_dir>"
    echo "Examp: `basename $0` public-PavelKrejci-20240326.pem pkrejci /home/pkrejci"
    exit 1
fi

PUBLIC_KEY="$1"
USERNAME="$2"
TARGET_HOME="$3"

# Verify running as correct user
if [ "$USER" != "$USERNAME" ]; then
    echo "Error: Script must be run as user $USERNAME"
    exit 1
fi

# Verify home directory
if [ ! -d "$TARGET_HOME" ]; then
    echo "Error: Target home directory $TARGET_HOME does not exist"
    exit 1
fi

# Setup SSH directory and keys
mkdir -p "$TARGET_HOME/.ssh"
chmod 700 "$TARGET_HOME/.ssh"
cat "$PUBLIC_KEY" >> "$TARGET_HOME/.ssh/authorized_keys"
chmod 600 "$TARGET_HOME/.ssh/authorized_keys"

# Copy RC files
cp ~/bin/rc/vimrc "$TARGET_HOME/.vimrc"
cp ~/bin/rc/screenrc "$TARGET_HOME/.screenrc"
cp ~/bin/rc/bash_aliases "$TARGET_HOME/.bash_aliases"

# Backup existing bashrc
if [ -f "$TARGET_HOME/.bashrc" ]; then
    cp "$TARGET_HOME/.bashrc" "$TARGET_HOME/.bashrc.$(date +%Y%m%d%H%M%S)"
fi

# Install appropriate bashrc
if [ "$USERNAME" == "root" ]; then
    cp ~/bin/rc/bashrc.root "$TARGET_HOME/.bashrc"
else
    cp ~/bin/rc/bashrc "$TARGET_HOME/.bashrc"
fi

echo "Configuration files updated for $USERNAME in $TARGET_HOME"