Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 2
  end

  config.vm.define "web-app" do |web|
        web.vm.box = "denislavd/xenial64"
        web.vm.hostname = "web-app"
        web.vm.provision :shell, path: "scripts/init_app.sh"
        web.vm.network "private_network", ip: "10.10.50.100"
      end

  config.vm.define "redis" do |db|
    db.vm.box = "denislavd/redis64"
    db.vm.hostname = "redis"
    db.vm.provision :shell, path: "scripts/init_db.sh"
    db.vm.network "private_network", ip: "10.10.50.200"
  end
end
