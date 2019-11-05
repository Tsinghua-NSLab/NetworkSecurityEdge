#!/bin/bash

for i in 10 20 30 40 
do
    echo "alert tcp any any -> any any ( msg:"ddos"; detection_filter: track by_dst, count $i, seconds 100; flow:stateless; sid:100000010; )" > test.rules
    echo "threshhold: $i" > flows_ddos_$i.log
    ./flows.sh flows_ddos_$i.log
done
