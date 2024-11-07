#!/bin/bash
count=0
output=""

if [ -z "$1" ]; then
	dir=$PATH
else
	dir=$1
fi

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	echo "DESCRIPTION: outputs cleared PATH (by default if no args)"
	echo "EXAMPLE: clearPath /bin:/usr/games:/usr/bin"
	exit 1

else
IFS=":" read -r -a arr <<< "$dir"
sort=$(for i in "${arr[@]}"; do echo "$i"; done | sort -u)
IFS=$'\n'
for line in $sort; do
	for file in $line/*; do
		if [ -x "$file" ] && [ -f "$file" ] && [ "${file:0:1}" == '/' ]; then
		count=$((count+1))
		fi
	done
	if [ $count != 0 ]; then
		if [ -z "$output" ]; then
			output=$line
		else
			output=$output:$line
		fi
		count=0
	fi
done
echo "$output"
fi
