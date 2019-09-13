#!/usr/bin/env bash

export HN=$(hostname)
var2=$(hostname)
# Create script check

cat << EOF > /usr/local/bin/check_db.sh
#!/usr/bin/env bash

redis-cli ping | grep "PONG"
EOF

cat << EOF > /usr/local/bin/check_service.sh
#!/usr/bin/env bash

systemctl status redis-server | grep "active (running)"
EOF

chmod +x /usr/local/bin/check_db.sh
chmod +x /usr/local/bin/check_service.sh

# Register db in consul
cat << EOF > /etc/consul.d/db.json
{
    "service": {
        "name": "redis",
        "tags": ["${var2}"],
        "port": 6379
    },
    "checks": [
        {
            "id": "db_script_check",
            "name": "Ping Pong check",
            "args": ["/usr/local/bin/check_db.sh", "-limit", "256MB"],
            "interval": "10s",
            "timeout": "1s"
        },
        {
            "id": "db_service_check",
            "name": "Service check",
            "args": ["/usr/local/bin/check_service.sh", "-limit", "256MB"],
            "interval": "10s",
            "timeout": "1s"
        }
    ]
}
EOF

sleep 5
consul reload
sleep 30
consul reload