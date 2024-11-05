#!/bin/bash

print_help() {
    echo "Использование: $0 [свой путь]"
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    print_help
    exit 0
fi

if [ -n "$1" ]; then
    INPUT_PATH="$1"
else
    INPUT_PATH="$PATH"
fi

IFS=: read -r -a path_array <<< "$INPUT_PATH"
declare -A path_set
cleaned_path=""

for dir in "${path_array[@]}"; do
    dir=$(echo "$dir" | xargs)
    
    if [[ -d "$dir" && -n "$(find "$dir" -maxdepth 1 -type f -executable 2>/dev/null)" ]]; then
        if [[ -z "${path_set["$dir"]}" ]]; then
            cleaned_path+="$dir:"
            path_set["$dir"]=1
        fi
    fi
done

cleaned_path=${cleaned_path%:}

echo "$cleaned_path"