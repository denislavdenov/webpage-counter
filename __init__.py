from flask import Flask, render_template
from redis import Redis
import os
import json
import urllib
import urllib.request

url = "http://10.10.56.11:8500/v1/catalog/service/web_app-sidecar-proxy"
response = urllib.request.urlopen(url).read()
output = json.loads(response.decode('utf-8'))
DB_IP = output[0]["ServiceProxy"]["LocalServiceAddress"]
DB_PORT=output[0]["ServiceProxy"]["Upstreams"][0]["LocalBindPort"]

app = Flask(__name__)
redis = Redis(host=DB_IP, port=DB_PORT)

@app.route('/')
def hello():
    redis.incr('hits')
    count = int(redis.get('hits'))
    return render_template('index.html', count = count)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)