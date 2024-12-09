#!/bin/bash
#
#

sudo systemctl start docker
docker pull bkimminich/juice-shop
#docker run --rm -p 80:3000 bkimminich/juice-shop
#docker run -it --rm -p 127.0.0.1:3000:3000 bkimminich/juice-shop
docker run -it --rm -p 3000:3000 bkimminich/juice-shop
#docker run --rm -p 192.168.50.128:3000:3000 bkimminich/juice-shop
#access http://localhost:3000 in the browser, 
#the proxy exceptions must be set to 
#<-loopback>

