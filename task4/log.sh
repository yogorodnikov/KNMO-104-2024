#!/bin/bash


usage() {
  echo "Usage: $0 [-h|--help] FILENAME"
  exit 1
}


if [[ "$#" == 0 ]]; then
  usage
fi

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
usage
fi

if [[ ! -f "$1" ]]; then
        echo "Error: File '$1' does not exist or is not readable."
        exit 1
      fi
LOGFILE="$1"




if [[ -z "${LOGFILE}" ]]; then
  echo "Error: No logfile specified."
  usage
fi


PERCENTILE=$(awk '{print $NF}' "$LOGFILE" | sort -n | awk '{
  lines[NR]=$1
} END {
  print lines[int(NR*0.99)]
}')


NEW_LOGFILE="${LOGFILE%.txt}_filtered.txt"
awk -v percentile="$PERCENTILE" '$NF <= percentile {print $0}' "$LOGFILE" > "$NEW_LOGFILE"

echo "New log file created: ${NEW_LOGFILE}"

