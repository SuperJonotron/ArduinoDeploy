FROM ubuntu:20.04
#Update before we do anything else
RUN apt-get update

#Get the CA certificates so we can validate packages
RUN apt-get install ca-certificates -y --no-install-recommends

#Uncomment this to install packages for debugging
RUN apt-get install iputils-ping net-tools -y --no-install-recommends

# Install all required packages
#   - curl -> used to retrieve arduino packages
#	- git -> used to retrieve arduino libraries
#	- python3 -> required to use arduino-cli
#	- python-is-python3 -> esp32 packages needs this to resolve python with esptool.py 
# 	- python3-serial -> Python serial module needed for esp32 compiling
#	- dos2unix -> Used to fix window line endings for bash files
RUN apt-get install curl git python3 python-is-python3 python3-serial dos2unix -y --no-install-recommends

#Create necessary directories
RUN mkdir -p /arduino-cli
RUN mkdir -p /sketch/out
RUN mkdir -p /library/out
RUN mkdir -p /arduino-deploy/bin

#Move over all the core required files
COPY arduino-cli/config /arduino-cli/config
COPY arduino-cli/bin/install.sh /arduino-cli/bin/
COPY arduino-cli/bin/configure.sh /arduino-cli/bin/

#Make sure binaries are executable
RUN chmod +x /arduino-cli/bin/*

# When developing in windows, bash files tend get
# corrupted so we'll correct for this every time to be safe
RUN find arduino-cli/config/ -type f -print0 | xargs -0 dos2unix
RUN find arduino-cli/config/esp8266 -type f -print0 | xargs -0 dos2unix
RUN find arduino-cli/bin/ -type f -print0 | xargs -0 dos2unix

# Install base arduino-cli install
RUN /arduino-cli/bin/install.sh

#Setup arduino-cli for specific board usages
#supported by this image
RUN /arduino-cli/bin/configure.sh

# Move over all files needed for compiling
# Doing this after core files helps with faster
# builds when modifying these files which happens
# much more often than the core files
COPY arduino-cli/bin/setupBoard.sh /arduino-cli/bin/
COPY arduino-cli/bin/compile.sh /arduino-cli/bin/
COPY bin/deploy.sh /arduino-deploy/bin/

# Make sure binaries are executable
RUN chmod +x /arduino-cli/bin/*

# When developing in windows, bash files tend get
# corrupted so we'll correct for this every time to be safe
RUN find arduino-cli/bin/ -type f -print0 | xargs -0 dos2unix

ENTRYPOINT ["/arduino-deploy/bin/deploy.sh"]

# NodeMCU 1.0 (ESP-12E Module) 
# https://github.com/esp8266/Arduino/blob/master/boards.txt

#nodemcuv2.menu.FlashSize.4M1M.build.spiffs_start=0x300000
#nodemcuv2.menu.FlashSize.4M1M.build.spiffs_end=0x3FB000

#0x3FB000 - 0x300000 = 0xFB000

#cd /root/.arduino15/packages/esp8266/tools/mkspiffs/2.5.0-4-b40a506/
#./mkspiffs --size 0xFB000 --page 256 --block 8192 -d 5 --create /data /data/spiffs.bin
