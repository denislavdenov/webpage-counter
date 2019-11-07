# Sample repo for python webpage hit counter


## How to use:
Requirements:
	
- `Virtualbox` latest version currently 6
- `Vagrant` latest version currently 2.2.5
	

1. Fork and clone
2. Enter `webpage-counter` folder
3. `vagrant up`
4. Open `http://10.10.50.100:5000` in browser or `curl http://10.10.50.100:5000`
5. Refresh to increase count
6. Consul UI available now at `http://10.10.56.11:8500`


## DONE:

- [x] Create Dev environtment Vagrantfile with 2 Ubuntu servers - 1 redis, 1 python
- [x] Develop app
- [x] Connect app with DB
- [x] Add html,css to python app
- [x] Create 1 consul server and add consul client to app and db
- [x] Add consul health checks for app and db
- [x] Edit python app to take redis info from Consul rather than hard coded
- [x] Enabled ACLs and Consul connect so app talks to db through TLS proxy
- [x] Start connect with systemd
- [x] Put a password to the redis DB
- [x] Update application to use password

## TODO:

- [ ] Add Vault in dev mode
- [ ] Add Redis password in Vault KV
- [ ] Create AppRole for our application
- [ ] Update app to read redis password from Vault KV
- [ ] Create ENV VAR for APP_PORT(5000)
- [ ] Make application to use this port, if no ENV VAR, default to 5000
- [ ] Run 3 copies of app on port 5001-5003
- [ ] Make the application run from Nomad
- [ ] Use Fabio for Load Balancer
