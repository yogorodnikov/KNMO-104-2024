#!/bin/bash
if [ -z $1 ]; then
    DIR=$PATH || exit 1
else
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This is SPRAVKA!!!"
        echo "\tIt is used to output non-empty directories of the\n\tglobal variable PATH to the second standard stream\n\t(instead PATH, you can specify else).\n\tformat for specifying other paths: /dir1:/dir2\n\tcalling help by -h or --help\n\n\tLaunch example_1: $0\n\texample_2: $0 /bin:/temp"
    else
        DIR=$1 || exit 1
    fi
fi

declare -a arr=()
declare -a ver_arr=()
declare -a arr_of_files=()

function whoIsNewer() {
    version1=$("$1" --version 2>/dev/null | awk '{print $NF}')
    version2=$("$2" --version 2>/dev/null | awk '{print $NF}')

    if [[ -z "$version1" ]]; then
        return 1; fi

    if [[ -z "$version2" ]]; then
        return 1; fi

    # Сравнение версий
    if [[ "$version1" == "$version2" ]]; then
        return 2
    elif [[ "$(echo -e "$version1\n$version2" | sort -V | head -n1)" == "$version1" ]]; then
        return 0
    else
        return 3; fi
}

echo "$DIR" | tr ':' '\n' | while read -r dir; do
    cd "$dir" 2>/dev/null || continue
    count=0
    # if ls * &>/dev/null; then
    if [ -n "$(ls -A . 2>/dev/null)" ]; then
        find . -type f | while read -r file; do
            if [[ -x "$file" ]]; then
                (( count+=1 ))
                arr_of_files+=( "$dir${file:1}" )
                # arr_of_files[${#arr_of_files[@]}]=$( $dir${file:1} )
                now_file=$file
            fi
        done
        if (( $count == 1 )); then
            ver_arr+=( "$dir${now_file:1}" )
        elif (( $count > 1 )); then
            arr+=( "$dir" )
        fi
    fi
done

# вывод всех путей, где более одного файла
for item in "${arr[@]}"; do
    echo "$item"
done

# вывод путей где один файл, если он новейший
for item in "${ver_arr[@]}"; do
    name=$item
    for file in "${arr_of_files[@]}"; do
        if [[ `basename "$name"` == `basename "$file"` ]]; then
            if whoIsNewer $file $name ; then
                name=$file
            fi
        fi
    done
    if [[ "$name" == "$item" ]]; then
        echo "$item"
    fi
done
