#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <Path> <seconds> <output filename>"
    exit 1
fi

INPUT_DIR=$1
DURATION=$2
OUTPUT_FILE=$3

IMAGES=($(find "$INPUT_DIR" -maxdepth 1 -type f -name "*.jpg" | sort))

# Check the number of images
NUM_IMAGES=${#IMAGES[@]}
if [ "$NUM_IMAGES" -eq 0 ]; then
    echo "No .jpg."
    exit 1
fi

DELAY=$(echo "scale=2; ($DURATION / $NUM_IMAGES) * 100" | bc)

convert "${IMAGES[@]}" -colorspace Gray -delay "$DELAY" -loop 0 "$OUTPUT_FILE"

echo "GIF animation $OUTPUT_FILE"
