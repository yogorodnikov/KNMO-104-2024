#!/bin/bash

if [[ "$1" == "-h" || "$1" == "-help" ]]; then
    echo "использование: $0 <directory> <min_width> <min_height> <name_of_pdf>"
fi

if [[ "$#" -ne 4 ]]; then
    echo "error no args"
    exit 1
fi

dir="$1"
min_width="$2"
min_height="$3"
pdf="$4"

if [ ! -d "$dir" ]; then
    echo "error no such directory '$dir'"
    exit 1
fi

if ! [[ "$min_width" =~ ^[0-9]+$ ]] || ! [[ "$min_height" =~ ^[0-9]+$ ]]; then
    echo "error args is not digits"
    exit 1
fi

temp=$(mktemp -d)

max_w=0
max_h=0

for image in "$dir"/*; do
    info=$(file "$image")
    if [[ $(echo "$info" | cut -d" " -f 2)=="JPEG"  ]]; then
        width=$(identify -format "%w" "$image")
        height=$(identify -format "%h" "$image")
        if [[ "$width" -ge "$min_width" ]] && [[ "$height" -ge "$min_height" ]]; then
            if [[ "$width" -gt "$max_width" ]]; then max_width="$width"; fi
            if [[ "$height" -gt "$max_height" ]]; then max_height="$height"; fi
            cp "$image" "$temp"
        fi
    else
        echo "'$image' is not jpeg"
    fi
done

if [ "$(ls -A $temp)" == "" ]; then
    echo "error no jpegs"
    rm -rf "$temp"
    exit 1
fi

for img in "$temp"/*; do
    convert "$img" -resize "${max_width}x${max_height}!" "$img"
done

convert "$temp"/* "$pdf"

rm -rf "$temp"

echo "pdf created '$pdf'"
