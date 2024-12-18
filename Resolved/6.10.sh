#!/bin/bash

case "$1" in
    -h|--help)
        echo "This is SPRAVKA!!!"
        echo "$0 is a script for bringing configuration
files into a form that is digestible for programs
example:
     >> $0 -h                           // to get help
     >> $0 specify/the/directory/here   // to processing specified by you"
        exit 0
        ;;
    -o)
        file="config.conf" # для упрощения отладки
        ;;
    
    *)
        file=$1
        ;;

esac

# Построчное чтение файла
while IFS= read -r line; do

    # Устанавливаем разделитель IFS на "=" и считываем в две переменные
    IFS='=' read -r key value <<< "$line"
    
    # Проверка строки на соответствие регулярному выражению
    if ! [[ $line =~ ^[a-zA-Z]+=[0-9]+(\.[0-9]+)?(s|min|h|d|mm|cm|dm|m|km|mg|g|kg|t)?$ ]]; then
        continue
    fi
    # Извлечение цифр
    digits="${value%%[!0-9.]*}"  # Убираем все символы после цифр
    digits=$((digits))

    # Извлечение букв
    letters="${value#$digits}"  # Убираем цифры из начала строки

    case $letters in
        s)
            up_to=1
            ;;
        min)
            up_to=60
            ;;
        h)
            up_to=3600
            ;;
        d)
            up_to=86400
            ;;
        mm)
            up_to=0.001
            ;;
        cm)
            up_to=0.01
            ;;
        dm)
            up_to=0.1
            ;;
        m)
            up_to=1
            ;;
        km)
            up_to=1000
            ;;
        mg)
            up_to=0.000001
            ;;
        g)
            up_to=0.001
            ;;
        kg)
            up_to=1
            ;;
        t)
            up_to=1000
            ;;
        "")
            up_to=1
            ;;
        *)
            echo $line; continue
            ;;
    esac
    digits=$(( $digits * $up_to ))
    digits=$(echo "$digits" | LC_NUMERIC=C awk '{printf ($1 == int($1)) ? "%d\n" : "%.6f\n", $1}')
    
    echo "$key=$digits"
done < "$file"