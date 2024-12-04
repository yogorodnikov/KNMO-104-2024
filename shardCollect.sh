c=0
directory="."
case $1 in
	"-h"|"--help")
		echo "$0 programm"
		echo "usage $0 -d [DIRECTORY]"
		exit 0
		;;
	"-d"|"--directory")
		if [ ! -d "$2" ]; then
			echo "error: couldn't find this directory"
			exit 1
		fi
		directory="$2"
		;;
	"")
		directory="."
		;;
	*)
		echo "try $0 -h or $0 --help to see usage"
		exit 1
		;;
esac
for dir in "$directory"/*; do
	if ! lsof +D "$dir" &>/dev/null; then
		if [ -d "$dir" ]; then
			echo "$dir"
			c=$((c + 1))
	fi
fi
done
if [ "$c" -lt 1 ]; then
	exit 1
fi
exit 0
