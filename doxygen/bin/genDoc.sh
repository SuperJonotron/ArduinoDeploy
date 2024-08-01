#!/bin/bash

echo -e "Generating doc...\n"

#Clear old results
rm -r /library/out/doc
#Move over the mounted source files
cp -r /library/src /doxygen/
#Move into the directory
cd /doxygen/src
#Generate the documentation
doxygen /doxygen/doxygen.conf
#Create the output directory
mkdir -p /library/out/doc
#Generate the pdf from the latex results
cd /doxygen/src/latex
make
#Move the generated documentation to the output directory
cp -r /doxygen/out/html /library/out/doc/
cp -r /doxygen/out/latex /library/out/doc
echo -e "Doc Generated...\nDone"