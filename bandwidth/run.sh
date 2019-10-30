#! /bin/bash

flow_num_unit=10

packet_num=100
flow_mult=1000
payload_size=1000
flow_period=100
max_shift=100

echo "start" >> result.log
date >> result.log
echo "multiply: "$flow_mult >> result.log

rm pcap/* -rf
flow_num=$flow_num_unit
while [ "$flow_num" -le 10000 ]
do

    echo "generating pcap file"
    tic=`date +'%s.%N'`
    ./generate_pcap.py -f $flow_num_unit -p $packet_num --minLength $payload_size -o pcap/new.pcapng.temp -t $flow_period
    toc=`date +'%s.%N'`
    echo "time: "`echo "sclae=4; $toc - $tic" | bc -l`

    echo "multiplying"
    tic=`date +'%s.%N'`
    ./generate_flows.sh -n $flow_mult -i pcap/new.pcapng.temp -o pcap/new.pcapng.temp -s $max_shift 2> /dev/null 
    toc=`date +'%s.%N'`
    echo "time: "`echo "sclae=4; $toc - $tic" | bc -l`

    echo "merging"
    tic=`date +'%s.%N'`
    rm pcap/out.pcapng -rf
    mergecap -w pcap/out.pcapng pcap/*temp
    rm pcap/*temp -rf
    toc=`date +'%s.%N'`
    echo "time: "`echo "sclae=4; $toc - $tic" | bc -l`

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
    echo "time: "$period
    echo

    echo $flow_num >> result.log
    echo $period >> result.log
    echo >> result.log

    sudo docker rm snort 2> /dev/null
    mv pcap/out.pcapng pcap/last.pcapng.temp

    let "flow_num += $flow_num_unit"
    exit 0
done

echo "done!" >> result.log
date >> result.log
