# Arduino Deploy

## Introduction

This project is designed to use Docker, Arduino CLI and doxygen to compile Arduino projects and create documentation.  It can also create pre-compiled files that can be distributed.

This project is designed to work with the esp8266, esp32 and rp2040 hardware. There is no technical restriction to this, it's just the boards I tend to use.

Most if not all boards have seem to have some special consideration, so it's unlikely I'll add more without a specific purpose but feel free to throw in a pull request if you like.

## Motivation

I liked the idea of making pre-compiled .a files for some of my projects so I could reuse release code and speed up compile and build times.  The documentation aspect just came later as it seemd liked a good addition to what I was doing.
 

## Requirements :computer:
### Hardware
 - Internet connection

### Software
- Docker - installation guide: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

All my work on this project has been through the use of Docker Desktop and WSL for windows but any supported OS for Docker should work, so just pick your preference from the link and get to building.

## Get started ▶️

### Setup
Once you have met the hardware and software requirements, you can get started. All you have to do to is run the build script

./build.sh

This will build the docker image containing all the dependencies and setup for usage.  The image created will be named:

`superjonotron/arduino-deploy`

## Usage

By itself, this project is not very useful, it is meant to be used from the context of a separate Arduino library.  Creating a library for Arduino is out of scope for this project and is well covered elsewhere so we'll just assume you have one ready going forward.


### Preparing Your Library
Any existing Arduino library that follows this basic Arduino library structure:

```
Library
 -src
 -examples
 -library.properties
 ```

 Needs no preparation to use the build scripts and can use the templates provided as a starting point with minimal modifications for use.  The only thing that will be missing is the ability to utilize the precompile feature.  To have your library precompiled, you will need to do the following:

 1. Configure for .a files:
 In your library.properties file add/modify the line to allow for this.
 
   `dot_a_linkage=true`

 2. Configure deployment strategy:
 If you want to deploy your library with precompiled .a files, you will need to add/modify the line:
 
   `precompiled=true`

   This can be set to false in case you don't want to deploy a precompiled library but do want to test it out or use it locally for your own purposes.  This will be automatically set to true inside the build container to allow precompiling to occur but won't modify your current library.properties file.

3. Setup your examples:
The builder method attempts to compile all examples for all boards defined but uses a special naming convention when determining precompiling.  To make your library precompile the library, all you need to do is to add a .ino(sketch) file that imports your library and is prepended by the name "_Precompile".

   example: If your library name is "foo"
The example you would need to generate could be named: "foo_Precompile"

   And the example sketch would look like the following (assuming a .h file was created for this library)

   ```
   #include <foo.h>
   
   void setup() {
   }

   void loop() {
   }
   ```

### Building Your Library

##### 1. Stand Alone Library
If you have a library that requires no dependencies outside of the core Arduino libraries provided and the board packages, you can run a one line command to build everything you need.

```docker run -it \
   --name <libraryname> \
   --rm \
   -v "$PWD"/src:/library/src \
   -v "$PWD"/examples:/library/examples \
   -v "$PWD"/out:/library/out \
   -v "$PWD"/library.properties:/library/library.properties \
   superjonotron/arduino-deploy $@
```

You will need to run this directly from the root of your library and update the libraryname to the name of your library.  i.e. if your library was named "libraryX" it would be updated to

`docker run -it \
   --name libraryX \
  ...`
  
  An example script that can be modified for your library can be found in the templates directory.
  
##### 2. Library with Dependencies
If you have a library that requires dependencies from other libraries, you will need to mount these to the correct location within the container.

```
docker run -it \
   --name <libraryname> \
   --rm \
   -v "$PWD"/src:/library/src \
   -v "$PWD"/examples:/library/examples \
   -v "$PWD"/out:/library/out \
   -v "$PWD"/library.properties:/library/library.properties \
   -v <path_to_library_dependency>:/library/dependencies/<depenency_name>
   $DEPENDENCIES \
   superjonotron/arduino-deploy $@
  ```

If you have multiple dependencies, you will need to have one entry per dependency.  To make this easier, see the templates section for simple example on how to accomplish this.

##### 3. Advanced Usage
In the previous examples, the eagle eyed reader may have noticed that $@ at the end of the command and wondered what's up with that?  That is used as a passthrough for any additional run arguments to the builder container.  These arguments are passed into the deploy.sh script in the bin folder.

- If you want to see the currently available arguments, you can run the -h option dirctly on the deploy.sh.  

   `deploy.sh -h`
    
   ```
    usage: build.sh [-b|-c|-doc|-h]
      -c         Compile all examples in this library and create binary files.
                 If -e(exmple) argument is supplied it will only compile the example specified.

      --doc      Generate the code documentation using doxygen.

      -b         Comma separated List of fully qualified board names (FQBN) to pass
                 to the arduino-cli compile function.
                 Default FQBN's:
                  -esp32:esp32:nonodemcu-32s
                  -esp8266:esp8266:nodemcuv2

      -e         Name of the specific example to compile. Will only compile this
                 specified example and not the entire library

      -p         Generate the precompiled .a files.
                 Precompiling only happens if there is an example that include
                 'Precompile' in its name or if the example is defined with the -e option
                 along with this option

      -h         Shows the usage help.

     If no arguemnts are supplied the default behavior is to
     precompile .a files, compile binaries, and generate documentation
    ```

   Or, if you like everything through docker for consistency.

   `docker run --rm superjonotron/arduino-deploy -h`

- Why did -h to the docker run work?  
The container that is built with this project uses the deploy.sh as the entrypoint which means any args you pass go directly to it.  Effectively, this is the same as running it locally.


## FAQ :raising_hand:
1. Why is this called ArduinoDeploy when all the documentation is around building/compiling projects?

I originally started this with the intention of building and uploading to  the controllers.  I tried a few things for OTA at one point but hit some weird networking things when it came to running from WSL and never got back to it.  If you inspect the dockerfile, you'll see a few notes I still have in there concerning various things I needed when it comes to working with spiffs from a command line perspective.  Maybe i'll get back to this eventually but for now, ArduinoDeply is mostly a compiling application.


