#! /bin/bash

flow_num=10

packet_num=5
flow_mult=100
payload_size=50
flow_period=100
max_shift=100

echo "start" >> result.log
date >> result.log
while [ "$flow_num" -le 1000 ]
do
    rm pcap/* -f

    echo "generating pcap file"
    i=1
    while [ "$i" -le $flow_num ]
    do
        ./generate_pcap.py -n $packet_num --minLength $payload_size -o pcap/$i.pcapng.temp -t $flow_period
        ./generate_flows.sh -n $flow_mult -i pcap/$i.pcapng.temp -o pcap/$i.pcapng.temp -s $max_shift 2> /dev/null 
        let "i += 1"
    done
    mergecap -w pcap/out.pcapng pcap/*.temp

    # snort
    echo "running snort"
    echo $flow_num >> result.log
    sudo docker rm snort 2> /dev/null
    sudo docker run -i --name snort \
        -v `pwd`/snort.lua:/usr/local/etc/snort/snort.lua \
        -v `pwd`/pcap/out.pcapng:/home/pcap \
        snort \
        snort -c /usr/local/etc/snort/snort.lua \
        -A fast \
        -r /home/pcap \
        2> /dev/null \
        | tail -n 4 | head -n 2 >> result.log
    echo >> result.log

    let "flow_num += 10"
done

echo "done!" >> result.log
date >> result.log
