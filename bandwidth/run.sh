#!/bin/bash

files=$(ls rules)
for file in $files ; do
    # Generate rules
    ./generate_rules.sh -p rules/$file
    echo "alert tcp any any -> any any ( msg:"ddos"; detection_filter: track by_dst, count 5, seconds 100; flow:stateless; sid:200000000; )" >> test.rules

    # Log and test
    filename="flows_d5_$file.log"
    echo "threshhold: 5" > $filename
    echo "pattern file: $file" >> $filename
    ./flows.sh $filename
done
