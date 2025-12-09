#!/bin/bash
#

#set -x
echo "Create backup of original app config"
SUFF=`mktemp -u orig-XXXX`
cp ~/.local/share/applications/chromium_chromium.desktop ~/.local/share/applications/chromium_chromium.desktop.$SUFF

echo "Copy new config"
cp /var/lib/snapd/desktop/applications/chromium_chromium.desktop ~/.local/share/applications/

echo "Check it contains valid Icon"
ICON=`grep -oP "(?<=Icon=).*" ~/.local/share/applications/chromium_chromium.desktop`
ls -la $ICON

echo "Rebuild KDE cache"
kbuildsycoca5 --noincremental

echo "Restart Plasma"
nohup plasmashell --replace >/dev/null 2>&1 &
disown

