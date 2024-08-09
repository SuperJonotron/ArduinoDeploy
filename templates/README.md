# Templates

## About 

Templates are simple bash scripts that can be used to build libraries.  There is minimal modifications required for these templates and can be reused for as many libraries as needed.  

The templates are prepended with identifying names for reference.  When using them, it is generally expected to remove this prepend so they are named build.sh within the library and modify them as defined below. 

## Stand Alone Library
When building a library that has no external libraries, you can copy this template and modify only a single variable.

In the standAloneLib_build.sh, update this line to be the name of your library:

`LIBRARY_NAME="LibraryName"`

Once this is updated to match the name of your library, you can run the script and it will build the library.


## Library with Dependencies
This template is designed to use other public git repositories as libraries.  It does not currently support Arduino libraries by name alone.  This was decided for simplicity as most, if not all Arduino libraries, have a git repository out there you can look at which simplifies the process to only a single method of importing libraries.

When building a library that has external libraries, you can copy this template by modifying only two variables.

In the externalDepLib_build.sh, update this line to be the name of your library:

`LIBRARY_NAME="LibraryName"` 

Next, update the LIBRARIES variable, by default no libraries are included.
LIBRARIES=""

And example is showin in the template and is duplicated here for quick reference

`LIBRARIES="Time@https://github.com/SuperJonotron/Time.git,Timezone@https://github.com/SuperJonotron/Timezone.git"`

This would include the Time and Timezone libraries from this github account.  The process to include these libraries is as follows:

-	Check if a library by that name exists
-	If it exists, do nothing.  Templates does not automatically check for latest git versions at this time.
-	If it does not exist, clone the main branch of the repository.  Template does not currently support specifying which branch to checkout.
-	Once all git repositories are either confirmed or cloned, a docker mount is created for each one in the format:

	`-v $DEPENDENCY_LOCATION:/library/dependencies/${array[0]}"`

	- DEPENDENCY_LOCATION: The absolute path to the git repository on your system.
	- array[0]: The name of the current library

Once this is updated to match the name of your library, you can run the script and it will build the library.

Using the libraries shown in this example, if we expanded out the docker run command to show the DEPENDENCIES variables content, the following  would be generated (assume the root directory is just /home:

```
docker run -it \
   --name $LIBRARY_NAME \
   --rm \
   -v "$PWD"/src:/library/src \
   -v "$PWD"/examples:/library/examples \
   -v "$PWD"/out:/library/out \
   -v "$PWD"/library.properties:/library/library.properties \
   -v /home/Time:/library/dependencies/Time \
   -v /home/Timezone:/library/dependencies/Timezone \
   superjonotron/arduino-deploy $@
 ```

Giving the library being compiled access to the Time and Timezone libraries.

