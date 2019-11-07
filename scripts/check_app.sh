#!/usr/bin/env bash
export CONSUL_HTTP_TOKEN=`cat /vagrant/keys/master.txt | grep "SecretID:" | cut -c19-`
export HN=$(hostname)
var2=$(hostname)

cat << EOF > /usr/local/bin/check_app.sh
#!/usr/bin/env bash

systemctl status webapp.service | grep "active (running)"
EOF

cat << EOF > /usr/local/bin/check_db.py
#!/usr/bin/env python3

import redis  
import os

conn = redis.StrictRedis(host='10.10.50.200', port=6379, password='redispass')
count = int(conn.get('hits'))
print(count)

EOF

chmod +x /usr/local/bin/check_app.sh
chmod +x /usr/local/bin/check_db.py

# Register web app in consul
cat << EOF > /etc/consul.d/web_app.json
{
    "service": {
        "name": "web_app",
        "tags": ["${var2}"],
        "port": 5000,
        "connect": {
          "sidecar_service": {
            "proxy": {
              "upstreams": [{
                "destination_name": "redis",
                  "local_bind_port": 6479
              }]
            }
          }
        }
    },
    "checks": [
        {
            "id": "app_tcp_check",
            "name": "TCP on port 5000",
            "tcp": "127.0.0.1:5000",
            "interval": "10s",
            "timeout": "1s"
        },
        {
            "id": "app_service_check",
            "name": "app service check",
            "args": ["/usr/local/bin/check_app.sh", "-limit", "256MB"],
            "interval": "10s",
            "timeout": "1s"
        },
        {
            "id": "db_conn_check",
            "name": "DB conn check",
            "args": ["/usr/local/bin/check_db.py", "-limit", "256MB"],
            "interval": "10s",
            "timeout": "1s"
        }
    ]
}
EOF

sleep 5
consul reload
sleep 5

sleep 30
consul reload

cat << EOF > /etc/systemd/system/connect-app.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul connect proxy -sidecar-for web_app
ExecReload=/usr/local/bin/consul connect proxy -sidecar-for web_app
KillMode=process
Restart=on-failure
LimitNOFILE=65536


[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload
sudo systemctl enable connect-app
sudo systemctl start connect-app