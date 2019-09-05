# Sample repo for python webpage hit counter

## TODO:

- [x] Create Dev environtment Vagrantfile with 2 Ubuntu servers - 1 redis, 1 python
- [x] Develop app
- [x] Connect app with DB
- [x] Add html,css to python app
- [ ] Create Prod env building docker containers
- [ ] Automate deployment process with jenkins and kubernetes


## How to use:
Requirements:
	
- `Virtualbox` latest version currently 6
- `Vagrant` latest version currently 2.2.5
	

1. Fork and clone
2. Enter `webpage-counter` folder
3. `vagrant up`
4. Open `http://10.10.50.100:5000` in browser or `curl http://10.10.50.100:5000`
5. Refresh to increase count
