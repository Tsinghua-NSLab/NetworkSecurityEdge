#!/bin/bash

for i in 0 10 10000
do
    ./generate_rules.sh -r 40:41 -n $i
    echo "alert tcp any any -> any any ( msg:"ddos"; detection_filter: track by_dst, count 5, seconds 100; flow:stateless; sid:200000000; )" >> test.rules
    echo "threshhold: 5" > flows_d5_n$i.log
    echo "string rule: $i" >> flows_d5_n$i.log
    ./flows.sh flows_d5_n$i.log
done
