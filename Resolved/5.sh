#!/bin/bash

target_dir=$(pwd)

case "$1" in
    -h|--help)
        echo "This is SPRAVKA!!!"
        echo "$0 is a script for detecting unused directories, pass the directory
you want to process to it, otherwise the current one will be used.
example:
     >> $0 -h                           // to get help
     >> $0                              // to processing now active catalog
     >> $0 specify/the/directory/here   // to processing specified by you"
        ;;
    -d|--dir)
        target_dir="$2"
        shift 2
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac


directories=()
open_files=()
da=0

while IFS= read -r dir; do
    directories+=("$dir")
done < <(find "$target_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)


while IFS= read -r file; do
    open_files+=("$file")
done < <(lsof +D "$target_dir" 2>/dev/null | awk '{print $9}')
# lsof +D выполняет поиск открытых файлов внутри указанной директории и её подкаталогов

for dir in "${directories[@]}"; do
    in_use=false
    for file in "${open_files[@]}"; do
        if [[ "$dir" == "$(dirname "$file")" ]]; then
            in_use=true
            break
        fi
    done
    if ! $in_use; then
        echo "$dir"
        da=1
    fi
done

if [[ $da == 0 ]]; then
    exit 1
fi

exit 0