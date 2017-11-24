from gevent import socket
from gevent.server import StreamServer

SERVER_PORT = 1598

def handle_echo(sock, address):
    fp = sock.makefile()
    while True:
        line = fp.readline()
        if line:
            fp.write(line)
            fp.flush()
        else:
            break
    sock.shutdown(socket.SHUT_WR)
    sock.close()

server = StreamServer(('', SERVER_PORT), handle_echo, spawn=2)

server.serve_forever()
