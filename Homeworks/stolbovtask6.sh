#!/bin/bash

# Проверка наличия аргумента
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <имя конфигурационного файла>"
    echo "Пример конфигурационного файла:"
    echo "time=4s"
    echo "distance=8m"
    echo "longtime=15h"
    echo "weight=42g"
    echo "Допустимые единицы измерения:"
    echo "  • Время: s, min, h, d"
    echo "  • Расстояние: mm, sm, dm, m, km"
    echo "  • Вес: mg, g, kg, t"
    exit 1
fi

config_file="$1"

# Проверка существования файла
if [ ! -f "$config_file" ]; then
    echo "Файл '$config_file' не найден!"
    echo "Использование: $0 <имя конфигурационного файла>"
    echo "Пример конфигурационного файла:"
    echo "time=4s"
    echo "distance=8m"
    echo "longtime=15h"
    echo "weight=42g"
    echo "Допустимые единицы измерения:"
    echo "  • Время: s, min, h, d"
    echo "  • Расстояние: mm, sm, dm, m, km"
    echo "  • Вес: mg, g, kg, t"
    exit 1
fi

# Функция для нормализации времени
normalize_time() {
    local value="$1"
    local unit="$2"
    
    case "$unit" in
        s) echo "$value" ;;
        min) echo "$(echo "$value * 60" | bc)" ;;
        h) echo "$(echo "$value * 3600" | bc)" ;;
        d) echo "$(echo "$value * 86400" | bc)" ;;
        *) echo "Неподдерживаемая единица времени: $unit"; exit 1 ;;
    esac
}

# Функция для нормализации расстояния
normalize_distance() {
    local value="$1"
    local unit="$2"
    
    case "$unit" in
        mm) echo "$(echo "$value / 1000" | bc)" ;;
        sm) echo "$(echo "$value / 100" | bc)" ;;
        dm) echo "$(echo "$value / 10" | bc)" ;;
        m) echo "$value" ;;
        km) echo "$(echo "$value * 1000" | bc)" ;;
        *) echo "Неподдерживаемая единица расстояния: $unit"; exit 1 ;;
    esac
}

# Функция для нормализации веса
normalize_weight() {
    local value="$1"
    local unit="$2"
    
    case "$unit" in
        mg) echo "$(echo "$value / 1000000" | bc)" ;;
        g) echo "$(echo "$value / 1000" | bc)" ;;
        kg) echo "$value" ;;
        t) echo "$(echo "$value * 1000" | bc)" ;;
        *) echo "Неподдерживаемая единица веса: $unit"; exit 1 ;;
    esac
}

# Чтение конфигурационного файла и нормализация значений
while IFS='=' read -r key value; do
    unit="${value: -2}" # последние две буквы - это единица измерения
    number="${value%$unit}" # все кроме последних двух букв - это число

    case "$key" in
        time|longtime)
            normalized_value=$(normalize_time "$number" "$unit")
            echo "$key=$normalized_value"
            ;;
        distance)
            normalized_value=$(normalize_distance "$number" "$unit")
            echo "$key=$normalized_value"
            ;;
        weight)
            normalized_value=$(normalize_weight "$number" "$unit")
            echo "$key=$normalized_value"
            ;;
        *)
            echo "Неизвестный параметр: $key"
            ;;
    esac
done < "$config_file"
