#!/bin/bash

show_help() {
  echo "Использование: $0 [-f путь-к-логам] [-t временной-промежуток] [-m минуты]"
  echo "Примечание:"
  echo "Временной промежуток задаётся в формате: 'yyyy-mm-dd hh:mm:ss' "
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

while getopts "hf:t:m:" opt; do
  case $opt in
    f)
      logfile=$OPTARG
      ;;
    t)
      timestamp=$OPTARG
      ;;
    m)
      minutes=$OPTARG
      ;;
  esac
done

if [ -z "$logfile" ] || [ -z "$timestamp" ] || [ -z "$minutes" ]; then
  show_help
  exit 1
fi

if [ ! -f "$logfile" ]; then
  echo "Файл с логами не найден!"
  exit 1
fi

reference_time=$(date -d "$timestamp" +%s)
start_time=$(($reference_time - $minutes * 60))

output_file="filtered_logs.log"
> $output_file

while IFS='|' read -r level date ip source exec_time; do
  log_time=$(date -d "$date" +%s)
  if [ -z $log_time ]; then
    continue
  fi  
  if [ $log_time -ge $start_time ] && [ $log_time -le $reference_time ]; then
    echo "$level|$date|$ip|$source|$exec_time" >> $output_file
  fi
done < "$logfile"

sort -t '|' -k5,5n -k4,4 $output_file -o $output_file

echo "Filtered logs saved to $output_file"

exit 0