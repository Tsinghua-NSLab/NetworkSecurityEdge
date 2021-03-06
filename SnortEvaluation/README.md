# snort bandwidth
Find the relationship between snort bandwidth and flow/rule number.

## TODO

- snort
    - [x] snort set rules

- try tcpreplay to snort
    - [x] use tcprewrite to change ip/port
    - [x] change flow number

- run snort in docker
    - [x] snort listen to interface
    - [x] test flows using different rules

- [x] use python to generate random flow
    - [x] change time period
    - [x] random payload length
    - [x] change packet number

- shell script
    - [x] generate random rules
        - [x] random src and dst ip, random port
        - [ ] rules applying to tcp flow instead of just one single packet
        - [ ] regex rules (generate from snort rules?)
    - [x] generate random flows
        - [x] change time, packet number and flow number, combine them to get an input file
    - snort
        - [ ] tcpreplay to snort
        - [x] snort read file
    - [x] record result
        - [ ] exclude unrelated packets?
    - [x] auto-experiment and log

- test
    - [x] change flow number
        - [x] use rule that won't match all
    - [x] change rule number
    - [x] change ddos threshold
    - [ ] mix ddos rule and regex rules
    - [ ] state rules

## Test Result
See `result/`.

- `flows.log`: Using string rules, matching any to any. Change flow number.
- `flows_nomatch.log`: Using string rules, but matching a specific ip. Change flow number.
- `flows_ddos_[d].log`: Using ddos rule, matching any to any. Change flow number. Number d stands for ddos threshold.
- `flows_d[d]_n[n].log`: Using ddos rule and string rules. Change flow number. Number d stands for ddos threshold. Number n stands for string rule number.
- `rules.log`: Using string rules. Change rule number.

## Tools
- Tcpreplay
- Wireshark
- Docker

`sudo yum install tcpreplay wireshark`

### Docker installation
`sudo yum install -y yum-utils device-mapper-persistent-data lvm2`

`sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo`

`sudo yum -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm`

`sudo yum install docker-ce docker-ce-cli`

## Useful commands

### Modify pcap file

#### Change IP and port
`tcprewrite -i pcap/sample.pcapng -o pcap/map -N 1.1.1.1/32:11.11.11.11/32,2.2.2.2/32:22.22.22.22/32 -r 10000:11111,20000:22222`

#### Random IP
`tcprewrite -i pcap/sample.pcapng -o pcap/sample_random.pcapng -s 234`

#### Shift timestamps
`editcap -t 0.00001 pcap/sample.pcapng pcap/sample_shifted.pcapng`

#### Merge pcappng files
`mergecap -w pcap/sample_merged.pcapng pcap/sample_random.pcapng pcap/sample_shifted.pcapng`

### Replay TCP packets

#### tcpreplay
`sudo tcpreplay -i wlp0s20u7 pcap/out.pcapng`

- `-x` multiplie
- `-M` send rate

### snort3 docker image

#### Install

[Reference](github.com/traceflight/snort3-with-openappid-docker)

`sudo docker pull traceflight/snort3-with-openappid-docker`

`sudo docker tag 1a19c7 snort`

#### Run

```
sudo docker run -it --name snort --net=host \
    --cap-add=NET_ADMIN \
    -v `pwd`/log/:/var/log/snort/ \
    -v `pwd`/test.rules:/usr/local/etc/snort/rules/rules/test.rules \
    -v `pwd`/snort.lua:/usr/local/etc/snort/snort.lua \
    snort \
    snort -c /usr/local/etc/snort/snort.lua \
    -A fast \
    -l /var/log/snort \
    -i wlp0s20u7 \
sudo docker rm snort
```

```
sudo docker run -d --name snort --net=host \
    --cap-add=NET_ADMIN \
    -v `pwd`/log/:/var/log/snort/ \
    -v `pwd`/test.rules:/usr/local/etc/snort/rules/rules/test.rules \
    -v `pwd`/snort.lua:/usr/local/etc/snort/snort.lua \
    snort \
    snort -c /usr/local/etc/snort/snort.lua \
    -A fast \
    -l /var/log/snort \
    -i wlp0s20u7 \
```

```
sudo docker kill -s=SIGINT snort
```

```
sudo docker logs snort | grep total_alerts >> log/out.log
```
