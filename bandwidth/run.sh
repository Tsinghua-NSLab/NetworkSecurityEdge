#!/bin/bash

files=$(ls rules)
for file in $files ; do
    # Generate rules
    ./generate_rules.sh -p rules/$file

    # Log and test
    filename="flows_pattern_$file.log"
    echo "pattern file: $file" >> $filename
    ./flows.sh $filename
done
