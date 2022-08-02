#!/bin/bash

#Loads the global variable set at build time
source /etc/environment

#Default options
BOARD="esp8266"

function usage {
    echo ""
    echo "usage: setupBoard.sh [-fqbn,-b||-h]"
    echo "  -b arduino-ci board name"
    echo "  -h Shows the usage help."
}

ARG="${1:-unset}"

#Check all arguments to assign build values
for i in $*; do
	case $ARG in
	    "-h") 
	        #Help requested.
	        usage 
	        exit 1
	        ;;
	esac
done

while getopts ":b:" opt; do
	case $opt in
		b)
			BOARD=$OPTARG
			;;
	esac
done

#Dynamically create the correct arduino global variables
#for the board regardless of what cli and board
#version were installed during build time
BOARD_VERSION=$(arduino-cli core list | grep $BOARD | awk '{print $2}')
BOARD_PATH="$DATA_PATH/packages/$BOARD/hardware/$BOARD/$BOARD_VERSION"
TOOL_PATH="$BOARD_PATH/tools/espota.py"

#Store board specific variables for use later
echo BOARD="\""$BOARD"\"">> /etc/environment 
echo BOARD_VERSION="\""$BOARD_VERSION"\"">> /etc/environment 
echo BOARD_PATH="\""$BOARD_PATH"\"">> /etc/environment 
echo TOOL_PATH="\""$TOOL_PATH"\"">> /etc/environment 

