#!/bin/bash

# Validate root execution
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root"
    exit 1
fi

# Validate input parameters
if [ -z "$2" ]; then
    echo "Usage: `basename $0` <public.pem> <username>"
    echo "Examp: `basename $0` public-PavelKrejci-20240326.pem pkrejci"
    exit 1
fi

PUBLIC_KEY="$1"
USERNAME="$2"
TARGET_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)

# Verify home directory exists
if [ ! -d "$TARGET_HOME" ]; then
    echo "Error: Home directory $TARGET_HOME for user $USERNAME does not exist"
    exit 1
fi

# Verify user exists
if ! id "$USERNAME" >/dev/null 2>&1; then
    echo "Error: User $USERNAME does not exist"
    exit 1
fi

# Setup SSH directory and keys
mkdir -p "$TARGET_HOME/.ssh"
chmod 700 "$TARGET_HOME/.ssh"
cat "$PUBLIC_KEY" >> "$TARGET_HOME/.ssh/authorized_keys"
chmod 600 "$TARGET_HOME/.ssh/authorized_keys"
chown -R "$USERNAME:$USERNAME" "$TARGET_HOME/.ssh"

# Copy RC files
cp ~/bin/rc/vimrc "$TARGET_HOME/.vimrc"
cp ~/bin/rc/screenrc "$TARGET_HOME/.screenrc"
cp ~/bin/rc/bash_aliases "$TARGET_HOME/.bash_aliases"

# Set RC files ownership
chown "$USERNAME:$USERNAME" "$TARGET_HOME/.vimrc"
chown "$USERNAME:$USERNAME" "$TARGET_HOME/.screenrc"
chown "$USERNAME:$USERNAME" "$TARGET_HOME/.bash_aliases"

# Backup existing bashrc
if [ -f "$TARGET_HOME/.bashrc" ]; then
    cp "$TARGET_HOME/.bashrc" "$TARGET_HOME/.bashrc.$(date +%Y%m%d%H%M%S)"
    chown "$USERNAME:$USERNAME" "$TARGET_HOME/.bashrc.$(date +%Y%m%d%H%M%S)"
fi

# Install appropriate bashrc
if [ "$USERNAME" == "root" ]; then
    cp ~/bin/rc/bashrc.root "$TARGET_HOME/.bashrc"
else
    cp ~/bin/rc/bashrc "$TARGET_HOME/.bashrc"
fi
chown "$USERNAME:$USERNAME" "$TARGET_HOME/.bashrc"

echo "Configuration files updated for $USERNAME in $TARGET_HOME"
