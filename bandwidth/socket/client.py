import socket
import time

host = '192.168.43.123'
port = 7321
addr = (host, port)
client = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
client.connect(addr)

def send_msg(msg):
    client.send(msg.encode())

send_msg('1234567890')
time.sleep(.1)
send_msg('abcd')
time.sleep(.1)
send_msg('abcdefgh')
time.sleep(.1)

s.close()

# while True:
    # msg = input("input: ")
    # if not msg:
        # continue
    # client.send(msg.encode())
    # print("send " + msg)
