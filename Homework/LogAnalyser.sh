#!/bin/bash

if [ -z "$1" ]; then
    echo "No args! See help for explanation"
    exit 1
else
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "HELP:"
        echo "USAGE: $0 <filename> <targetfile> <beginTime> <shiftTime>"
        exit 0
    else

        filename=$1
        targetfile=$2
        beginTime1=$3
        beginTime2=$4
        shiftTime=$5
    fi
fi

echo "" > "$targetfile"

beginTime=( "$beginTime1 $beginTime2" )

shiftTime=$(($shiftTime * 60))

beginTimeSec=$(date -d "%Y-%m-%d %H:%M:%S" "$beginTime" +%s 2>/dev/null)
if [ $? -ne 0 ]; then  
    echo "Error: Invalid format beginTime. Expected format YYYY-MM-DD HH:MM:SS."
    exit 10
fi

if true; then
    endTimeSec=$(( $beginTimeSec + $shiftTime ))
else
    temp=$beginTimeSec
    endTimeSec=$(( $beginTimeSec - $shiftTime ))
    beginTimeSec=$endTimeSec
    endTimeSec=$temp
fi


while IFS= read -r line
do
    time=$(echo "$line" | awk -F'|' '{print $2}')
    
    timeSec=$(date -d "%Y-%m-%d %H:%M:%S" "$time" +%s 2>/dev/null)

    if [[ $timeSec -ge $beginTimeSec && $timeSec -le $endTimeSec ]]; then
        echo "$line" >> $targetfile
    fi

done < "$filename"
echo "Done"
