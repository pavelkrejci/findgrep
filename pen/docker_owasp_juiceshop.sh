#!/bin/bash
#
#

sudo systemctl start docker
docker pull bkimminich/juice-shop
docker run --rm -p 80:3000 bkimminich/juice-shop
#access http://localhost:3000 in the browser, 
#the proxy exceptions must be set to 
#<-loopback>

