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

translation() {
    value="$1"
    
    
    # извлечение цифр
    digits="${value%%[!0-9.]*}"  # убираем все символы после цифр
    digits=$((digits))

    # извлечение букв
    letters="${value#$digits}"  # убираем цифры из начала строки

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
            echo "error"
            exit 1
            ;;
    esac
    digits=$(( $digits * $up_to ))
    #digits=$(printf "%.0f" "$digits")
    echo "$digits"
}
    
export LC_ALL=C

# построчное чтение файла
while IFS= read -r line; do
    # устанавливаем разделитель IFS на "=" и считываем в две переменные
    IFS='=' read -r key value <<< "$line"

    #echo "orig) $line"
    operation=""
    flag=0
    for_reg=$(echo "$line" | sed -E 's/[[:space:]]+/ /g; s/[()]//g')
    #for_reg=$(echo "$line" | sed -E 's/[[:space:]]+/ /g; s/[()]//g')
    if [[ -z "$for_reg" ]]; then
        continue
    fi

    # Проверка на единицы времени
    if [[ "$line" =~ ^([0-9]+)([[:space:]]*)(s|min|h|d)$ ]]; then
        # Проверка, что строка не содержит единиц длины или массы
        if [[ "$line" =~ [0-9]+[[:space:]]*(mm|sm|dm|m|km|mg|g|kg|t) ]]; then
            echo "incorrect input data"
            continue
        fi
    fi

    # Проверка на единицы длины
    if [[ "$line" =~ ^([0-9]+)([[:space:]]*)(mm|sm|dm|m|km)$ ]]; then
        # Проверка, что строка не содержит единиц времени или массы
        if [[ "$line" =~ [0-9]+[[:space:]]*(s|min|h|d|mg|g|kg|t) ]]; then
            echo "incorrect input data"
            continue
        fi
    fi

    # Проверка на единицы массы
    if [[ "$line" =~ ^([0-9]+)([[:space:]]*)(mg|g|kg|t)$ ]]; then
        # Проверка, что строка не содержит единиц времени или длины
        if [[ "$line" =~ [0-9]+[[:space:]]*(s|min|h|d|mm|sm|dm|m|km) ]]; then
            echo "incorrect input data"
            continue
        fi
    fi

    # Дополнительная проверка на сочетание разных единиц (например, длина и время)
    # Теперь мы проверяем только, если в строке присутствуют оба типа единиц: длина и время
    if [[ "$line" =~ [0-9]+[[:space:]]*(min) && "$line" =~ [0-9]+[[:space:]]*(m ) ]]; then
        echo "incorrect input data"
        continue
    fi
    
    if [[ "$line" =~ [0-9]+[[:space:]]*(mg) && "$line" =~ [0-9]+[[:space:]]*(m ) ]]; then
        echo "incorrect input data"
        continue
    fi

    if [[ "$line" =~ [0-9]+[[:space:]]*(dm) && "$line" =~ [0-9]+[[:space:]]*(d ) ]]; then
        echo "incorrect input data"
        continue
    fi



    
    elements=($(echo "$value" | tr " " "\n"))   # на это ругается шелчек, но я ничего лучше и работающего не нашёл
    #IFS=' ' read -ra elements <<< "$value"     # вот так надо писать, но у меня почему-то не работает(((

    # обработка элементов
    for ananas in "${elements[@]}"; do
        #echo "$ananas"
        case $ananas in
            "+")
                operation+="+"
                ;;
            "-")
                operation+="-"
                ;;
            "*")
                operation+="*"
                ;;
            "/")
                operation+="/"
                ;;
            "(")
                operation+="("
                ;;
            ")")
                operation+=")"
                ;;
            *)
                operation+=" "
                temp=$(translation "$ananas")
                if [[ $temp == "error" ]]; then
                    flag=1
                fi
                operation+=$temp
                operation+=" "
                ;;
        esac
    done

    operation+=" "  # добавляем пробел в конец строки operation для корректной обработки следующей части

    # преобразуем строку, заменяя двойные пробелы на +
    operation=$(echo "$operation" | sed 's/  / + /g')

    # оставляем только правую часть строки, которая уже не содержит цифры
    #echo "1) $operation"
    operation=$(echo "$operation" | grep -oE '.*[0-9]')
    #echo "2) $operation"
    # устанавливаем флаг flag1 в 0, чтобы отслеживать успешность вычислений
    flag1=0

    # динамическая строка для вычислений:
    # подаем строку операции в bc (калькулятор) -l (-l включает дроби)
    # если возникла ошибка, flag1 становится равным 1
    result=$(echo "$operation" | bc -l 2>/dev/null) || flag1=1

    # форматируем результат, проверяя, является ли оно целым числом:
    # если результат целый, выводим как целое число
    # если результат с плавающей точкой, выводим его с 6 знаками после запятой
    result=$(echo "$result" | LC_NUMERIC=C awk '{printf ($1 == int($1)) ? "%d\n" : "%.6f\n", $1}')

    # проверяем, были ли ошибки в вычислениях или в строках (flag == 0 и flag1 == 0)
    if [[ $flag == 0 && $flag1 == 0 ]]; then
        echo "$key=$result"
    else
        echo "fix expression"
    fi


done < "$file"