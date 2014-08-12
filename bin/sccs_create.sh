#!/bin/bash

function PrintUsage
{
    cat <<EOT

    This script puts the content of a current directory or the pointed files 
under sccs (removing created ,* files).
    
Usage: $0 [-r|-sm] [-simulate]
Where:
 -r        Run through all subdirectories starting from the current dir.
 -sm       Work in streaming mode. The input is expected to be a list of
           files that are to be put under sccs.
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

# Rock on
F_RECUR=`echo $1 | grep "\-r"`
F_STREAMING=`echo $1 | grep "\-sm"`
F_SIMUL=`echo $1 $2 | grep "\-simulate"`
ABSSTARTDIR=`pwd`

if [ -n "$F_RECUR" ]; then
    DIRS=`find . -type d`
else
    DIRS=.
fi

if [ -n "$F_STREAMING" ]; then

    # Streaming mode

    for FULL_FILE_NAME in `xargs echo`
    do
        FILE_PATH=`dirname $FULL_FILE_NAME`
        FILE_NAME=`basename $FULL_FILE_NAME`
        cd $FILE_PATH
        if [ -e "SCCS/s.$FILE_NAME" ]; then
            echo "[SKIPPING] file $FULL_FILE_NAME is already under sccs"
            cd $ABSSTARTDIR
            continue
        fi
        echo "sccs create $FULL_FILE_NAME"
        if [ -z "$F_SIMUL" ]; then
            sccs create $FILE_NAME
        fi
        cd $ABSSTARTDIR
    done
else

    # Default mode

    for DIR in $DIRS; do
        # Omit SCCS and Codemgr_wsdata directories
        if [[ -n "`echo $DIR | grep "SCCS"`" || -n "`echo $DIR | grep "Codemgr_wsdata"`" ]]; then
            continue
        fi
        cd $ABSSTARTDIR/$DIR
        for FILE in `ls -1F | grep -v "\/"`; do
            if [ -e "SCCS/s.$FILE" ]; then
                echo "[SKIPPING] file $DIR/$FILE is already under sccs"
                continue
            fi
            echo "sccs create $DIR/$FILE"
            if [ -z "$F_SIMUL" ]; then
                sccs create $FILE
            fi
        done
    done
fi

echo "[REMOVING] ,* trash: find $ABSSTARTDIR -name ",*" -type f -exec rm -f \{\} \;"
if [ -z "$F_SIMUL" ]; then
    find $ABSSTARTDIR -name ",*" -type f -exec rm -f \{\} \;
fi


# ENTRYDIR=$1
# for DIR in `find $ENTRYDIR -type d`
# do
#     # Omit SCCS and Codemgr_wsdata directories
#     if [[ -n  "`echo $DIR | grep "SCCS"`" || -n  "`echo $DIR | grep "Codemgr_wsdata"`"]]; then
#         continue
#     fi
#     echo "sccs create $DIR/*"
#     sccs create $DIR/*
# done
#
# find $ENTRYDIR -name ",*" | xargs rm

