#! /bin/bash

pcap_num=10
flow_num=100
packet_num=20
payload_size=100
flow_period=10
max_shift=100

rm pcap/*temp -f

i=1
while [ "$i" -le $pcap_num ]
do
    ./generate_pcap.py -n $packet_num --minLength $payload_size -o pcap/$i.pcapng.temp -t $flow_period
    ./generate_flows.sh -n $flow_num -i pcap/$i.pcapng.temp -o pcap/$i.pcapng.temp -s $max_shift
    let "i += 1"
done
mergecap -w pcap/out.pcapng pcap/*
rm pcap/*temp

# snort

#sudo docker kill snort
#sudo docker rm snort

#sudo docker run -d --name snort --net=host \
    #--cap-add=NET_ADMIN \
    #-v `pwd`/log/:/var/log/snort/ \
    #-v `pwd`/test.rules:/usr/local/etc/snort/rules/rules/test.rules \
    #-v `pwd`/snort.lua:/usr/local/etc/snort/snort.lua \
    #snort \
    #snort -c /usr/local/etc/snort/snort.lua \
    #-A fast \
    #-l /var/log/snort \
    #-i wlp0s20u7

#sudo tcpreplay -i wlp0s20u7 pcap/out.pcapng 

#sudo docker kill -s=SIGINT snort

##echo "$1 flows $2 rules" >> log/out.log
#alerts=$(sudo docker logs snort | grep total_alerts | sed 's/.* \(\d*\)/\1/g')
#echo $alerts
##echo >> log/out.log
