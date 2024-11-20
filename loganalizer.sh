if [ "$1" == "-h" -o "$1" == "--help" ]; then
	echo "$0 programm"
	echo "usage: $0 [log file]"
	echo "returns log file with requests which have request time less then 99th percentile"
	echo "idk why tho"
	exit 0
fi
if [ ! -e "$1" -o ! -f "$1" ]; then
	echo "error: no such directory or file doesnt exist"
	exit 1
fi

request_time=()
for req_time in $(cat "$1" | cut -d'|' -f5 | sort -n ); do
	request_time+=("$req_time")
done

log_quantity=${#request_time[@]}
percentile_position=$(echo "scale=0; 0.99 * $log_quantity / 1" | bc)
percentile=${request_time["$percentile_position"]}
output_log="output_log.log"
>"$output_log"

while IFS= read -r line; do
	if [[ $(echo "$line" | cut -d'|' -f5) -lt "$percentile" ]]; then
		echo "$line" >> "$output_log"
	fi
done < "$1"
exit 0
