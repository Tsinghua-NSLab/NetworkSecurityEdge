#!/usr/bin/python3
import matplotlib.pyplot as plt

x = []
y = []
z = []
with open("result.log.temp", "r") as f:
    for i in range(564):
        flow_num = int(f.readline())
        seconds = float(f.readline())
        # packets = int(f.readline())
        packets = flow_num * 20000
        f.readline()
        x += [flow_num]
        y += [packets / seconds]
        z += [seconds]

plt.scatter(x, z, s=3)
plt.show()
