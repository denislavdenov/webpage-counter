Vagrant.configure("2") do |config|
 
  # global settings of VMs
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 2
  end
 
  # app node
  config.vm.define "web-app" do |web|
        web.vm.box = "denislavd/xenial64"
        web.vm.hostname = "web-app"
        web.vm.provision :shell, path: "scripts/init_app.sh", privileged: true
        web.vm.network "private_network", ip: "10.10.50.100"
      end
  
  # db node
  config.vm.define "redis" do |db|
    db.vm.box = "denislavd/redis64"
    db.vm.hostname = "redis"
    db.vm.provision :shell, path: "scripts/init_db.sh", privileged: true
    db.vm.network "private_network", ip: "10.10.50.200"
  end
end
