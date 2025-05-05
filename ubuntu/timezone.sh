#!/bin/bash

# Install dependencies
sudo apt-get update && sudo apt-get install -y tzdata 

# Set timezone 
TZ=${1:-Europe/Prague}

echo $TZ
sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && sudo echo $TZ > /etc/timezone

