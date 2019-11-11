from flask import Flask, render_template
import redis
import os
import json
import urllib
import urllib.request
import requests

url = "http://10.10.56.11:8500/v1/catalog/service/web_app-sidecar-proxy"
response = urllib.request.urlopen(url).read()
output = json.loads(response.decode('utf-8'))
DB_IP = output[0]["ServiceProxy"]["LocalServiceAddress"]
DB_PORT=output[0]["ServiceProxy"]["Upstreams"][0]["LocalBindPort"]

vault_url = "http://10.10.56.11:8500/v1/catalog/service/vault"
vault_response = urllib.request.urlopen(vault_url).read()
vault_output = json.loads(vault_response.decode('utf-8'))
VAULT_IP = vault_output[0]["Address"]
VAULT_PORT = vault_output[0]["ServicePort"]
with open('/vagrant/keys/vault.txt') as fp:
  VAULT_TOKEN = fp.read()

headers = {
    'X-Vault-Token': VAULT_TOKEN,
}

 
role_id_url = "http://" + str(VAULT_IP) + ":" + str(VAULT_PORT) + "/v1/auth/approle/role/redis/role-id"
ROLE_ID_RES = requests.get(role_id_url, headers=headers)
ROLE_ID = ROLE_ID_RES.json()["data"]["role_id"]

sec_id_url = "http://" + str(VAULT_IP) + ":" + str(VAULT_PORT) + "/v1/auth/approle/role/redis/secret-id"
SEC_ID_RES = requests.post(sec_id_url, headers=headers)
SEC_ID = SEC_ID_RES.json()["data"]["secret_id"]

login_url = "http://" + str(VAULT_IP) + ":" + str(VAULT_PORT) + "/v1/auth/approle/login"
data = '{"role_id":"' + ROLE_ID + '","secret_id":"' + SEC_ID + '"}'
login = requests.post(login_url, data=data)
VAULT_TOKEN = login.json()["auth"]["client_token"]
headers = {
    'X-Vault-Token': VAULT_TOKEN,
}
pass_url = "http://" + str(VAULT_IP) + ":" + str(VAULT_PORT) + "/v1/kv/redis"

redisdbpass = requests.get(pass_url, headers=headers)

DB_PASS = redisdbpass.json()["data"]["pass"]



app = Flask(__name__)
conn = redis.StrictRedis(host=DB_IP, port=DB_PORT, password=DB_PASS)
# APP_PORT_RUN = os.environ['APP_PORT']
# if APP_PORT_RUN != "5000":
#     APP_PORT_RUN = "5000"


@app.route('/')
def hello():
    conn.incr('hits')
    count = int(conn.get('hits'))
    return render_template('index.html', count = count)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)