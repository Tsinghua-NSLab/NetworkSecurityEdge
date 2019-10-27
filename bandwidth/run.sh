#! /bin/bash

flow_num=100

packet_num=5
flow_mult=100
payload_size=50
flow_period=100
max_shift=100

echo "start" >> result.log
date >> result.log

rm pcap/* -f
i=1
while [ "$flow_num" -le 100000 ]
do

    echo "generating pcap file"
    while [ "$i" -le $flow_num ]
    do
        ./generate_pcap.py -n $packet_num --minLength $payload_size -o pcap/$i.pcapng.temp -t $flow_period
        ./generate_flows.sh -n $flow_mult -i pcap/$i.pcapng.temp -o pcap/$i.pcapng.temp -s $max_shift 2> /dev/null 
        let "i += 1"
    done

    echo "merging"
    mergecap -w pcap/out.pcapng pcap/*
    rm pcap/*temp -f

    # snort
    echo "running snort"
    echo $flow_num >> result.log
    sudo docker rm snort 2> /dev/null
    sudo docker run -i --name snort \
        -v `pwd`/test.rules:/usr/local/etc/snort/rules/rules/test.rules \
        -v `pwd`/snort.lua:/usr/local/etc/snort/snort.lua \
        -v `pwd`/pcap/out.pcapng:/home/pcap \
        snort \
        snort -c /usr/local/etc/snort/snort.lua \
        -A fast \
        -r /home/pcap \
        2> /dev/null \
        | tail -n 4 | head -n 2 >> result.log
    echo >> result.log

    mv pcap/out.pcapng pcap/out.pcapng.temp

    let "flow_num += 100"
done

echo "done!" >> result.log
date >> result.log
