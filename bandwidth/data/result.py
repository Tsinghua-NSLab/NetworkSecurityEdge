import matplotlib.pyplot as plt

x = []
y = []
z = []
with open("out", "r") as f:
    for i in range(12):
        flow_num = int(f.readline())
        seconds = float(f.readline())
        packets = int(f.readline())
        f.readline()
        x += [flow_num]
        y += [packets / seconds]
        z += [seconds]

plt.scatter(x, z, s=3)
plt.show()
