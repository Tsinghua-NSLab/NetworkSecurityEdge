# snort bandwidth
Find the relationship of snort bandwidth and flow number and rule number.

## TODO

- snort
    - [x] snort set rules

- try tcpreplay to snort
    - [x] tcprewrite to change ip/port
    - [ ] how to change flow number?
        - repeat flow, shift timestamp, then combine pcap files?

- [ ] run snort in docker

- shell script
    - [ ] change rules
    - [ ] generate random flow
    - [ ] tcpreplay to snort
    - [ ] record result


## Replay TCP packets

### tcprewrite

#### Change IP and port
`tcprewrite -i pcap/sample.pcapng -o pcap/map -N 1.1.1.1/32:11.11.11.11/32,2.2.2.2/32:22.22.22.22/32 -r 10000:11111,20000:22222`

#### Random IP
`tcprewrite -i pcap/sample.pcapng -o pcap/sample_random.pcapng -s 234`

### tcpreplay
`sudo tcpreplay -i lo pcap/sample.pcapng`

- `-x` multiplie
- `-M` send rate
