#!/bin/bash

#WordPress scan
MYTOKEN="KaJMBG9Ityv8eIprRoUKTfofioIAwjVmg90q0RXMtdY"

wpscan --api-token $MYTOKEN $*
