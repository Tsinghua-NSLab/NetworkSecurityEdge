#! /bin/bash

flow_num_unit=100
packet_num=20
flow_mult=100
payload_size=1000

flow_period=100

log_file="/dev/null"
if [ ! -z "$1" ]; then
    log_file=$1 
fi

echo "Log to $log_file."

date >> $log_file
echo "flow_mult: "$flow_mult >> $log_file
echo "packet_num: "$packet_num >> $log_file
echo "payload_size: "$payload_size >> $log_file
echo >> $log_file

rm pcap/* -rf
sudo docker rm snort 2> /dev/null
flow_num=$flow_num_unit
while [ "$flow_num" -le 1000 ]
do

    echo "generating pcap file"
    tic=`date +'%s.%N'`
    ./generate_pcap.py -f $flow_num_unit -p $packet_num --minLength $payload_size -o pcap/new.pcapng.temp -t $flow_period
    toc=`date +'%s.%N'`
    echo "time: "`echo "sclae=4; $toc - $tic" | bc -l`

    echo "multiplying"
    tic=`date +'%s.%N'`
    ./generate_flows.sh -n $flow_mult -i pcap/new.pcapng.temp -o pcap/new.pcapng.temp -s $flow_period 2> /dev/null 
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
        > /dev/null 2>&1
    endtime=`date +'%s.%N'`
    period=`echo "sclae=4; $endtime - $starttime" | bc -l`
    echo "time: "$period

    echo $flow_num >> $log_file
    echo $period >> $log_file
    echo >> $log_file

    sudo docker rm snort 2> /dev/null
    mv pcap/out.pcapng pcap/last.pcapng.temp

    let "flow_num += $flow_num_unit"
    echo
done

echo "done!" >> $log_file
date >> $log_file
