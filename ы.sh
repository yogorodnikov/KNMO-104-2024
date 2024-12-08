#!/bin/bash

cur=$(pwd)
dirs=()
opd=()
f=0

case "$1" in
    -h|--help)
        echo "Дорогой читатель. Эта хрень выводит неиспользуемые директории."
	echo "$0 -h/--help показывает то, где мы есть.
$0 работает в текущей директории
$0 (полный путь до директории) работает в указанной директории"
        ;;
    -d|--dir)
        cur="$2"
        shift 2
        ;;
    *)
        echo "не надо так"
        exit 1
        ;;
esac

while IFS= read -r file; do
    opd+=("$file")
done < <(lsof +D "$cur" 2>/dev/null | awk '{print $9}')

while IFS= read -r dr; do
    dirs+=("$dr")
done < <(find "$cur" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

for dr in "${dirs[@]}"; do
    u=false
    for fl in "${opd[@]}"; do
        if [[ "$dr" == "$(dirname "$fl")" ]]; then
            u=true
            break
        fi
    done
    if ! $u; then
        echo "$dir"
        f=1
    fi
done

if [[ $f == 0 ]]; then
    exit 1
fi

exit 0
