#!/bin/bash

# This script is intended to build an Arduino library with
# no external dependencies.  It will create an output directory
# to store all compiled files based on the parameters provided.

# The script should be run directly from the root folder of the
# library that is being compiled.  

# Building of the ArduinoDeploy image needs to be performed before
# this script being run.

# This is only a template and needs to be modified for the specific
# library it is intended for.

mkdir -p "$PWD"/out

# Update this to the name of your library
LIBRARY_NAME="LibraryName"


docker run -it \
   --name "$LIBRARY_NAME" \
   --rm \
   -v "$PWD"/src:/library/src \
   -v "$PWD"/examples:/library/examples \
   -v "$PWD"/out:/library/out \
   -v "$PWD"/library.properties:/library/library.properties \
   superjonotron/arduino-cli $@
