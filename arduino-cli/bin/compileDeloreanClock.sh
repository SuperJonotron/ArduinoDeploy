#!/bin/bash

LIBRARY="DeloreanClock"
EXAMPLE="DeloreanWebServer"

#Loads the global variable set at build time
source /etc/environment

#Download all external libraries from git that don't have direct arduino library support
LIBRARIES=$USER_PATH/libraries
git clone https://github.com/SuperJonotron/arduino-tm1637 $LIBRARIES/arduino-tm1637
git clone https://github.com/SuperJonotron/Time $LIBRARIES/Time
git clone https://github.com/SuperJonotron/Timezone $LIBRARIES/Timezone
git clone https://github.com/SuperJonotron/RTClib $LIBRARIES/RTClib

#Download all available libraries from the arduino library manager
arduino-cli lib install "ArduinoJson"
arduino-cli lib install "rBase64"


#Download the DeloreanWebServer Library
#Can't do this until its made public
#git clone https://github.com/SuperJonotron/DeloreanClock $LIBRARIES/$LIBRARY

# Compile the DeloreanWebServer library
#cd $LIBRARIES/$LIBRARY/$EXAMPLE
#arduino-cli compile -e --fqbn esp8266:esp8266:nodemcuv2
