#!/bin/bash
#
#

sudo systemctl start docker
docker pull bkimminich/juice-shop
docker run --rm -p 3000:3000 bkimminich/juice-shop
