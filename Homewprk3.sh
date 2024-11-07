#!/bin/bash

# Получаем путь для проверки
if [[ "$1" = "-h" || "$1" = "--help" ]]; then
	echo "Передаваемые параметры"

	echo "Директория/-h;--help/пустой параметр."
	echo "Условия работы."

	echo "Если передается пустой параметр то работаем с PATH."
	echo "Eсли передается наша директория работаем с ней."
fi
DIRECTORY=()
if [[ -n "$1" ]]; then
   DIRECTORY+=("$1")
  else
      for dir in $PATH; do
        DIRECTORY+=("$dir")
done
fi
IFS=':' read -ra DIRECTORY <<< "${DIRECTORY[@]}"

# Убираем дублирующиеся пути и сортируеvm
unique_paths=($(printf "%s\n" "${DIRECTORY[@]}" | awk '!seen[$0]++'))

# Проверяем директории и собираем валидные
pid=()
for direct in "${unique_paths[@]}"; do
	for file in "$direct"/*; do
	    if [[ -x "$file" ]]; then
      		pid+=("$direct")
		break
    fi
done
done

# Выводим очищенный PATH
IFS=':'
echo "${pid[*]}"



