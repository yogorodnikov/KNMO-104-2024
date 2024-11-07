#!/bin/bash

# Функция для вывода справки
function show_help {
    echo "Использование: $0 [-h|--help] [путь]"
    echo "Проверяет директории в PATH на наличие исполняемых файлов."
}

# Проверка на наличие аргументов
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Определение переменной для проверки
if [[ -n "$1" ]]; then
    PATH_TO_CHECK="$1"
else
    PATH_TO_CHECK="$PATH"
fi

# Инициализация массива для хранения уникальных путей
declare -A unique_paths

# Очищенный путь для вывода
cleaned_path=""

# Разделение PATH на директории и проверка каждой директории
IFS=':' read -r -a directories <<< "$PATH_TO_CHECK"
for dir in "${directories[@]}"; do
    # Проверка существования директории и наличия исполняемых файлов
    if [[ -d "$dir" ]]; then
        # Поиск исполняемых файлов в директории
        executables=($(find "$dir" -maxdepth 1 -type f -executable))
        
        # Если есть исполняемые файлы, добавляем путь в cleaned_path
        if [[ ${#executables[@]} -gt 0 ]]; then
            unique_paths["$dir"]=1  # Добавляем путь в ассоциативный массив для уникальности
        fi
    fi
done

# Формируем очищенный PATH без дубликатов
for path in "${!unique_paths[@]}"; do
    cleaned_path+="$path:"
done

# Удаляем последний символ ":" если он есть
cleaned_path=${cleaned_path%:}

# Вывод очищенного PATH
echo "$cleaned_path"
