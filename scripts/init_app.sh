#!/usr/bin/env bash
set -x
sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 5000
export PATH=/home/vagrant/.local/bin:$PATH
cd /home/vagrant/
pipenv install
pipenv install --dev python-dotenv
pipenv install psycopg2-binary Flask-SQLAlchemy Flask-Migrate
pipenv install mistune
pipenv install redis

set +x