IMAGE_NAME = ENV["IMAGE_NAME"]
LOADBALANCERS = ENV["LOADBALANCERS"].to_i
MASTERS = ENV["MASTERS"].to_i
WORKERS = ENV["WORKERS"].to_i
ETCDS = ENV["ETCDS"].to_i
SUBNET = ENV["SUBNET"]

Vagrant.configure("2") do |c|
  
  print IMAGE_NAME, "\n"
  c.vm.provision "shell" do |s|
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    s.inline = <<-SHELL
      echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
    SHELL
  end

  print "LOADBALANCERS: ", LOADBALANCERS, "\n"
  (1..LOADBALANCERS).each do |i|
    c.vm.define "kload#{i}" do |m|
      m.vm.box = IMAGE_NAME
      m.vm.hostname = "kload#{i}"
      m.vm.provider "virtualbox" do |v|
        v.memory = 512
        v.cpus = 2
      end
      m.vm.network "private_network", ip: "#{SUBNET}.#{i + 10}"
      m.vm.provision "file", source: "environment.sh", destination: "~/environment.sh"
      m.vm.provision "shell", path: "000_all_hosts.sh"
      m.vm.provision "shell", path: "010_all_docker.sh"
      m.vm.provision "shell", path: "030_lb_docker_compose.sh"
      m.vm.provision "shell", path: "035_lb_nginx.sh"
    end
  end

  print "ETCDS: ", ETCDS, "\n"
  (1..ETCDS).each do |i|
    c.vm.define "ketcd#{i}" do |m|
      m.vm.box = IMAGE_NAME
      m.vm.hostname = "ketcd#{i}"
      m.vm.provider "virtualbox" do |v|
        v.memory = 798
        v.cpus = 1
      end
      m.vm.network "private_network", ip: "#{SUBNET}.#{i + 20}"
      m.vm.provision "file", source: "environment.sh", destination: "~/environment.sh"
      m.vm.provision "shell", path: "000_all_hosts.sh"
      m.vm.provision "shell", path: "010_all_docker.sh"
      m.vm.provision "shell", path: "015_all_k8s.sh"
      m.vm.provision "shell", path: "040_etcd_install.sh"
    end 
  end

  print "MASTERS: ", MASTERS, "\n"
  (1..MASTERS).each do |i|
    c.vm.define "kmast#{i}" do |m|
      m.vm.box = IMAGE_NAME
      m.vm.hostname = "kmast#{i}"
      m.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
      end
      m.vm.network "private_network", ip: "#{SUBNET}.#{i + 30}"
      m.vm.provision "file", source: "environment.sh", destination: "~/environment.sh"
      m.vm.provision "shell", path: "000_all_hosts.sh"
      m.vm.provision "shell", path: "010_all_docker.sh"
      m.vm.provision "shell", path: "015_all_k8s.sh"
    end          
  end

  print "WORKERS: ", WORKERS, "\n"
  (1..WORKERS).each do |i|
    c.vm.define "kwork#{i}" do |m|
      m.vm.box = IMAGE_NAME
      m.vm.hostname = "kwork#{i}"
      m.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
      end
      m.vm.network "private_network", ip: "#{SUBNET}.#{i + 40}"
      m.vm.provision "file", source: "environment.sh", destination: "~/environment.sh"
      m.vm.provision "shell", path: "000_all_hosts.sh"
      m.vm.provision "shell", path: "010_all_docker.sh"
      m.vm.provision "shell", path: "015_all_k8s.sh"
    end
  end

end