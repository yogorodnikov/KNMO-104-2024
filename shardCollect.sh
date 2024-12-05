#!/bin/bash

directory="."

if [[ "$#" -gt 0 ]]; then
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -h|--help)
                echo "Использование: $0 [опции]"
                echo "Данная программа выводит все подкаталоги первого уровня, в которых нет ни одного открытого файла"
                echo "  -h, --help показать справку"
                echo "  -d, --directory указать директорию для поиска (по умолчанию используется текущая)"
                exit 0
                ;;
            -d|--directory)
                shift
                if [[ -n "$1" ]]; then
                    directory="$1"
                else
                    echo "Ошибка: Не указана директория."
                    exit 1
                fi
                ;;
            *)
                echo "Ошибка: Неизвестная опция '$1'. Используйте '-h' или '--help' для получения справки."
                exit 1
                ;;
        esac
        shift
    done
fi

open_files=$(lsof +D "$directory" | awk '{print $9}' | sort | uniq)

subdirs=$(find "$directory" -mindepth 1 -maxdepth 1 -type d)

found=false

for subdir in $subdirs; do
    if ! echo "$open_files" | grep -q "^$subdir$"; then
        echo "$subdir"
        found=true
    fi
done

if ! $found; then
	echo "Необходимые подкаталоги не найдены"
    exit 1
fi

exit 0
