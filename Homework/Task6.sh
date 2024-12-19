#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "недостаточно аргументов"
    exit 1
fi

if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "Программа принимает имя файла в котором данные записаны в следующем формате:"
    echo "time=4s"
    echo "distance=8m"
    echo "longtime=15h"
    echo "weight=42g + 6kg"
    echo
    echo "Скрипт выводит конфиг, где все единицы приведены к одному измерению"
    exit 0
fi

if [[ ! -f $1 ]]; then
    echo "файл '$1' не существует"
    exit 1
fi

fname="$1"

lnum=0
while IFS="" read line; do
    lnum=$((lnum + 1))
    if [[ $line =~ ^([a-zA-Z]+)=(.*)$ ]]; then
  key=${BASH_REMATCH[1]}
  value=${BASH_REMATCH[2]}
  newvalue=$(echo "$value" | tr -d '[:space:]')

  if [[ $newvalue =~ ^\(*[0-9]+(h|s|min|d)[\(\)]*((-|\+|\*|/)*[\(\)]*[0-9]+(h|s|min|d))*\)*$ ]]; then
        typ="time"
  elif [[ $newvalue =~ ^\(*[0-9]+(mm|sm|dm|m|km)[\(\)]*((-|\+|\*|/)*[\(\)]*[0-9]+(mm|sm|dm|m|km))*\)*$ ]]; then
        typ="distance"
  elif [[ $newvalue =~ ^\(*[0-9]+(mg|g|kg|t)[\(\)]*((-|\+|\*|/)*[\(\)]*[0-9]+(mg|g|kg|t))*\)*$ ]]; then
        typ="weight"
  else
        echo "Некорректные единицы измерения '$key' в строке $lnum"
        exit 1
  fi

  if [[ $typ == "time" ]]; then
    itog=$(echo "$value" | sed -E '
          s/([0-9]+)s/\1/g;
          s/([0-9]+)min/\1*60/g;
          s/([0-9]+)h/\1*3600/g;
           s/([0-9]+)d/\1*86400/g;
    ')

  elif [[ $typ == "distance" ]]; then
    itog=$(echo "$value" | sed -E '
          s/([0-9]+)dm/\1*0.1/g;
          s/([0-9]+)km/\1*1000/g;
          s/([0-9]+)sm/\1*0.01/g;
          s/([0-9]+)mm/\1*0.001/g;
          s/([0-9]+)m/\1/g;
    ')

  else
    itog=$(echo "$value" | sed -E '
          s/([0-9]+)mg/\1*0.000001/g;
          s/([0-9]+)kg/\1/g;
          s/([0-9]+)g/\1*0.001/g;
          s/([0-9]+)t/\1*1000/g;
    ')
  fi

  res=$(echo "$itog" | bc -l 2>/dev/null)

  if [[ $? -ne 0 || -z $res ]]; then
        echo "Некорректное значение '$key' в строке $lnum"
  else
        echo "$key=$res"
  fi
    else
        echo "Ошибка в строке $lnum: неверный синтаксис"
    fi
done < "$fname"
