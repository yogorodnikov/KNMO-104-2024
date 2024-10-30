if test "$1" = "-h" -o "$1" = "--help"; then
	echo "$0 programm"
	echo "$0" makes collage with N collums and M rows
	echo usage: "$0" N M input_path output_file
	exit 0
fi
if [ ! -d "$3" ]; then
	echo error: no such directory
	exit 1
fi
images=()
for img in "$3"/*; do
	if file "$img" | grep -qE 'image data'; then
		images+=("$img")
	fi
done

images_in_directory=${#images[@]}

grid_size=$(($1*$2))
c=0

if test $grid_size -gt $images_in_directory; then
	echo error: not enough images
	exit 1
fi

if test $grid_size -le $images_in_directory; then
	mkdir -p "$3/temp"
	temp_dir="$3/temp"

	for img in "${images[@]}"; do
		convert "$img" -resize 512x512! "$temp_dir/$(basename "$img")"
		c=$((c + 1))
		if test "$c" -ge "$grid_size"; then
			break
		fi
	done
	montage "$temp_dir/*" -tile "${1}x${2}" -geometry +0+0 "$4"
	rm -rf "$temp_dir"
	exit 0
fi
