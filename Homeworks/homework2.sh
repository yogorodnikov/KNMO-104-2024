#!/bin/bash

# Отображение справки
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Использование: $0 <папка_с_изображениями> <длительность_анимации> <выходной_gif>"
  echo "Конвертировать все .jpg изображения в папке в черно-белые и создать анимированный GIF."
  exit 0
fi

# Проверка входных параметров
if [[ $# -ne 3 ]]; then
  echo "Ошибка: необходимо передать три аргумента."
  echo "Использование: $0 <папка_с_изображениями> <длительность_анимации> <выходной_gif>"
  exit 1
fi

IMAGE_DIR="$1"
ANIMATION_DURATION="$2"
OUTPUT_GIF="$3"

# Проверка существования папки
if [[ ! -d "$IMAGE_DIR" ]]; then
  echo "Ошибка: папка '$IMAGE_DIR' не существует."
  exit 1
fi

# Проверка наличия .jpg файлов в папке
IMAGE_COUNT=$(ls "$IMAGE_DIR"/*.jpg 2>/dev/null | wc -l)
if [[ "$IMAGE_COUNT" -eq 0 ]]; then
  echo "Ошибка: в папке нет .jpg файлов."
  exit 1
fi

# Конвертация изображений в черно-белые и сохранение их во временную папку
TEMP_DIR=$(mktemp -d)
for IMAGE in "$IMAGE_DIR"/*.jpg; do
  BASENAME=$(basename "$IMAGE")
  convert "$IMAGE" -colorspace Gray "$TEMP_DIR/$BASENAME"
done

# Расчет времени показа каждого изображения (в миллисекундах)
DISPLAY_TIME=$(echo "$ANIMATION_DURATION * 1000 / $IMAGE_COUNT" | bc)

# Создание анимированного GIF
convert -delay "$DISPLAY_TIME" -loop 0 "$TEMP_DIR"/*.jpg "$OUTPUT_GIF"

# Очистка временной папки
rm -r "$TEMP_DIR"

echo "GIF успешно создан: $OUTPUT_GIF"