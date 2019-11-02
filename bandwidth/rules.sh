#! /bin/bash

rule_num=10

flow_num=20
packet_num=20
flow_mult=100
payload_size=1000

flow_period=100
log_file=rules.log

date >> $log_file
echo "flow_num: "$flow_num >> $log_file
echo "flow_mult: "$flow_mult >> $log_file
echo "packet_num: "$packet_num >> $log_file
echo "payload_size: "$payload_size >> $log_file
echo >> $log_file

rm pcap/* -rf
sudo docker rm snort 2> /dev/null

# Generate pcapng file
echo "generating pcap file"
tic=`date +'%s.%N'`
./generate_pcap.py -f $flow_num -p $packet_num --minLength $payload_size -o pcap/out.pcapng -t $flow_period
toc=`date +'%s.%N'`
echo "time: "`echo "sclae=4; $toc - $tic" | bc -l`

echo "multiplying"
tic=`date +'%s.%N'`
./generate_flows.sh -n $flow_mult -i pcap/out.pcapng -o pcap/out.pcapng -s $flow_period 2> /dev/null 
toc=`date +'%s.%N'`
echo "time: "`echo "sclae=4; $toc - $tic" | bc -l`

echo

while [ "$rule_num" -le 100000 ]
do

    echo "generating rules"
    tic=`date +'%s.%N'`
    ./generate_rules.sh -n $rule_num -r 40:41
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

    echo $rule_num >> $log_file
    echo $period >> $log_file
    echo >> $log_file

    sudo docker rm snort 2> /dev/null

    let "rule_num *= 2"
    echo
done
