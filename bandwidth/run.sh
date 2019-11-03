#!/bin/bash

./generate_rules.sh -R
./flows.sh flows_nomatch.log

./generate_rules.sh -d
./flows.sh flows_ddos.log
