#!/bin/bash

# Print usage
function PrintUsage
{
    cat <<EOT

By default this script makes "sccs diffs" to all checked out files
in current directory.
    
Usage: $0 [-r|-sm] 
Where:
 -r    Run through all subdirectories starting from curen dir. 
 -sm   Work in streaming mode. The input is expected to be a list of
       files under sccs with open deltas.
      
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
        if [ "`sccs tell | grep $FILE_NAME`" = "" ]; then
            echo "[SKIPPING] $FULL_FILE_NAME is NOT checked out"
        else
            echo [RUNNING] sccs diffs $FULL_FILE_NAME
            sccs diffs $FILE_NAME
        fi
        # Restore current dir
        cd $START
    done
elif [ "$1" = "-r" ]; then

    # Through all directories
    START=`pwd`
    DIRS=`find $START -type d | grep -v "/SCCS"`
    for WHERE in $DIRS
    do
        cd $WHERE

        FILES=`sccs tell`
        if [ "$FILES" != "" ]; then
            echo [DIR]: $WHERE
            sccs diffs $FILES
        fi
    done
else

    # Default - work on current dir only
    FILES=`sccs tell`
    if [ "$FILES" = "" ]; then
        echo "All files checked in"
    else
        sccs diffs $FILES
    fi
fi

echo "DONE"
