#!/bin/bash

# Проверка параметров

if [[ $1 == '-h' || $1 == '--help' ]]; then

  echo "Использование: $0 <директория> <ширина> <высота> <имя_файла.pdf>"

  exit 0

fi

# Параметры

DIR=$1

MIN_WIDTH=$2

MIN_HEIGHT=$3

PDF_NAME=$4

# Проверка существования директории

if [ ! -d "$DIR" ]; then

  echo "Директория не найдена!"

  exit 1

fi

# Получаем максимальные размеры изображений

MAX_WIDTH=0

MAX_HEIGHT=0

for IMAGE in "$DIR"/*; do

  # Проверка, является ли файл изображением

  if file "$IMAGE" | grep -qE 'image|bitmap'; then

    WIDTH=$(identify -format "%w" "$IMAGE")

    HEIGHT=$(identify -format "%h" "$IMAGE")

    if [[ $WIDTH -ge $MIN_WIDTH && $HEIGHT -ge $MIN_HEIGHT ]]; then

      if (( WIDTH > MAX_WIDTH )); then

        MAX_WIDTH=$WIDTH

      fi

      

      if (( HEIGHT > MAX_HEIGHT )); then

        MAX_HEIGHT=$HEIGHT

      fi

    fi

  fi

done

# Изменяем размер изображений и создаем список файлов для PDF

TEMP_FILES=()

for IMAGE in "$DIR"/*; do

  if file "$IMAGE" | grep -qE 'image|bitmap'; then

    WIDTH=$(identify -format "%w" "$IMAGE")

    HEIGHT=$(identify -format "%h" "$IMAGE")

    if [[ $WIDTH -ge $MIN_WIDTH && $HEIGHT -ge $MIN_HEIGHT ]]; then

      OUTPUT_IMAGE="${IMAGE%.*}_resized.jpg"

      # Изменение размера изображения

      convert "$IMAGE" -resize "${MAX_WIDTH}x${MAX_HEIGHT}!" "$OUTPUT_IMAGE"

      TEMP_FILES+=("$OUTPUT_IMAGE")

    fi

  fi

done

# Создаем PDF

if [ ${#TEMP_FILES[@]} -gt 0 ]; then

  # Объединение изображений в один PDF

  convert "${TEMP_FILES[@]}" "$PDF_NAME"

  echo "Создан PDF файл: $PDF_NAME"

else

  echo "Нет подходящих изображений."

fi

# Удаляем временные файлы

for TEMP_FILE in "${TEMP_FILES[@]}"; do

  rm -f "$TEMP_FILE"

done
