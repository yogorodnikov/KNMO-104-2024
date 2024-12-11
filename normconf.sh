if [ "$1" == "-h" -o "$1" == "--help" ]; then
 echo "this programm normalize your config"
 echo "so all units of measurment will be"
 echo "converted to SI"
 echo
 echo "usage: $0 [config_file]"
 echo
 echo "config example: [any_set_of_english_letters]=[number][unit]"
 echo "units that are allowed in config:"
 echo "time: s - seconds, min - minutes, h - hours, d - days"
 echo "distance: mm - millimeters, sm - centimeters, dm - decimeters, m - meters, km - kilometers"
 echo "mass: mg - miligrams, g - grams, kg - kilograms, t - tons"
 echo
 echo "ariphmetical calculatoins are also allowed in config"
 echo "you can use + - / * and ( )"
 echo "example: [any_set_of_english_letters]=[value1][unit] [math_action] [value2][unit]"
 echo "make sure to do math actions with the same type of physical values"
 echo "if operation was not specified, numbers add up by default: 4min 4s <=> 4min + 4s"
fi
if [ "$1" == "" ]; then
 echo "error: config file was not specified"
 echo "try $0 --help to see usage"
fi
if [ ! -f "$1" ]; then
 echo "error: couldn't find config file"
fi
error="none"
isSameType(){
 func_line=$(echo "$1" | sed -e 's/[^a-zA-Z ]//g')
 type="none"
 prev_type="none"
 for unit in $func_line; do
  case "$unit" in
  "s"|"min"|"h"|"d")
   type="time"
   ;;
  "mm"|"sm"|"dm"|"m"|"km")
   type="distance"
   ;;
  "mg"|"g"|"kg"|"t")
   type="mass"
   ;;
  *)
   error="error: unsupported measurement unit: $unit"
   break
   ;;
  esac
  if [ "$prev_type" != "$type" ] && [ "$prev_type" != "none" ]; then
   error="error: different physical measures: $prev_type and $type"
   break
  fi
  prev_type="$type"
 done
}
temp_line=""
expression=""
output_line=""
line_number=1
while IFS= read -r line; do
 temp_line=$(echo "$line" | cut -d"=" -f2)
 isSameType "$temp_line"
 if [ "$error" != "none" ]; then
  echo "line $line_number: $error"
  error="none"
  line_number=$(($line_number + 1))
  continue
 fi
 line_number=$(($line_number + 1))
 expression=$(echo "$temp_line" | sed -e 's/t/ \* 1000/g; s/km/ \* 1000/g; s/s//g; s/min/ \* 60/g; s/h/ \* 3600/g; s/dm/ \* 0.1/g; s/d/ \* 86400/g; s/mm/ \* 0.001/g; s/sm/ \* 0.01/g; s/mg/ \* 0.000001/g; s/m//g; s/kg//g; s/g/ \* 0.001/g;')
 output_line=$(echo "$line" | cut -d"=" -f1)
 expression=$(echo "$expression" | sed -E 's/([0-9]+) ([0-9]+)/\1 + \2/g')
 expression=$(echo "$expression" | bc -l)
 output_line="$output_line"="$expression"
 echo "$output_line"
done < "$1"
