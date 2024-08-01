#!/bin/bash

#Loads the global variable set during arduino-cli install
source /etc/environment

#Update arduino-cli with the new config file
arduino-cli core update-index

#Install the esp8266 board
arduino-cli core install esp8266:esp8266

#Install the esp32 board
arduino-cli core install esp32:esp32

#Install the esp32 board
arduino-cli core install rp2040:rp2040

#Dynamically create the correct variables
#for the esp8266 board regardless of what cli and board
#version were installed during build time
echo "Configure Data Path: $DATA_PATH"
cat /etc/environment
BOARD="esp8266"
BOARD_VERSION=$(arduino-cli core list | grep $BOARD | awk '{print $2}')
BOARD_PATH="$DATA_PATH/packages/$BOARD/hardware/$BOARD/$BOARD_VERSION"

#Replace the platform.txt for the esp8266 to fix pre-compiled library usage
cp /arduino-cli/config/$BOARD/platform.txt $BOARD_PATH
