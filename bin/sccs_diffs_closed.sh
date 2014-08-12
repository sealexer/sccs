#!/bin/bash

# Print usage
function PrintUsage
{
    cat <<EOT

Show changes in latest deltas for files with closed deltas.

Usage: $0 -sm
Where:
 -sm   Work in streaming mode. The input is expected to be a list of
       files under sccs with CLOSED deltas.
      
Example: echo "MyTest.java" | $0 -sm
EOT
}

# Check if help required
if [ "$1" = "-h" -o "$1" = "-help" -o "$1" = "--help" ]; then
    PrintUsage
    exit 1
fi

# Rock on
if [ "$1" = "-sm" ]; then

    # Streaming mode
   
    START=`pwd` 
    for FULL_FILE_NAME in `xargs echo`
    do
        FILE_PATH=`dirname $FULL_FILE_NAME`
        FILE_NAME=`basename $FULL_FILE_NAME`
        cd $FILE_PATH
        LAST_DELTA=`sccs prt -y $FILE_NAME | sed -e "s/.\{1,\}D[ \t]1\.\([0-9\.]\{1,\}\).*/\1/"`
        PREV_DELTA=`expr $LAST_DELTA - 1`
        echo [RUNNING] sccs diffs -r1.$PREV_DELTA $FULL_FILE_NAME
        sccs diffs -r1.$PREV_DELTA $FILE_NAME
        # Restore current dir
        cd $START
    done
else
    PrintUsage
    exit 1
fi

echo "DONE"


