#!/bin/bash

# Функция для отображения справки
show_help() {
    echo "Использование: $0 [опции]"
    echo "Опции:"
    echo "  -h, --help          Показать это сообщение"
    echo "  -d, --directory     Указать директорию для поиска (по умолчанию текущая)"
}

# Инициализация переменной для директории
directory="."

# Обработка аргументов командной строки
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

# Получение списка открытых файлов с помощью lsof
open_files=$(lsof +D "$directory" | awk '{print $9}' | sort -u)

# Поиск подкаталогов первого уровня в указанной директории
find "$directory" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
    # Проверка, есть ли открытые файлы в подкаталоге
    if ! echo "$open_files" | grep -q "^$dir"; then
        echo "$dir"
    fi
done

# Установка кода возврата, если ничего не найдено
if [[ $? -ne 0 ]]; then
    exit 1
fi

exit 0
