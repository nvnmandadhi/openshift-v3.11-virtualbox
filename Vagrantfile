# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01"

  boxes = [
    {
        :name => "master",
        :hostname => "master.192.168.0.10.nip.io",
        :eth1 => "192.168.0.10",
        :mem => "8192",
        :cpu => "4",
        :box_name => "master"
    },
    {
      :name => "node1",
      :hostname => "node1.192.168.0.11.nip.io",
      :eth1 => "192.168.0.11",
      :mem => "2048",
      :cpu => "2",
      :box_name => "node1"
    },
  ]

  PRIVATE_KEY = "~/.ssh/id_rsa"
  PUBLIC_KEY  = '~/.ssh/id_rsa.pub'
  ANSIBLE_HOSTS  = 'inventory-all-in-one.ini'

  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.network :private_network, ip: opts[:eth1], hostname: true
      config.ssh.insert_key = false
      config.ssh.private_key_path = [PRIVATE_KEY, "~/.vagrant.d/insecure_private_key"]
      config.vm.provision "file", source: PUBLIC_KEY, destination: "~/.ssh/authorized_keys"
      config.vm.provision "file", source: ANSIBLE_HOSTS, destination: "hosts"
      config.ssh.username = "vagrant"
      config.vm.hostname = opts[:hostname]
    
      config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.name = opts[:box_name]
        vb.memory = opts[:mem]
        vb.cpus = opts[:cpu]
      end
      
      if opts[:name] == "master"
        config.vm.provision "shell", privileged: false, inline: <<-SHELL
          set -e
          sudo yum -y install wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct nano git httpd-tools
          sudo yum -y install "https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
          sudo sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
          sudo yum -y --enablerepo=epel install ansible pyOpenSSL
          ansible --version
          ssh-keygen -f /home/vagrant/.ssh/id_rsa -t rsa -N ''
          cat /home/vagrant/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
        SHELL
      end

      config.vm.provision "shell", privileged: true, inline: <<-SHELL
        set -e
        echo "Host *
        StrictHostKeyChecking no
        UserKnownHostsFile=/dev/null" >> /home/vagrant/.ssh/config

        ip_addr=`ifconfig eth1 | awk '/inet / {print $2}'`
        echo "My hostname: `hostname -f` ip: $ip_addr"
        
        echo "search nip.io" >> /etc/resolv.conf
        echo "nameserver 8.8.8.8" >> /etc/resolv.conf
      SHELL
    end
  end
end