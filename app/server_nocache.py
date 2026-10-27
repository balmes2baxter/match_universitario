import http.server
import socketserver
import os
import sys

web_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'build', 'web')
os.chdir(web_dir)

class NoCacheHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

Handler = NoCacheHTTPRequestHandler
PORT = 8080

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("0.0.0.0", PORT), Handler) as httpd:
    print(f"Serving {web_dir} on 0.0.0.0:{PORT} with NO-CACHE headers...")
    sys.stdout.flush()
    httpd.serve_forever()
