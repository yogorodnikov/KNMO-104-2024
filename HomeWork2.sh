#!/bin/bash

DIRECTORY="$1"
Time="$2"
outputFile="$3"

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Использование: Директория, Время, Результат"
    echo
    echo "Параметры:"
    echo "Директория-Путь к папке с изображениями"
    echo "Время показа всего gif" 
    echo "Результат-Имя выходного файла в формате gif"
    exit 0
fi

# Проверка входящих параметров
if [ -z "$DIRECTORY" ]; then
    echo "Пожалуйста, укажите директорию."
    exit 1
fi
# Проверка правильности начальному параметру
if ! [ -d "$DIRECTORY" ]; then
    echo "Ошибка: Указанная директория не существует."
    exit 1
fi

files=($(ls "$DIRECTORY"/* 2>/dev/null | sort))

images=()
for image in "${files[@]}"; do
    typeFile=$(file --mime-type -b "$image")
    if [[ "$typeFile" == image/* ]]; then
        images+=("$image")
    else
        echo "Внимание: файл $image не является изображением"
    fi
done

convert -colorspace GRAY -extent 4:3 -scale 1000 -delay "$Time" "${images[@]}" "./$3" || exit 1

echo   "Анимированный GIF сохранён как: $outputFile"
