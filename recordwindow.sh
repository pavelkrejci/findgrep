#!/bin/bash
#
recordmydesktop --windowid `xwininfo -display :0 | grep 'id: 0x' | grep -Eo '0x[a-z0-9]+'`
