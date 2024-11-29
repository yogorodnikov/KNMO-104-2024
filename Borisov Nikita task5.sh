#!/bin/bash


usage() {
  echo "The program finds all first-level subdirectories that do not contain any open files."
  echo "Usage: $0 [-h|--help] || [-d|--directory DIRECTORY]"
  echo "If the directory is not specified, the current one will be used"
  exit 1
}



if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
usage
fi

if [[ "$1" == "-d" ]] || [[ "$1" == "--directory" ]];then
if [[ ! -d "$2" ]]; then
     echo "Directory '$2' does not exist or is not a valid directory."
     directory="."
else directory=$2
fi
fi



subdirs=($(find "$directory" -mindepth 1 -maxdepth 1 -type d))
count=0

for subdir in "${subdirs[@]}"; do
  open_files=($(lsof +D "$subdir"))
  
  
  if [[ ${#open_files[@]} -eq 0 ]]; then
    echo "$subdir"
    ((count++))
  fi
done


if [[ count == 0 ]]; then
  exit 1
fi

  



