import gevent
from gevent import socket
import time
import BaseHTTPServer
import json

HOST_NAME = ''
HTTP_PORT = 1597
CLIENT_PORT = 1598
CLIENT_FILENAME = 'clients.json'

class HttpHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_HEAD(s):
        s.send_response(200)
        s.send_header("Content-type", "text/html")
        s.end_headers()

    def do_GET(s):
        s.send_response(200)
        s.send_header("Content-type", "text/html")
        s.end_headers()
        s.wfile.write("<html><head><title>Title goes here.</title></head>")
        s.wfile.write("<body><p>This is a test.</p>")
        s.wfile.write("<p>You accessed path: %s %s</p>" % (s.path, read_clients()))
        s.wfile.write("</body></html>")

    def do_POST(s):
        pass

def read_clients():
    return json.load(open(CLIENT_FILENAME))['clients']

if __name__ == '__main__':
    urls = ['localhost:' + str(CLIENT_PORT)]
    jobs = [gevent.spawn(socket.gethostbyname, url) for url in urls]
    gevent.joinall(jobs, timeout=2)

    server_class = BaseHTTPServer.HTTPServer
    httpd = server_class((HOST_NAME, HTTP_PORT), HttpHandler)
    print time.asctime(), "Server Starts - %s:%s" % (HOST_NAME, HTTP_PORT)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, HTTP_PORT)
