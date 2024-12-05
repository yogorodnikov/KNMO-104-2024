#!/bin/bash

direct="."


# Проверка на наличие аргументов
if [[ -z "$1" || -z "$2" ]]; then
    echo "Ошибка: все 2 аргумента должны быть указаны."
    exit 1
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Это программа для обнаружения всех неиспользующихся файлов в текущей директории"
        echo "Для того чтобы использовать, введи 3 параметра: <имя исполняемого файла> <-d или --directory> и саму <директорию>"
        echo "пример: bash Task4.sh -directory ./Your directory"
        exit 0
    fi

# Обработка параметров
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--directory)
            direct="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: \$1"
            exit 1
            ;;
    esac
done

# Проверка существования директории
if [[ ! -d "$direct" ]]; then
    echo "Ошибка: директория '$ditect' не существует."
    exit 1
fi

# Поиск подкаталогов и открытых файлов
sd=$(find "$direct" -maxdepth 1 -type d | tail -n +2)
of=$(lsof +D "$direct" | grep -o '[^ ]*')

found=0

# Проверка подкаталогов на открытость
for dir in $sd; do
    if ! echo "$of" | grep -q "^$dir$"; then
        echo "$dir"
        found=1
    fi
done

# Проверка, найдены ли неиспользуемые подкаталоги
if [[ $found -eq 0 ]]; then
    exit 1
fi

exit 0
