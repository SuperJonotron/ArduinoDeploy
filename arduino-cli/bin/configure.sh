#!/bin/bash

#Loads the global variable set during arduino-cli install
source /etc/environment

#Replace file "/root/.arduino15/arduino-cli.yaml" created from init
#with the esp8266 and esp32 boards defined in additional_urls
cp /arduino-cli/config/arduino-cli.yaml $DATA_PATH

#Update arduino-cli with the new config file
arduino-cli core update-index

#Install the esp8266 board
arduino-cli core install esp8266:esp8266

#Install the esp32 board
arduino-cli core install esp32:esp32

#Dynamically create the correct variables
#for the esp8266 board regardless of what cli and board
#version were installed during build time
BOARD="esp8266"
BOARD_VERSION=$(arduino-cli core list | grep $BOARD | awk '{print $2}')
BOARD_PATH="$DATA_PATH/packages/$BOARD/hardware/$BOARD/$BOARD_VERSION"

#Replace the platform.txt for the esp8266 to fix pre-compiled library usage
cp /arduino-cli/config/$BOARD/platform.txt $BOARD_PATH
