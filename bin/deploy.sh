#!/bin/bash

function usage {
    echo -e "\nusage: build.sh [-b|-c|-doc|-h]"
    echo "  -c         Compile all examples in this library and create binary files." 
    echo "             If -e(exmple) argument is supplied it will only compile the example specified."
    echo
    echo "  --doc      Generate the code documentation using doxygen."
    echo
    echo "  -b         Comma separated List of fully qualified board names (FQBN) to pass"
    echo "             to the arduino-cli compile function."
    echo "             Default FQBN's: "
    echo "              -esp32:esp32:nonodemcu-32s"
    echo "              -esp8266:esp8266:nodemcuv2"
    echo
    echo "  -e         Name of the specific example to compile. Will only compile this"
    echo "             specified example and not the entire library"
    echo
    echo "  -p         Generate the precompiled .a files."
    echo "             Precompiling only happens if there is an example that include"
    echo "             'Precompile' in its name or if the example is defined with the -e option"
    echo "             along with this option"
    echo
    echo "  -h         Shows the usage help."
    echo -e "\n If no arguemnts are supplied the default behavior is to"
    echo " precompile .a files, compile binaries, and generate documentation"
}

ARG="${1:-unset}"

# Default all variables to false so we can just turn on
# the ones selected via the ARGS
COMPILE=false
GEN_DOC=false
PRE_COMPILED=false
FQBNS="esp8266:esp8266:nodemcuv2,esp32:esp32:nodemcu-32s"
EXAMPLE=""



#Validate the arguments when provided


case $ARG in
	"-h") 
        #Help requested.
        usage 
        exit 1
        ;;
    "unset")
		# No Args provided, set the default behavior
		COMPILE=true
		GEN_DOC=true
		PRE_COMPILED=true
esac

# while getopts ":b:c:e:cph-:" opt; do
while getopts ":b:e:cph-:" opt; do
	echo "OPT: $opt"
	case $opt in
		-)
			case "${OPTARG}" in
				doc)
					GEN_DOC=true
					;;
			esac;;
		b)
			FQBNS=$OPTARG
			;;
		c)
			COMPILE=true
			;;
		e)
			EXAMPLE=$OPTARG
			;;
		p)
			PRE_COMPILED=true
			;;
		h) 
	        #Help requested.
	        usage 
	        exit 1
	        ;;
	esac
done

if [ "$COMPILE" == true ];then
	#Create an output directory for the binaries
	mkdir -p "$PWD/out/"

	OPTARGS=""
	if [ "$PRE_COMPILED" == true ];then
		OPTARGS="-p"
	fi

	if [ ! -z "$EXAMPLE" ];then
		OPTARGS+=" -e $EXAMPLE"
	fi

	BOARDS=$(echo $FQBNS | tr "," "\n")
	for fqbn in $BOARDS
	do
		/arduino-cli/bin/compile.sh "-b $fqbn" "$OPTARGS"
	done
fi

if [ "$GEN_DOC" == true ];then
	echo -e "Generating doc...\nDone"
fi