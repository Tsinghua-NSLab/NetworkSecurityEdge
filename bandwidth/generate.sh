#! /bin/bash

function show_help {
echo "
Usage: generate.sh [options]

    -h                              show help
    -v                              verbose
    -n <flow number>                set flow number
    -i <input filename>             set input file
    -o <output filename>            set output file
    -s <maximum timestamp shift>    set output file
"
}

cd "$(dirname $0)"

temp_dir='.temp'

# Argument parsing
OPTIND=1

flow_count=100
verbose=0
in_file=./pcap/sample.pcapng
out_file=./pcap/out.pcapng
max_shift=30

while getopts "h?vn:o:i:s:" opt; do
    case "$opt" in
        h|\?)
            show_help
            exit 0
            ;;
        v)  verbose=1
            ;;
        n)  flow_count=$OPTARG
            ;;
        i)  in_file=$OPTARG
            ;;
        o)  out_file=$OPTARG
            ;;
        s)  max_shift=$OPTARG
            ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--"  ] && shift

if [[ $@ != '' ]] ; then
    echo "Unknown argument $@!" >&2; show_help; exit 1
fi


if ! [[ $flow_count =~ ^[0-9]+$ ]] ; then
    echo "$flow_count is not a number!" >&2; show_help; exit 1
fi

if ! [[ $max_shift =~ ^[0-9]+$ ]] ; then
    echo "$max_shift is not a number!" >&2; show_help; exit 1
fi

if ! [ -f $in_file ] ; then
    echo "Can't find input file $in_file!" >&2; show_help; exit 1
fi

# Remove old files

if [ -d $temp_dir ] ; then
    rm -rf $temp_dir
fi

mkdir $temp_dir

# Loop
flow_i=1

while [ "$flow_i" -le $flow_count ]
do
    file_name=test$flow_i.pcapng

    # Random port
    PORT_S=$((RANDOM+1024))
    PORT_O=$((RANDOM+1024))
    tcprewrite -i $in_file -o $temp_dir/$file_name -r 10000:$PORT_S,20000:$PORT_O

    # Random IP
    tcprewrite -i $temp_dir/$file_name -o $temp_dir/$file_name -s $RANDOM

    # Shift timestamp
    shift=$(echo "scale=8;($RANDOM+$RANDOM*32768)/(32767*32767)*$max_shift"  | bc)
    editcap -t $shift $temp_dir/$file_name $temp_dir/$file_name

    if [[ $verbose == 1 ]] ; then echo $shift ; fi
    let "flow_i += 1"
done

mergecap -w $out_file $temp_dir/*
echo "$flow_count flows are generated."
