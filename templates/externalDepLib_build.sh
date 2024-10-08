#!/bin/bash
mkdir -p "$PWD"/out

# Update this to the name of your library
LIBRARY_NAME="LibraryName"

# Define the third party libraries that are from public Git repository sources
# Format is <Library_Name1>@<Library_Git_URL1>,<Library_Name2>@<Library_Git_URL2>

#Example with two libraries
#LIBRARIES="Time@https://github.com/SuperJonotron/Time.git,Timezone@https://github.com/SuperJonotron/Timezone.git"
LIBRARIES=""

# Move into the library folder location 
pushd ../ > /dev/null

# Check if the library defined already exists
# in the library folder and return the path
# if it exists or clone from git and then
# return the path to the library
function resolveGitDependencyLibrary(){
	LIB_NAME=$1
	GIT_URL=$2
	if [ ! -d "$LIB_NAME" ];then
		LIBRARY="$(pwd)/$LIB_NAME"
		git clone $GIT_URL
		echo "$TIME"
	else
		LIBRARY="$(pwd)"/$LIB_NAME
		echo "$LIBRARY"
	fi
}

# Check and download library dependencies if not available.
# Build the docker mount command to include all library
# dependencies after they are resolved
DEPENDENCIES=""
LIBRARY=$(echo $LIBRARIES | tr "," "\n")
for lib in $LIBRARY
do
	echo "Resolving Library: $lib"
	IFS='@ ' read -r -a array <<< "$lib"
	DEPENDENCY_LOCATION=$(resolveGitDependencyLibrary "${array[0]}" "${array[1]}")
	echo "Library Resolved: $DEPENDENCY_LOCATION "
	DEPENDENCIES+=" -v $DEPENDENCY_LOCATION:/library/dependencies/${array[0]}"
done

#Move back into this library
popd > /dev/null

docker run -it \
   --name $LIBRARY_NAME \
   --rm \
   -v "$PWD"/src:/library/src \
   -v "$PWD"/examples:/library/examples \
   -v "$PWD"/out:/library/out \
   -v "$PWD"/library.properties:/library/library.properties \
   $DEPENDENCIES \
   superjonotron/arduino-cli $@
