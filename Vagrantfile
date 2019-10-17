SERVER_COUNT = 1
CONSUL_VER = "1.6.0"
LOG_LEVEL = "debug" #The available log levels are "trace", "debug", "info", "warn", and "err". if empty - default is "info"
DOMAIN = "consul"

Vagrant.configure("2") do |config|
 
  # global settings of VMs
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 2
  end

  # Consul server
  ["dc1",].to_enum.with_index(1).each do |dcname, dc|

    
    (1..SERVER_COUNT).each do |i|
      
      config.vm.define "consul-server#{i}-#{dcname}" do |node|
        node.vm.box = "denislavd/xenial64"
        node.vm.hostname = "consul-server#{i}-#{dcname}"
        node.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
        node.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}"}
        node.vm.network "private_network", ip: "10.#{dc}0.56.1#{i}"
      end
    end
  

    # db node
    config.vm.define "client-redis-#{dcname}" do |db|
      db.vm.box = "denislavd/redis64"
      db.vm.hostname = "client-redis-#{dcname}"
      db.vm.provision :shell, path: "scripts/init_db.sh", privileged: true
      db.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
      db.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}"}
      db.vm.provision :shell, path: "scripts/check_db.sh"
      db.vm.network "private_network", ip: "10.10.50.200"
    end

    # app node
    config.vm.define "client-web-app-#{dcname}" do |web|
      web.vm.box = "denislavd/xenial64"
      web.vm.hostname = "client-web-app-#{dcname}"
      web.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
      web.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}"}
      web.vm.provision :shell, path: "scripts/check_app.sh"
      web.vm.provision :shell, path: "scripts/init_app.sh", privileged: true
      web.vm.network "private_network", ip: "10.10.50.100"
    end
  end
end
