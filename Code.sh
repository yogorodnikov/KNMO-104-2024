#!/bin/bash

if [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
    echo 'SPRAVKA'
    exit 0
else
    cd "$1" || exit 1 
    input=( $(find . -name "*.jpg" | sort) )

    resources=()
    for file in "${input[@]}"; do
        if file "$file" | grep -qE 'image|bitmap|graphics'
        then
            resources+=("$file")
        fi
    done

    if [ ${#resources[@]} -eq 0 ]
    then
        echo "No image files found in the directory."
        exit 1
    fi

    time=$(echo "$2 / ${#resources[@]}" | bc -l)

    convert -colorspace GRAY -extent 4:3 -scale 1000 -delay "$time" "${resources[@]}" "./$3.gif" || exit 1

    exit 0
fi
