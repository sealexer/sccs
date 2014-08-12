#!/bin/bash


function PrintUsage
{
    cat <<EOT

This script makes "sccs unedit" recursively to all checked out files with 
emty deltas starting from curent dir. "Empty delta" means that after checking
out the file did not get changed.
    
Usage: $0 [-sm] [-simulate]
Where:
 -sm       Work in streaming mode. The input is expected to be a list of 
           files under sccs with open deltas.
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
        if [ "`sccs tell | grep $FILE_NAME`" == "" ]; then
            echo "[SKIPPING] $FULL_FILE_NAME is NOT checked out"
        # A bit ugly \n form...
        elif [ "`sccs diffs $FILE_NAME | grep -v $FILE_NAME`" != "\
" ]; then
            echo "[SKIPPING] $FULL_FILE_NAME got changed after checking out"
        else
            echo "[UNCHANGED]: sccs unedit $FULL_FILE_NAME"
            if [ -z $SIMULATE ]; then 
                sccs unedit $FILE_NAME
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
        
        cd $WHERE

        if [ "`ls -al | grep SCCS`" == "" ]; then
            # No sccs information - skip
            continue
        fi

        echo [DIR]: $WHERE
        
        # Get list of all checked out files
        FILES_IN_THIS_DIR=`sccs tell`
        for FULL_FILE_NAME in $FILES_IN_THIS_DIR
        do
            FILE_NAME=`basename $FULL_FILE_NAME`
            # A bit ugly \n form...
            if [ "`sccs diffs $FILE_NAME | grep -v $FILE_NAME`" != "\
" ]; then
                echo "[SKIPPING] $FULL_FILE_NAME got changed after checking out"
            else
                echo "[UNCHANGED]: sccs unedit $FILE_NAME"
                if [ -z $SIMULATE ]; then 
                    sccs unedit $FILE_NAME
                fi
            fi
        done
    done
fi

echo "DONE"
