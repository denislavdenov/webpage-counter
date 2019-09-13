#!/usr/bin/env bash
set -x
sudo systemctl stop consul
sleep 5
sudo systemctl status consul
DOMAIN=${DOMAIN}
SERVER_COUNT=${SERVER_COUNT}
DCNAME=${DCS}
DC=${DC}
SOFIA_SERVERS="[\"10.10.56.11\"]"
JOIN_SERVER="[\"10.${DC}0.56.11\"]"


var2=$(hostname)
mkdir -p /vagrant/logs
mkdir -p /etc/consul.d

# Function used for initialize Consul. Requires 2 arguments: Log level and the hostname assigned by the respective variables.
# If no log level is specified in the Vagrantfile, then default "info" is used.
init_consul () {
    killall consul

    LOG_LEVEL=$1
    if [ -z "$1" ]; then
        LOG_LEVEL="info"
    fi

    if [ -d /vagrant ]; then
    mkdir /vagrant/logs
    LOG="/vagrant/logs/$2.log"
    else
    LOG="vault.log"
    fi

    IP=$(hostname -I | cut -f2 -d' ')

    sudo useradd --system --home /etc/consul.d --shell /bin/false consul
    sudo chown --recursive consul:consul /etc/consul.d
    sudo chmod -R 755 /etc/consul.d/
    sudo mkdir --parents /tmp/consul
    sudo chown --recursive consul:consul /tmp/consul
    mkdir -p /tmp/consul_logs/
    sudo chown --recursive consul:consul /tmp/consul_logs/

    cat << EOF > /etc/systemd/system/consul.service
    [Unit]
    Description="HashiCorp Consul - A service mesh solution"
    Documentation=https://www.consul.io/
    Requires=network-online.target
    After=network-online.target

    [Service]
    User=consul
    Group=consul
    ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
    ExecReload=/usr/local/bin/consul reload
    KillMode=process
    Restart=on-failure
    LimitNOFILE=65536


    [Install]
    WantedBy=multi-user.target

EOF
}

# Function that creates the conf file for the Consul servers. It requires 8 arguments. All of them are defined in the beginning of the script.
# Arguments 5 and 6 are the SOFIA_SERVERS and BTG_SERVERS and they are twisted depending in which DC you are creating the conf file.
create_server_conf () {
    cat << EOF > /etc/consul.d/config_${1}.json
    
    {
        
        "server": true,
        "node_name": "${2}",
        "bind_addr": "${3}",
        "client_addr": "0.0.0.0",
        "bootstrap_expect": ${4},
        "retry_join": ${5},
        "log_level": "${6}",
        "data_dir": "/tmp/consul",
        "enable_script_checks": true,
        "domain": "${7}",
        "datacenter": "${1}",
        "ui": true,
        "disable_remote_exec": true
    }
EOF
}

# Function that creates the conf file for Consul clients. It requires 6 arguments and they are defined in the beginning of the script.
# 3rd argument shall be the JOIN_SERVER as it points the client to which server contact for cluster join.
create_client_conf () {
    cat << EOF > /etc/consul.d/consul_client.json

        {
            "node_name": "${1}",
            "bind_addr": "${2}",
            "client_addr": "0.0.0.0",
            "retry_join": ${3},
            "log_level": "${4}",
            "data_dir": "/tmp/consul",
            "enable_script_checks": true,
            "domain": "${5}",
            "datacenter": "${6}",
            "ui": true,
            "disable_remote_exec": true,
            "leave_on_terminate": false
        }

EOF
}


# Starting consul

init_consul ${LOG_LEVEL} ${var2} 

if [ ${TLS} = true ]; then
    create_gossip_conf $var2
fi

if [[ "${var2}" =~ "consul-server" ]]; then
    killall consul
     
    if [[ "${var2}" =~ "dc1" ]]; then


    create_server_conf ${DCNAME} ${var2} ${IP} ${SERVER_COUNT} ${SOFIA_SERVERS} ${LOG_LEVEL} ${DOMAIN}


    fi


    sleep 1
    sudo systemctl enable consul
    sudo systemctl start consul
    journalctl -f -u consul.service > /vagrant/logs/${var2}.log &
    sleep 5
    sudo systemctl status consul

else
    if [[ "${var2}" =~ "client" ]]; then
        killall consul
        create_client_conf ${var2} ${IP} ${JOIN_SERVER} ${LOG_LEVEL} ${DOMAIN} ${DCNAME}
    fi

    sleep 1

    sudo systemctl enable consul
    sudo systemctl start consul
    journalctl -f -u consul.service > /vagrant/logs/${var2}.log &
    sleep 5
    sudo systemctl status consul
    
fi


sleep 5

consul members

set +x