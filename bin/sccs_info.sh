#!/bin/bash

# Print usage
function PrintUsage
{
    cat <<EOT

Just shows which files are checked out. 
Works recursively starting from the current dir.
    
EOT
}

# Check if help required
if [ "$1" = "-h" -o "$1" = "-help" -o "$1" = "--help" ]; then
    PrintUsage
    exit 1
fi


for DIRPATH in `find . $1 -type d | grep -v SCCS`
do
    RES=`sccs info $DIRPATH 2>/dev/null | grep 'edited:'`
    if [ "$RES" != "" ]; then
	echo -e "======$DIRPATH:======\n$RES"
    fi
done

