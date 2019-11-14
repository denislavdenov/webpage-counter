SERVER_COUNT = 1
CONSUL_VER = "1.6.0"
VAULT= "1.2.3"
LOG_LEVEL = "trace" #The available log levels are "trace", "debug", "info", "warn", and "err". if empty - default is "info"
DOMAIN = "consul"
NOMAD_VER = "0.10.1"

Vagrant.configure("2") do |config|
 
  # global settings of VMs
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  
  ["dc1",].to_enum.with_index(1).each do |dcname, dc|

    
    (1..SERVER_COUNT).each do |i|
      # Consul server
      config.vm.define "consul-server#{i}-#{dcname}" do |node|
        node.vm.box = "denislavd/xenial64"
        node.vm.hostname = "consul-server#{i}-#{dcname}"
        node.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
        node.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}"}
        node.vm.network "private_network", ip: "10.#{dc}0.56.1#{i}"
      end
      # Nomad server
      config.vm.define "client-nomad-server#{i}-#{dcname}" do |node|
        node.vm.box = "denislavd/xenial64"
        node.vm.hostname = "client-nomad-server#{i}-#{dcname}"
        node.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
        node.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}"}
        node.vm.provision :shell, path: "scripts/install_nomad.sh", env: {"NOMAD_VER" => NOMAD_VER}
        node.vm.provision :shell, path: "scripts/start_nomad.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DCS" => "#{dcname}","DC" => "#{dc}"}
        node.vm.network "private_network", ip: "10.#{dc}0.58.1#{i}"
      end

    end


    # vault node
    config.vm.define "client-vault-#{dcname}" do |vl|
      vl.vm.box = "denislavd/xenial64"
      vl.vm.hostname = "client-vault-#{dcname}"
      vl.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
      vl.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}"}
      vl.vm.provision :shell, path: "scripts/install_vl.sh", env: {"VAULT" => VAULT}
      vl.vm.provision :shell, path: "scripts/init_vl.sh"
      vl.vm.provision :shell, path: "scripts/check_vl.sh"
      vl.vm.network "private_network", ip: "10.10.50.150"
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

    # nomad client 
    config.vm.define "client-nomad-client-#{dcname}" do |nm|
      nm.vm.box = "denislavd/xenial64"
      nm.vm.hostname = "client-nomad-client-#{dcname}"
      nm.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
      nm.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}"}
      nm.vm.provision :shell, path: "scripts/install_nomad.sh", env: {"NOMAD_VER" => NOMAD_VER}
      nm.vm.provision :shell, path: "scripts/start_nomad.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DCS" => "#{dcname}","DC" => "#{dc}"}
      nm.vm.provision :shell, path: "scripts/init_app.sh", privileged: true
      nm.vm.network "private_network", ip: "10.10.58.100"
    end
  end
end
