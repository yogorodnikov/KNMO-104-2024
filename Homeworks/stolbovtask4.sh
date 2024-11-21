#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <log_file>"
    echo "Analyze the log file and create a new log file with filtered entries."
    exit 1
fi

log_file="$1"

if [[ ! -f "$log_file" ]]; then
    echo "Error: File '$log_file' not found."
    exit 1
fi

# Получение времени обработки запросов и нахождение 99-го перцентиля
mapfile -t exec_times < <(awk -F '|' '{print $5}' "$log_file" | tr -d ' ') # Извлечение exec_time в массив

# Сортировка значений времени выполнения и сохранение в новый массив
mapfile -t sorted_exec_times < <(printf '%s\n' "${exec_times[@]}" | sort -n) # Сортировка и загрузка в новый массив

count=${#sorted_exec_times[@]}
percentile_index=$((count * 99 / 100)) # Индекс 99-го перцентиля

if [[ $percentile_index -gt 0 ]]; then
    percentile_value=${sorted_exec_times[$percentile_index]} # Значение 99-го перцентиля
else
    echo "No execution times found."
    exit 1
fi

echo "99th percentile execution time: $percentile_value"

# Фильтрация и форматирование записей
output_file="filtered_logs.txt"
echo "" > "$output_file" # Очистка выходного файла

while IFS='|' read -r level date ip source exec_time; do
    level=$(echo "$level" | xargs) # Удаление пробелов
    date=$(echo "$date" | xargs)
    ip=$(echo "$ip" | xargs)
    source=$(echo "$source" | xargs)
    exec_time=$(echo "$exec_time" | xargs)

    level=$(printf "%-6s" "$level")
    ip=$(printf "%-15s" "$ip")

    if (( exec_time < percentile_value )); then
        printf "%s | %s | %s | %s | %d\n" "$level" "$date" "$ip" "$source" "$exec_time" >> "$output_file"
    fi
done < <(tail -n +2 "$log_file") # Пропуск заголовка (если есть)

sort -k5,5n -k4,4 "$output_file" -o "$output_file"

echo "Filtered logs saved to '$output_file'."
