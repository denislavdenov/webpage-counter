#!/usr/bin/env bash
set -x
sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 5000

export PATH=/home/vagrant/.local/bin:$PATH
sudo apt-get update
sudo apt-get install vim -y
sudo apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install -y python3.7 -y
sudo pip3 install pipenv
sudo pip3 install -U Flask
sudo pip3 install redis

cd /vagrant/
pipenv install
pipenv install --dev python-dotenv
pipenv install psycopg2-binary Flask-SQLAlchemy Flask-Migrate
pipenv install mistune
pipenv install redis

source .env
export FLASK_ENV=development
export FLASK_APP='/vagrant/.'
sudo chown -R vagrant:vagrant /etc/systemd/system

cat << EOF > /etc/systemd/system/webapp.service
    [Unit]
    Description="Python web app"
    Documentation=None
    Requires=network-online.target
    After=network-online.target

    [Service]
    User=vagrant
    Group=vagrant
    WorkingDirectory=/vagrant/
    ExecStart=/usr/local/bin/pipenv run flask run --host=0.0.0.0 --port=5000
    KillMode=process
    Restart=on-failure
    LimitNOFILE=65536


    [Install]
    WantedBy=multi-user.target

EOF
systemctl daemon-reload
systemctl enable webapp
systemctl start webapp
systemctl status webapp
set +x
