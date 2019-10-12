#! /bin/bash

verbose=0
random_ip_port=0
rule_count=10
out_file=./test.rules
pattern_range="5:40"

function show_help {
echo "
Usage: ./generate_rules.sh [options]

    -h                              show help
    -v                              verbose
    -R                              random rule ip, any if unset. default unset
    -n <rule_number>                set rule number, default $rule_count
    -o <output_filename>            set output file, default $out_file
    -r <min_length:max_length>      set pattern length range, default $pattern_range

"
}

function get_random_ip {
    printf "%d.%d.%d.%d" "$((RANDOM % 256))" "$((RANDOM % 256))" "$((RANDOM % 256))" "$((RANDOM % 256))"
}

cd "$(dirname $0)"

# Argument parsing
OPTIND=1

while getopts "h?vRn:o:r:" opt; do
    case "$opt" in
        h|\?)
            show_help
            exit 0
            ;;
        v)  verbose=1
            ;;
        R)  random_ip_port=1
            ;;
        n)  rule_count=$OPTARG
            ;;
        o)  out_file=$OPTARG
            ;;
        r)  pattern_range=$OPTARG
            ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--"  ] && shift

if [[ $@ != '' ]] ; then
    echo "Unknown argument $@!" >&2; show_help; exit 1
fi

if ! [[ $rule_count =~ ^[0-9]+$ ]] ; then
    echo "$rule_count is not a number!" >&2; show_help; exit 1
fi

IFS=':' read -ra range <<< "$pattern_range"
range_l="${range[0]}"
range_h="${range[1]}"

if ! [[ $range_l =~ ^[0-9]+$ && $range_h =~ ^[0-9]+$ ]] ; then
    echo "Unavailable range $pattern_range!" >&2; show_help; exit 1
fi

if [[ $range_l -lt 2 ]] ; then
    echo "Pattern must be longer than 2!" >&2; show_help; exit 1
fi

if [[ $range_h -gt 1000 ]] ; then
    echo "Pattern must be shorter than 1000!" >&2; show_help; exit 1
fi


cp /dev/null $out_file

# Loop
rule_i=1

while [ "$rule_i" -le $rule_count ]
do
    file_name=test$rule_i.pcapng

    len=$(($RANDOM%($range_h-$range_l)+$range_l))
    pattern=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $len | head -n 1)
    sid=$((100000000+$rule_i))
    if [[ $random_ip_port == 0 ]] ; then 
        src="any" ; dst="any" ; src_p="any" ; dst_p="any"
    else 
        src=$(get_random_ip) ; dst=$(get_random_ip) ; src_p=$RANDOM ; dst_p=$RANDOM
    fi

    echo "alert tcp $src $src_p -> $dst $dst_p ( msg:\"$pattern\"; content:\"$pattern\"; sid:$sid; )" >> $out_file

    let "rule_i += 1"
done
if [[ $verbose == 1 ]] ; then echo "$rule_count rules are generated to file $out_file." ; fi
