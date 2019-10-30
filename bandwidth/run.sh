#! /bin/bash

flow_num_unit=10

packet_num=20
flow_mult=1000
payload_size=1000
flow_period=100
max_shift=100

echo "start" >> result.log
date >> result.log

rm pcap/* -rf
i=1
flow_num=$flow_num_unit
while [ "$flow_num" -le 100000 ]
do
    iteration_start=`date +'%s.%N'`

    echo "generating pcap file"
    while [ "$i" -le $flow_num ]
    do
        ./generate_pcap.py -n $packet_num --minLength $payload_size -o pcap/$i.pcapng.temp -t $flow_period
        ./generate_flows.sh -n $flow_mult -i pcap/$i.pcapng.temp -o pcap/$i.pcapng.temp -s $max_shift 2> /dev/null 
        let "i += 1"
    done

    rm pcap/out.pcapng -rf
    mergecap -w pcap/out.pcapng pcap/*temp
    rm pcap/*temp -rf

    # snort
    echo "running snort"

    starttime=`date +'%s.%N'`
    sudo docker run -i --name snort \
        -v `pwd`/test.rules:/usr/local/etc/snort/rules/rules/test.rules \
        -v `pwd`/snort.lua:/usr/local/etc/snort/snort.lua \
        -v `pwd`/pcap/out.pcapng:/home/pcap \
        snort \
        snort -c /usr/local/etc/snort/snort.lua \
        -A fast \
        -r /home/pcap \
        &> /dev/null &2>1
    endtime=`date +'%s.%N'`
    period=`echo "sclae=4; $endtime - $starttime" | bc -l`

    echo $flow_num >> result.log
    echo $period >> result.log
    echo >> result.log

    sudo docker rm snort 2> /dev/null
    mv pcap/out.pcapng pcap/last.pcapng.temp

    let "flow_num += $flow_num_unit"
    iteration_end=`date +'%s.%N'`
    echo "iteration time: "`echo "sclae=4; $iteration_end - $iteration_start" | bc -l`
    echo
done

echo "done!" >> result.log
date >> result.log
