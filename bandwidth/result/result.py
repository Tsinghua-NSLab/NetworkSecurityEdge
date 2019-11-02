#!/usr/bin/python3
import sys
import matplotlib.pyplot as plt

filename = sys.argv[1]
if not filename:
    print("no file name specified, exit")
    exit(0)

x = []
y = []
first_line = -1
with open(filename, "r") as f:
    for num, line in enumerate(f, start=1):
        if first_line < 0:
            if line == '\n':
                first_line = num + 1
            else:
                continue
        else:
            if (num - first_line) % 3 == 0:
                flow_num = int(line)
                x += [flow_num]
            elif (num - first_line) % 3 == 1:
                seconds = float(line)
                y += [seconds]

plt.scatter(x, y, s=3)
plt.show()
