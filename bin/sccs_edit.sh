#!/bin/bash

# Print usage
function PrintUsage
{
    cat <<EOT

By default this script opens deltas of all files under sccs 
recursively through all subdirs starting from current directory.
    
Usage: $0 [-sm] [-simulate]
Where:
 -sm       Work in streaming mode. The input is expected to be a list of 
           files under sccs that need to be opened for editing.
           For example: 
           find . -name "*.test.xml" | grep -v SCCS | $0 -sm
      
 -simulate Do not perform any actions, just show what would do.
 
EOT
}


# Check if help required
if [ "$1" = "-h" -o "$1" = "-help" -o "$1" = "--help" ]; then
    PrintUsage
    exit 1
fi

if [ "`echo $@ | grep '\-simulate'`" != "" ]; then
    SIMULATE="1"
fi

# Start processing
if [ "$1" = "-sm" ]; then
    
    # Streaming mode
   
    START=`pwd` 
    for FULL_FILE_NAME in `xargs echo`
    do
        FILE_PATH=`dirname $FULL_FILE_NAME`
        FILE_NAME=`basename $FULL_FILE_NAME`
        cd $FILE_PATH
        if [ -f $WHERE/SCCS/p.$FILE_NAME ]; then
            echo "[SKIPPING] $FULL_FILE_NAME is already checked out"
        else
            echo "sccs edit $FULL_FILE_NAME"
            if [ -z $SIMULATE ]; then 
                sccs edit $FILE_NAME
            fi
        fi
        # Restore current dir
        cd $START
    done
else
    
    # Default mode
    
    START=`pwd`
    DIRS=`find $START -type d | grep -v "/SCCS"`
    for WHERE in $DIRS
    do
        echo [DIR]: $WHERE
        cd $WHERE

        # Workaround for trouble with "find -maxDepth 1" under Solaris
        FILES_IN_THIS_DIR=`find $WHERE/. \( -type d -a \! -name . -prune \) -o -type f -print`
        for FULL_FILE_NAME in $FILES_IN_THIS_DIR
        do
            FILE_NAME=`basename $FULL_FILE_NAME`
            if [ -f $WHERE/SCCS/p.$FILE_NAME ]; then
                echo "[SKIPPING] $FULL_FILE_NAME is already checked out"
            else
                echo "sccs edit $FILE_NAME"
                if [ -z $SIMULATE ]; then 
                    sccs edit $FILE_NAME
                fi
            fi
        done
    done
fi

echo "DONE"
