#!/bin/bash

target_dir="."

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            echo "Скрипт показывает подкаталоги (первого уровня) заданной директории, в которых нет открытых файлов."
            echo "Использование: $0 -d|--directory <путь к директории>"
            exit 0
            ;;
        -d|--directory)
            target_dir="$2"
            shift 2
            ;;
        *)
            echo "Ошибка: неизвестный ключ '$1'."
            exit 1
            ;;
    esac
done

if [[ ! -d "$target_dir" ]]; then
  echo "Ошибка. Директория не существует"
  exit 1
fi

opened=$(lsof +D "$target_dir" | grep -o '[^ ]*')
subd=$(find "$target_dir" -mindepth 1 -maxdepth 1 -type d)

flag=1

for d in $subd; do
    if ! echo "$opened" | grep -q "^$d$"; then
        echo "$d"
        flag=0
    fi
done

exit $flag