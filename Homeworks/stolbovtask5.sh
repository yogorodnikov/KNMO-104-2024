#!/bin/bash

show_help() {
    echo "Использование: $0 [опции]"
    echo "Опции:"
    echo "  -h, --help          Показать это сообщение"
    echo "  -d, --directory     Указать директорию для поиска (по умолчанию текущая)"
}

directory="."

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) 
            show_help
            exit 0
            ;;
        -d|--directory) 
            directory="$2"
            shift
            ;;
        *) 
            echo "Неизвестная опция: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done

open_files=$(lsof +D "$directory" | awk '{print $9}' | sort -u)

find "$directory" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do

    if ! echo "$open_files" | grep -q "^$dir"; then
        echo "$dir"
    fi
done

if [[ $? -ne 0 ]]; then
    exit 1
fi

exit 0
