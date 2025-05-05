#!/bin/bash

# Install dependencies
sudo apt-get update && sudo apt-get install -y tzdata 

# Set timezone 
TZ=${1:-Europe/Prague}

sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && sudo echo $TZ > /etc/timezone && echo "Timezone $TZ has been set."

