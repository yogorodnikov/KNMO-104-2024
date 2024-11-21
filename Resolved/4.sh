#!/bin/bash

stTime=$(date +%s) # засекаем время начала выполнения программы
# путь к файлу
if [ -z $1 ]; then
    echo "Wrong call! Try call help, example:\n     >> $0 --help" || exit 1
    exit 2
else
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This is SPRAVKA!!!"
        echo "\tA script for converting logs (selecting all those that\n\ttook more than 99 minutes to complete and\n\twriting from to a new file)\n\tExample of a call\n     >> $0 input.log output.log\n     >> $0 --help"
        exit 0
    else
        if [ -z $2 ]; then
            echo "Need second argument ( targetfile )"
            exit 3
        else
            filename=$1 || exit 1
            targetfile=$2 || exit 1
        fi
    fi
fi

echo -n > $targetfile # создаём/пересоздаём пустой файл

# -F указывает разделитель, принт 5 это печатать 5 колонку
# -n в сортировке это что бы по величине цифр сортировала
procental99=$(awk -F'|' '{print $5}' $filename | sort -n | awk '{ 
    a[NR] = $1
} END {
    x = int((99 / 100) * (NR - 1)) + 1
    print a[x]
}')
# в массив а записываем на последнюю позицию (NF) времена выполнения запросов
# потом в конце считаем х по формуле честно взятой с интернета и получаем значение на этой позиции
# NR - это кол-во строк. это работает из-за того что мы просто берём в sort массиве число
# позиция которо соответствует 99% длины массива

echo $procental99 # для отладки

# чтение файла построчно ( разделитель пустой, read - читает строчки из файла
# -r отключает интрепретацию "\" )    ^
while IFS= read -r line             # |
do
    time=$(echo "$line" | awk -F'|' '{print $5}') # -F указывает разделитель, принт 5 это печатать 5 колонку
    # здесь можно обработать каждую строку
    if (( $time > procental99 )); then
        echo $line >> $targetfile # пишем в файл
    fi
done < "$filename" # указывает что стандартный ввод для команды read будет
                   # поступать не с клавиатуры, а из файла



endTime=$(date +%s) # завершаем считать время выполнения программы
echo "done with $((endTime - stTime))s" # говорим что готово и время, за которе выполнили программу



# ето прототип типа
# Цикл по всем запросам в логах
#   Найти 99 перцентиль по времени обработки запроса
# Цикл по всех запросам в логах
#   Включить в новые логи только те, у которых время обработки которых меньше найденного прецентиля
