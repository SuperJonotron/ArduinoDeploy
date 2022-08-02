#!/bin/bash

# Install the core arduino-cli code and do bare minimum to set it up for usage 
# within the container.
#
# This is intended help keep the Dockerfile cleaner and easier to read as well 
# as remove a lot of issues with dynamic enviornemnt variables that are hard to 
# manage when trying to work from the Docker build context. 

#Download and install arduino-cli to /bin
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

#Initialize arduino-cli
arduino-cli config init 

#Resolve the installed locations for arduino-cli
DATA_PATH=$(arduino-cli config dump | grep "data:" | awk '{print $2}')
USER_PATH=$(arduino-cli config dump | grep "user:" | awk '{print $2}')

#Setup the libraries folder
mkdir -p $USER_PATH/libraries
LIBRARIES=$USER_PATH/libraries

#Store the arduino global variables
echo DATA_PATH="\""$DATA_PATH"\"">> /etc/environment 
echo USER_PATH="\""$USER_PATH"\"">> /etc/environment 
echo LIBRARIES="\""$LIBRARIES"\"">> /etc/environment 

