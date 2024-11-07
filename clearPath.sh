#!/bin/bash

CLEAR_PATH=""
PATHS="$PATH"
CORRECT_PATHS=()
IFS=":"

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	echo This program clears PATH of unnecessary paths.
	echo bash clearPath.sh
	echo OR
	echo bash clearPath.sh SOME_PATHS
	exit 0
fi

if [[ "$1" != "" ]]; then
	PATHS="$1"
fi

for path in $PATHS; do
	if [[ -d "$path" ]]; then
		if [[ $(find "$path" -type f -executable) != "" ]]; then
			isUniquePath=1
			for CORRECT_PATH in "${CORRECT_PATHS[@]}"; do
				if [[ "$CORRECT_PATH" == "$path" ]]; then
					isUniquePath=0
					break
				fi
			done

			if [[ $isUniquePath == 1 ]]; then
				CORRECT_PATHS+=("$path")
			fi
		fi
	fi
done

for path in "${CORRECT_PATHS[@]}"; do
	CORRECT_PATH="$path"
	if [[ -z "$CLEAR_PATH" ]]; then
		CLEAR_PATH="$CORRECT_PATH"
	else
		CLEAR_PATH="$CLEAR_PATH:$CORRECT_PATH"
	fi
done

echo ENTERED PATHS - "$PATHS"
echo CLEARED PATH - "$CLEAR_PATH"
