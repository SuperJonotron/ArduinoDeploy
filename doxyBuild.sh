#!/bin/bash
# Builds the docker images. Usage of this file is expected to be run form the
# ArduinoDeploy root folder to maintain proper relative file locations.

function usage {
    echo ""
    echo "usage: buildDev.sh [-b|-h]"
    echo "  -b Build the image and recompile the code without starting the docker container."
    echo "  -h Shows the usage help."
}

ARG="${1:-unset}"

#Validate the arguments when provided
case $ARG in
    "unset"|"-b") 
        #All good
        ;;
    "-h") 
        #Help requested.
        usage 
        exit 1
        ;;
    *) 
        #Invalid arguments
        usage 
        exit 1
        ;;
esac

echo "Building image for doxygen..."
docker build -f docker/Dockerfile-doxygen -t superjonotron/doxygen .