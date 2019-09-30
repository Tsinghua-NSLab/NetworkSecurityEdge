import socket

host = ''
port = 7321
addr = (host, port)
server = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
server.bind(addr)
server.listen(1)

while True:

    s, addr = server.accept()
    print(addr)

    while True:
        data = s.recv(2048)
        if data:
            print("receive " + data.decode())
        else:
            s.close()
            break
