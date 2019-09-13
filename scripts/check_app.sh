#!/usr/bin/env bash

export HN=$(hostname)
var2=$(hostname)

cat << EOF > /usr/local/bin/check_app.sh
#!/usr/bin/env bash

systemctl status webapp.service | grep "active (running)"
EOF

cat << EOF > /usr/local/bin/check_db.py
#!/usr/bin/env python3

from redis import Redis
import os

redis = Redis(host='10.10.50.200', port=6379)
count = int(redis.get('hits'))
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
        "port": 5000
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
