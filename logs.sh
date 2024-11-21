#!/bin/bash

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	echo "Входящие параметры :"
	echo "Файл с логами"
	echo "Выходной файл"
	echo "Функция скрипта"
	echo "Нахождение трех самых популярных ресурсов на сервере. "	
	echo "Запись  в новый файл с  логами ресурсов которые соответствуют требованиям."
fi
# Проверка на наличие входного файла
if [ -z  "$1"  ]; then
    echo "Первый аргумент пустой . Передайте пожалуйста файл с логами."
    exit 1
fi

log_file="$1"
output_file="$2"
declare -A request_count

while read -r line; do
    resource=$(echo "$line" | awk -F'|' '{print $4}') # Извлечение ресурса из строки лога
    if [ -n "$resource" ]; then # Проверка на непустой ресурс
        ((request_count["$resource"]++))
    fi
done < "$log_file"

# Сортировка ресурсов по количеству запросов и выбор трех самых популярных
popular_resources=$(for resource in "${!request_count[@]}"; do
    echo "${request_count[$resource]} $resource"
done | sort -nr | awk '{print $2}' | uniq | head -n 3)

# Запись всех записей, соответствующих популярным ресурсам в новый файл
while read -r line; do
    for resource in $popular_resources; do
        if [[ "$line" == *"$resource"* ]]; then
            echo "$line" >> "$output_file"
            break # Прекращаем поиск по остальным ресурсам, если нашли совпадение
        fi
    done
done < "$log_file"

echo "Записи по самым популярным ресурсам сохранены в $output_file."


