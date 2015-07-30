#!/bin/bash

#  Give your TimeMachine Backup a Diet by culling older backups
#  Coded by Jack-Daniyel Strong, J-D Strong Consulting, Inc. & Strong Solutions
#  Written 2015.07.28, Last Modified 2015.07.28 by Jack-Daniyel Strong

# Define variables for path to executables
TMUTIL="/usr/bin/tmutil"

# Define variables
TARGETSIZE=$1  #in GB

### TOUCH NOTHING BELOW THIS LINE ###
TARGETSIZE=$((TARGETSIZE*1000))

echo "We will remove backups greater than $1 GB, or $TARGETSIZE MB."

declare -a BACKUPS

if [ $(whoami) != 'root' ]; then
       echo "Must be root to run $0"
        exit 1;
fi
if [ -z $1 ]; then
        echo "Usage: $0 <target size in Gigabytes>"
        exit 1
fi

# Build List to Loop Through
IFS=$'\n'       # make newlines the only separator
let count=0
for backup in $( $TMUTIL "listbackups" ); do
    BACKUPS[$count]="$backup"
    ((count++))

#	echo "$count: $backup"
done

echo " Loop Count: $count /n"
let snapshot=$count

let snapshotsum=0
for ((i=${#BACKUPS[*]-1}; i>=0; i--));
do
    busize=`$TMUTIL uniquesize ${BACKUPS[i]} | awk '{print $1}'`
    busizemb=`echo $busize |   
    awk '{
    ex = index("MB-G", substr($1, length($1)))
    val = substr($1, 0, length($1)-1)

    prod = val * 10^((ex * 1) - 1)

    sum += prod
}
END {print sum}'`
     let busizemb=${busizemb/\.*} #remove floating point
     let newsnapshotsum=$snapshotsum+$busizemb
    if (( $newsnapshotsum >= $TARGETSIZE )); then
    	#cull this backup
    	echo Removing ${BACKUPS[i]} $snapshotsum
	 	$TMUTIL delete ${BACKUPS[i]}
	else
     let "snapshotsum+=$busizemb"
    echo $i: ${BACKUPS[i]} $snapshotsum
	
	fi
done

# Detect SparseBundle and Compress


exit 0

# done ! :)
