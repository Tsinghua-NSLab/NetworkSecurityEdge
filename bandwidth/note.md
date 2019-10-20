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
    - [x] change payload

- shell script
    - [x] generate random rules
        - [x] random src and dst ip, random port
        - [ ] add rules that matches the flow content
    - [x] generate random flows
    - [ ] tcpreplay to snort
    - [ ] record result
        - [ ] exclude unrelated packets?
    - [ ] auto-experiment and log error

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

#### Shift timestamp
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
