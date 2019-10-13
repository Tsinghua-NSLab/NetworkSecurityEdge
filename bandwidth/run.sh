#! /bin/bash

./generate_flows.sh -n $1 -s 5

./generate_rules.sh -n $2 -m

sudo docker kill snort
sudo docker rm snort

sudo docker run -d --name snort --net=host \
    --cap-add=NET_ADMIN \
    -v `pwd`/log/:/var/log/snort/ \
    -v `pwd`/test.rules:/usr/local/etc/snort/rules/rules/test.rules \
    -v `pwd`/snort.lua:/usr/local/etc/snort/snort.lua \
    snort \
    snort -c /usr/local/etc/snort/snort.lua \
    -A fast \
    -l /var/log/snort \
    -i wlp0s20u7

sudo tcpreplay -i wlp0s20u7 pcap/out.pcapng 

sudo docker kill -s=SIGINT snort

#echo "$1 flows $2 rules" >> log/out.log
alerts=$(sudo docker logs snort | grep total_alerts | sed 's/.* \(\d*\)/\1/g')
echo $alerts
#echo >> log/out.log
