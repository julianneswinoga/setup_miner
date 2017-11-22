import time
import BaseHTTPServer
import json

HOST_NAME = ''
HTTP_PORT_NUMBER = 1597
CLIENT_PORT_NUMBER = 1598
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
        s.wfile.write("<p>You accessed path: %s</p>" % s.path)
        s.wfile.write("</body></html>")
        print read_clients()

    def do_POST(s):
        pass

def read_clients():
    return json.load(open(CLIENT_FILENAME))['clients']

if __name__ == '__main__':
    server_class = BaseHTTPServer.HTTPServer
    httpd = server_class((HOST_NAME, HTTP_PORT_NUMBER), HttpHandler)
    print time.asctime(), "Server Starts - %s:%s" % (HOST_NAME, HTTP_PORT_NUMBER)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, HTTP_PORT_NUMBER)
