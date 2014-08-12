#!/bin/bash

# Print usage
function PrintUsage
{
    cat <<EOT

Lists files which are not tracked by SCCS.
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
    for F in `ls -1r $DIRPATH`; 
    do
        test -f $DIRPATH/$F || continue
        test -f $DIRPATH/SCCS/s.$F || echo "[Not under SCCS]: $DIRPATH/$F"
    done
done 

