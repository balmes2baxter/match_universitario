import http.server
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

    def address_string(self):
        return str(self.client_address[0])

PORT = 8080

class ReusableThreadingHTTPServer(http.server.ThreadingHTTPServer):
    allow_reuse_address = True

with ReusableThreadingHTTPServer(("0.0.0.0", PORT), NoCacheHTTPRequestHandler) as httpd:
    print(f"Serving {web_dir} on 0.0.0.0:{PORT} (multithreaded, no-cache)...")
    sys.stdout.flush()
    httpd.serve_forever()
