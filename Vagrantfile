K8S_IMAGE_NAME = ENV["K8S_IMAGE_NAME"]
K8S_LOADBALANCERS = ENV["K8S_LOADBALANCERS"].to_i
K8S_MASTERS = ENV["K8S_MASTERS"].to_i
K8S_WORKERS = ENV["K8S_WORKERS"].to_i
K8S_ETCDS = ENV["K8S_ETCDS"].to_i
K8S_SUBNET = ENV["K8S_SUBNET"]

if K8S_LOADBALANCERS.to_i == 0
  print "First, source environment.sh" "\n"
  exit 2
end

Vagrant.configure("2") do |c|
  
  c.vm.provision "shell" do |s|
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    s.inline = <<-SHELL
      echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
    SHELL
  end

  (1..9).each do |i|
    break if i == K8S_LOADBALANCERS+1
    c.vm.define "kload#{i}" do |m|
      m.vm.box = K8S_IMAGE_NAME
      m.vm.hostname = "kload#{i}"
      m.vm.provider "virtualbox" do |v|
        v.memory = 512
        v.cpus = 2
      end
      m.vm.network "private_network", ip: "#{K8S_SUBNET}.#{i + 10}"
    end
  end

  (1..9).each do |i|
    break if i == K8S_ETCDS+1
    c.vm.define "ketcd#{i}" do |m|
      m.vm.box = K8S_IMAGE_NAME
      m.vm.hostname = "ketcd#{i}"
      m.vm.provider "virtualbox" do |v|
        v.memory = 798
        v.cpus = 2
      end
      m.vm.network "private_network", ip: "#{K8S_SUBNET}.#{i + 20}"
    end 
  end

  (1..9).each do |i|
    break if i == K8S_MASTERS+1
    c.vm.define "kmast#{i}" do |m|
      m.vm.box = K8S_IMAGE_NAME
      m.vm.hostname = "kmast#{i}"
      m.vm.provider "virtualbox" do |v|
        v.memory = 1536
        v.cpus = 2
      end
      m.vm.network "private_network", ip: "#{K8S_SUBNET}.#{i + 30}"
    end          
  end

  (1..9).each do |i|
    break if i == K8S_WORKERS+1
    c.vm.define "kwork#{i}" do |m|
      m.vm.box = K8S_IMAGE_NAME
      m.vm.hostname = "kwork#{i}"
      m.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
      end
      m.vm.network "private_network", ip: "#{K8S_SUBNET}.#{i + 40}"
    end
  end

end