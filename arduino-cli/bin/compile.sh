#!/bin/bash
FQBN="esp8266:esp8266:nodemcuv2"

function usage {
    echo ""
    echo "usage: compile.sh [-fqbn,-b||-h]"
    echo "  -b Fully qualified board name"
    echo "  -e Name of the example to compile"
    echo "  -p Precompile the library"
    echo "  -h Shows the usage help."
}

PRE_COMPILED=false

#Check if the last command run was succesful or not
function lastCommandFailed(){
	if [ $? -eq 0 ]; then
   		echo -e "\033[32mOK\033[0m"
	else
   		echo -e "\033[31mFAIL\033[0m]"
	fi
}

# Set the properties in the library.properties file of the library
# to generate pre-compiled .a files
function enablePrecompileOptions(){
	#Turn off the precompiled flag to create precompiled file
	sed -i "/precompiled=/ s/=.*/=false/" $LIBRARY_PATH/library.properties
	#Turn on the option to precompiled file
	sed -i "/dot_a_linkage=/ s/=.*/=true/" $LIBRARY_PATH/library.properties
}

# Set the properties in the library.properties file of the library
# to compile without generating .a files but compile with existing .a files
function disablePrecompileOptions(){
	#Turn on the precompiled flag to use precompiled files
	sed -i "/precompiled=/ s/=.*/=true/" $LIBRARY_PATH/library.properties
	#Turn off the option to create precompiled file
	sed -i "/dot_a_linkage=/ s/=.*/=false/" $LIBRARY_PATH/library.properties
}

function precompile(){
	enablePrecompileOptions
	#Make the directories to store the pre-compiled .a file
	mkdir -p /$LIBRARY_PATH/src/$BOARD
	mkdir -p /library/out/build/$BOARD
	find $LIBRARY_PATH/examples/*Precompile -prune -type d | while IFS= read -r d; do
		# Delete all existing arduino tmp files so only one set of
		# cached compiled files exist for proper resolving after compilation
		find /tmp -type d -name 'arduino*' -exec rm -r {} +
		EXAMPLENAME=${d##*/} 
    	echo -e "\n\033[32mPrecompiling: \033[33m$d\033[0m"
		#Pre-compile the library 
        CMD="arduino-cli compile -e --output-dir /library/out/build/examples/$EXAMPLENAME -b $FQBN $d"
		echo -e "\033[33m$CMD\033[0m"
		$CMD
		SUCCESS=$(lastCommandFailed)
		echo -e "\033[32mPrecompiled $d: \033[33m$SUCCESS \033[0m"
		#Make the directories to store the pre-compiled .a file
		mkdir -p /$LIBRARY_PATH/src/$BOARD
		mkdir -p /library/out/build/$BOARD
		#Extract and load precompiled .a file to the correct location
		cd /tmp/arduino-sketch*
		cp libraries/$LIBRARY/$LIBRARY.a $LIBRARY_PATH/src/$BOARD/lib$LIBRARY.a
		cp libraries/$LIBRARY/$LIBRARY.a /library/out/build/$BOARD/lib$LIBRARY.a
    done	
}

function compileExamples(){
	disablePrecompileOptions
	find $LIBRARY_PATH/examples/* -prune -type d | while IFS= read -r d; do
		if [[ $d == *"Precompile"* ]];then
			echo -e "\033[33mSkipping Precompile Example: $d\033[0m"
		else
			EXAMPLENAME=${d##*/}
    		echo -e "\n\033[32mCompiling Example: \033[33m$d\033[0m"
    		CMD="arduino-cli compile -e --output-dir /library/out/build/examples/$EXAMPLENAME -b $FQBN $d"
			echo -e "\033[33m$CMD\033[0m"
			$CMD
			SUCCESS=$(lastCommandFailed)
			echo -e "\033[32mCompiled $d: \033[33m$SUCCESS \033[0m"
		fi
	done
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


#while getopts ":b:e:p-" opt; do
while getopts ":b:e:p-:" opt; do
	case $opt in
		b)
			FQBN=$OPTARG
			;;
		e)
			EXAMPLE=$OPTARG
			;;
		p)
			PRE_COMPILED=true
			;;
	esac
done

echo -e "\nFQBN Resolved:\033[33m $FQBN \033[0m"
#Extract just the board name from the fqbn
BOARD=$(echo $FQBN | awk '{split($FQBN,a,":"); print a[1]}')

#Extract the library name from the properties file
LIBRARY=$(cat /library/library.properties | grep name= | awk '{split($0,a,"="); print a[2]}')
echo -e "\nLibrary Resolved from library.properties:\033[33m $LIBRARY \033[0m"

#Setup the arduino-cli for board specified
echo -e "\n\033[32mSetting up Board: $BOARD...\033[0m"
/arduino-cli/bin/setupBoard.sh -b $BOARD
echo -e "\033[32mBoard Setup Complete! \033[0m"

#Loads the global variable set
source /etc/environment

#Define the library path
LIBRARY_PATH=$LIBRARIES/$LIBRARY
mkdir -p $LIBRARY_PATH

#Add some messaging to help confirm everything is working
echo -e "\n\033[32mVariables Loaded for compilation: \033[0m"
echo -e "TOOL_PATH:\033[33m $TOOL_PATH \033[0m"
echo -e "DATA_PATH:\033[33m $DATA_PATH \033[0m"
echo -e "USER_PATH:\033[33m $USER_PATH \033[0m"
echo -e "LIBRARY:\033[33m $LIBRARY \033[0m"
echo -e "LIBRARIES:\033[33m $LIBRARIES \033[0m"
echo -e "LIBRARY_PATH:\033[33m $LIBRARY_PATH \033[0m"
echo -e "BOARD:\033[33m $BOARD \033[0m"
echo -e "BOARD_VERSION:\033[33m $BOARD_VERSION \033[0m"
echo -e "BOARD_PATH:\033[33m $BOARD_PATH \033[0m"

#Extract OTA python tool and store to mounted location
mkdir -p /library/out/tools
cp $TOOL_PATH /library/out/tools

#Copy the mounted library to the expected 
#arduino-cli library location
cp -r /library/src $LIBRARY_PATH
cp -r /library/examples $LIBRARY_PATH
cp /library/library.properties $LIBRARY_PATH

if [ "$PRE_COMPILED" == true ];then
	precompile
fi

compileExamples