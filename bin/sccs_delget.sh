#!/bin/bash


function PrintUsage
{
    cat <<EOT

This script closes deltas of checked out files pointed in the input stream.
Checked in files are skipped. The parameters to the script (except -sm) are 
passed transparently to the "sccs delget" command.
See man sccs for more info.
    
Usage: $0 -sm [-simulate] [args]
Where:
 -sm       Work in streaming mode. The input is expected to be a list of 
           files under sccs with open deltas that need to be checked in.
    
 -simulate Do not perform any actions, just show what would do.

 args   The arguments to be passed to the sccs delget call
        For example:
        find . -name "*.test.xml" | grep -v SCCS | $0 -sm -y"Fix for BugID 123456"
EOT
}


# Check if help required
if [ "$1" = "-h" -o "$1" = "-help" -o "$1" = "--help" -o "$1" != "-sm" ]; then
    PrintUsage
    exit 1
fi

# Process parameters
if [ "$2" = "-simulate" ]; then
    SIMULATE="1"
fi

# SCCS_ARGS=`echo $@ | sed -e "s/-sm//" | sed -e "s/^\ *-simulate//"`
# Take care of quotes in passed comments: -y"Bla bla bla"
# SCCS_ARGS=`echo $SCCS_ARGS | sed -e "s/\(.*\)-y\(.*\)/\1-y\"\2\"/"`

# The previous form of passing comments to sccs delget command does not work -
# the {"} sign is treated like a usual letter and in the comment like:
#   sccs delget -y"This is the comment"
# {"This} is treated like a comment and {is} {the} {comment"} like names of files.

# Have to put comment out of SCCS_ARGS
COMMENT=`echo $@ | sed -e "s/.*-y\(.*\)/\1/"`
SCCS_ARGS=`echo $@ | sed -e "s/-sm//; s/^\ *-simulate//; s/-y[\"']\{0,1\}.*[\"']\{0,1\}//"`

# Rock on
START=`pwd` 
for FULL_FILE_NAME in `xargs echo`
do
    FILE_PATH=`dirname $FULL_FILE_NAME`
    FILE_NAME=`basename $FULL_FILE_NAME`
    cd $FILE_PATH
    if [ "`sccs tell | grep $FILE_NAME`" = "" ]; then
        echo "[SKIPPING] $FULL_FILE_NAME is NOT checked out"
    else
        echo "sccs delget $SCCS_ARGS -y\"$COMMENT\" $FULL_FILE_NAME"
        if [ -z $SIMULATE ]; then 
            sccs delget $SCCS_ARGS -y"$COMMENT" $FILE_NAME
        fi
    fi
    # Restore current dir
    cd $START
done
    
echo "DONE"
