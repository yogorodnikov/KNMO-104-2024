#!/bin/bash

function show_help() {
    echo "Использование: $0 [-h] [-d directory] [--help] [--directory directory]"
    echo "-d | --directory - указывает директорию."
    echo "-h | --help - вывод справки об использовании."
    echo Примечание: если обрабатываемая директория не указана, то программа будет использовать текущую.
    exit 0
}

DIRECTORY=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        (-h|--help) show_help ;;
        (-d|--directory) DIRECTORY="$2"; shift ;;
        (*) echo "Неизвестный параметр: $1"; exit 1 ;;
    esac
    shift
done


if [ -z "${DIRECTORY}" ]; then
    DIRECTORY=$(pwd)
fi

OPEN_DIRS=$(lsof +D "$DIRECTORY" 2>/dev/null | sort | uniq)

for dir in "$DIRECTORY"/*; do
    if [ -d "$dir" ]; then
        if ! echo "$OPEN_DIRS" | grep "^$dir$"; then
            echo "$dir"
            RESULT=1
        fi
    fi
done

exit $RESULT    