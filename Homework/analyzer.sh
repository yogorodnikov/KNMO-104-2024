#!/bin/bash

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "$0 записывает из исходного файла в файл для сохранения все записи, совершенные за указанное количество минут до указанного времени"
  echo
  echo "Использование: $0 <log_file> <output_file> <ref_time> <minutes>"
  echo "  log_file     - исходный файл логов в формате level|date|ip|source|exec_time"
  echo "  output_file  - файл для сохранения результата"
  echo "  ref_time     - время начала фильтрации в формате 'YYYY-MM-DD HH:MM:SS'"
  echo "  minutes      - количество минут до ref_time для фильтрации"
  echo
  echo "Пример:"
  echo "  $0 input.log output.log '2019-10-03 21:12:00' 10"
  exit 0
fi

if [ "$#" -ne 4 ]; then
  echo "Ошибка: Неверное количество аргументов."
  exit 1
fi

log_file=$1
if [ ! -f "$log_file" ]; then
  echo "Ошибка: Файл '$log_file' не существует."
  exit 1
fi

out_file=$2
ref_time=$3
if ! [[ "$ref_time" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] || ! date -d "$ref_time" > /dev/null 2>&1; then
  echo "Ошибка: Некорректный формат времени '$ref_time'. Используйте 'YYYY-MM-DD HH:MM:SS'."
  exit 1
fi

minutes=$4
if ! [[ "$minutes" =~ ^[0-9]+$ ]]; then
  echo "Ошибка: Количество минут должно быть целым числом."
  exit 1
fi

ref_epoch=$(date -d "$ref_time" +%s)
min_epoch=$((ref_epoch - minutes * 60))
 
awk -F'|' -v ref="$ref_epoch" -v min="$min_epoch" '
{
  split($2, datetime, " ")
  split(datetime[1], date_parts, "-")
  split(datetime[2], time_parts, ":")
 
  year = date_parts[1]
  month = (length(date_parts[2]) == 1 ? "0" date_parts[2] : date_parts[2])
  day = (length(date_parts[3]) == 1 ? "0" date_parts[3] : date_parts[3])
 
  log_epoch = mktime(year " " month " " day " " time_parts[1] " " time_parts[2] " " time_parts[3])
 
  if (log_epoch >= min && log_epoch <= ref) {
    print $0
  }
}' "$log_file" | sort -t '|' -k5,5n -k4,4 > "$out_file"
 
echo "Фильтрация и сортировка завершены. Результаты сохранены в $out_file"

