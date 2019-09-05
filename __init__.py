from flask import Flask, render_template
from redis import Redis
import os

app = Flask(__name__)
redis = Redis(host='10.10.50.200', port=6379)

@app.route('/')
def hello():
    redis.incr('hits')
    count = int(redis.get('hits'))
    return render_template('index.html', count = count)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)