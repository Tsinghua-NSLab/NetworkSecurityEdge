#!/usr/bin/python3

import random
import string
from scapy.all import *
import argparse

def random_string(minLength, maxLength):
    stringLength = random.randint(minLength, maxLength)
    letters = string.ascii_letters
    return ''.join(random.choice(letters) for i in range(stringLength))


def generate_time_seq(num, time):
    sequence = []
    for i in range(num):
        sequence += [random.uniform(0, time)]
    sequence.sort()
    sequence[-1] = time
    return sequence


class FlowGenerater():
    def __init__(self):
        self.add_c = "1.1.1.1"
        self.add_s = "2.2.2.2"
        self.port_c = 10000
        self.port_s = 20000
        self.seq_c = random.randrange(2**32)
        self.seq_s = random.randrange(2**32)
        self.pkts = []

        # ip packets
        self.IP_C = Ether()/IP(src=self.add_c, dst=self.add_s)
        self.IP_S = Ether()/IP(src=self.add_s, dst=self.add_c)

    def seq_c_acc(self, num=1):
        self.seq_c += num
        self.seq_c %= 2**32

    def seq_s_acc(self, num=1):
        self.seq_s += num
        self.seq_s %= 2**32

    def handshake_pkts(self):
        SYN = self.IP_C/TCP(sport=self.port_c, dport=self.port_s,
                            flags='S', seq=self.seq_c)
        self.seq_c_acc()

        SYNACK = self.IP_S/TCP(sport=self.port_s, dport=self.port_c,
                               flags='SA', seq=self.seq_s, ack=self.seq_c)
        SYNACK.time = SYN.time + random.uniform(0.0001, 0.0002) * 2
        self.seq_s_acc()

        ACK = self.IP_C/TCP(sport=self.port_c, dport=self.port_s,
                            flags='A', seq=self.seq_c, ack=self.seq_s)
        ACK.time = SYNACK.time + random.uniform(0.0001, 0.0002)
        self.seq_c_acc()

        self.pkts += [SYN, SYNACK, ACK]

    def finish_pkts(self):
        FIN = self.IP_C/TCP(sport=self.port_c, dport=self.port_s,
                            flags='FA', seq=self.seq_c)
        FIN.time = self.pkts[-1].time + random.uniform(0.0001, 0.0002)
        self.seq_c_acc()

        FINACK = self.IP_S/TCP(sport=self.port_s, dport=self.port_c,
                               flags='FA', seq=self.seq_s, ack=self.seq_c)
        FINACK.time = FIN.time + random.uniform(0.0001, 0.0002) * 2
        self.seq_s_acc()

        ACK = self.IP_C/TCP(sport=self.port_c, dport=self.port_s,
                            flags='A', seq=self.seq_c, ack=self.seq_s)
        ACK.time = FINACK.time + random.uniform(0.0001, 0.0002)
        self.seq_c_acc()

        self.pkts += [FIN, FINACK, ACK]

    def client_pkt(self, data):
        pkt = self.IP_C/TCP(sport=self.port_c, dport=self.port_s,
                            flags='A', seq=self.seq_c, ack=self.seq_s)/data
        self.seq_c_acc(len(data))
        return pkt

    def server_pkt(self, data):
        pkt = self.IP_S/TCP(sport=self.port_s, dport=self.port_c,
                            flags='A', seq=self.seq_s, ack=self.seq_c)/data
        self.seq_s_acc(len(data))
        return pkt

    def generate_random_pkts(self, num, minLength, maxLength, time):
        if maxLength == 0:
            maxLength = minLength + 1
        time_base = fg.pkts[-1].time
        time_seq = generate_time_seq(num, time)
        for i in range(num):
            data = random_string(minLength, maxLength)
            funs = [self.server_pkt, self.client_pkt]
            pkt = random.choice(funs)(data)
            pkt.time = time_base + time_seq[i]
            self.pkts += [pkt]
            if random.random() < 0.005:
                dup_pkt = pkt.copy()
                dup_pkt.time += random.uniform(0.1, 0.3)
                self.pkts += [dup_pkt]


parser = argparse.ArgumentParser(description='Generate random flow.')
parser.add_argument('-n', dest='pnum', default=10,
                    help='packet number', type=int)
parser.add_argument('--minLength', dest='minLength',
                    default=100, help='minimal data length', type=int)
parser.add_argument('--maxLength', dest='maxLength',
                    default=0, help='maximum data length,\
                    0 means exactly as minLength', type=int)
parser.add_argument('-t', dest='time', default=10,
                    help='flow time period', type=float)
parser.add_argument('-o', dest='outfile', default='pcap/temp.pcapng',
                    help='output file path', type=str)
args = parser.parse_args()

fg = FlowGenerater()
fg.handshake_pkts()
fg.generate_random_pkts(num=args.pnum, minLength=args.minLength,
                        maxLength=args.maxLength, time=args.time)
fg.finish_pkts()

# Save to file
wrpcap(args.outfile, fg.pkts)
