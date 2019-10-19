#!/usr/bin/python3

import random
import string
from scapy.all import *


def random_string(minLength=10, maxLength=1001):
    stringLength = random.randint(minLength, maxLength)
    letters = string.ascii_letters
    return ''.join(random.choice(letters) for i in range(stringLength))


class FlowGenerater():
    def __init__(self):
        self.add_c = "1.1.1.1"
        self.add_s = "2.2.2.2"
        self.port_c = 10000
        self.port_s = 20000
        self.seq_c = 10000000  # TODO: random it
        self.seq_s = 20000000  # TODO: random it
        self.pkts = []

        # ip packets
        self.IP_C = IP(src=self.add_c, dst=self.add_s)
        self.IP_S = IP(src=self.add_s, dst=self.add_c)

    def handshake_pkts(self):
        SYN = self.IP_C/TCP(sport=self.port_c, dport=self.port_s,
                       flags='S', seq=self.seq_c)
        self.seq_c += 1

        SYNACK = self.IP_S/TCP(sport=self.port_s, dport=self.port_c,
                               flags='SA', seq=self.seq_s, ack=self.seq_c)
        self.seq_s += 1

        ACK = self.IP_C/TCP(sport=self.port_c, dport=self.port_s,
                            flags='A', seq=self.seq_c, ack=self.seq_s)
        self.seq_c += 1

        self.pkts = [SYN, SYNACK, ACK]

    def client_pkt(self, data):
        pkt = self.IP_C/TCP(sport=self.port_c, dport=self.port_s,
                            flags='A', seq=self.seq_c, ack=self.seq_s)/data
        self.seq_c += len(data)
        self.pkts += [pkt]
        return pkt

    def server_pkt(self, data):
        pkt = self.IP_S/TCP(sport=self.port_s, dport=self.port_c,
                            flags='A', seq=self.seq_s, ack=self.seq_c)/data
        self.seq_s += len(data)
        self.pkts += [pkt]
        return pkt

    def random_pkts(self, num=10):
        # Random data
        for i in range(num):
            data = random_string()
            funs = [self.server_pkt, self.client_pkt]
            random.choice(funs)(data)

# TODO: random duplicate?
# TODO: fin

fg = FlowGenerater()
fg.handshake_pkts()
fg.random_pkts(10)

# Save to file
wrpcap("temp.cap", fg.pkts)
