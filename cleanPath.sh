#!/bin/bash
chmod +x cleanPath.sh

if [[ "$1" == "-h" || "$1" == "--help" ]]; then

  echo "Использование: $0 [-h|--help] [путь]"

  echo "Этот скрипт проверяет директории в PATH и выводит очищенный путь."

  exit 0

fi


if [ -z "$1" ]; then

  CHECK_PATH=$PATH

else

  CHECK_PATH=$1

fi



IFS=':' read -r -a DIRS <<< "$CHECK_PATH"


VALID_DIRS=()


for dir in "${DIRS[@]}"; do



  if [ -d "$dir" ]; then



found_executable=false

for file in "$dir"/*; do

  if [ -x "$file" ]; then

    found_executable=true

    break

  fi

done



if $found_executable; then

  VALID_DIRS+=("$dir")

fi

  

fi

done



declare -A UNIQUE_DIRS

for dir in "${VALID_DIRS[@]}"; do

  UNIQUE_DIRS["$dir"]=1

done



CLEANED_PATH=""

for dir in "${!UNIQUE_DIRS[@]}"; do

  if [ -z "$CLEANED_PATH" ]; then

    CLEANED_PATH="$dir"

  else

    CLEANED_PATH="$CLEANED_PATH:$dir"

  fi

done



echo "$CLEANED_PATH"
