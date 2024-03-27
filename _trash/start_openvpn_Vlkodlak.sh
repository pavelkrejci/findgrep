#!/bin/bash

keepassxc-cli attachment-export /home/atos/shares/KeePass/prace.kdbx /VPN/Vlkodlak pavel_krejci_vlkodlak.ovpn --stdout | sudo openvpn --config /dev/stdin

exit 0

#false attempt to use ssh agent - not possible to export private key like this
#SSH_KEY=$(ssh-add -L | grep pavel_krejci_vlkodlak.pem | awk '{print $2}')
#echo -e "$SSH_KEY" | openvpn --config ~/pavel_krejci_vlkodlak.ovpn --cert ~/pavel_krejci_vlkodlak.cert --key /dev/stdin

#simple file
#sudo openvpn --config ~/pavel_krejci_vlkodlak.ovpn
