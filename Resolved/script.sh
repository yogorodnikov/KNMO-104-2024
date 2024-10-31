if [ $1 = "--help" -o $1 = "-h" ]; then
    echo 'This is SPRAVKA!!!'
    echo '\tThis is a script for converting an unlimited number of\n\tphotos into a collage of a given size.\n\tTo use, specify the size n x m,\n\talso specify the directory in which the script\n\tshould work and the name of the output file'
    exit 0
fi

arr1=( $(find $3 -type f -name "*.png" -o -name "*.jpeg" -o -name "*.jpg" | sort) )
arr2=()
count=0
for file in ${arr1[*]}; do
    if file "$file" | grep -qE 'image|bitmap|graphics'; then
        arr2+=($file)
        count=$[ $count + 1 ]
        if (( $count == $1 * $2 )); then
            break
        fi
    fi

done

if (( $count >= $1 * $2 )); then
    montage ${arr2[*]} -tile "$1x$2" -geometry +0+0 -extent 1:1 -scale 1000 "$3/$4.jpg"
    exit 0
else
    echo "Need more photo in directory"
    exit 1
fi

exit 0
