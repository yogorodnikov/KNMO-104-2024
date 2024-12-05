#!/bin/bash
input=$1
if [ -z "$input" ]; then
input=$(pwd)
fi
if [ "$1" == "-h" ]||[ "$1" == "--help" ]; then
	echo "DESCRIPTION: outputs unused directories"
	echo "EXAMPES: shardCollect.sh"
	echo "         shardCollect.sh Desktop"
	exit 1

else
read -ra array <<< "$(echo $(find "$input" -mindepth 1 -type d))"
read -ra list <<< "$(echo $(lsof +D "$input" |  awk '$9 ~ /^ *\// {print $9}'))"
count=0
for dir in "${array[@]}"
do
	for element in "${list[@]}"
	do
		if [ "$dir" == "$(dirname "$element")" ]; then
			count=1
		fi
	done
	if [ "$count" == "0" ]; then
    	echo "$dir";
    	fi
	count=0
done
fi
