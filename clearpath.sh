if [ "$1" == "-h" -o "$1" == "--help" ]; then
	echo "$0 programm prints PATH variable without unexecutable and unexisting files and directories"
	echo "usage: $0 [directory] (will check only your directories) or $0 (will check PATH variable)"
	exit 0
fi
dir=$PATH
dir="$dir:this/is/fake/directory"
if [ "$#" -gt 0 ]; then
	dir="$1"
fi
output_dirs=()
IFS=:
for file in $dir; do
	if [ -d "$file" -a -x "$file" ]; then
		output_dirs+=("$file")
	fi
done
for i in "${output_dirs[@]}"; do
	echo "$i"
done
exit 0
