#! /bin/bash
set -e

echo "Provisioning the machines"
vagrant destroy --force
vagrant up
echo "<--------------------------------------------------------------------------->"

echo "Creating ssh public key in master and adding to hosts"
master_public_hostname="master.192.168.0.10.nip.io"
master="master"
key=$(vagrant ssh "$master" -c "cat /home/vagrant/.ssh/id_rsa.pub")
echo "Master public key: $key"

for vm in master node1; do
    echo "<--------------------------------------------------------------------------->"
    echo "Adding key to $vm"
    echo "<--------------------------------------------------------------------------->"
    vagrant ssh "$vm" -c "echo $key >> /home/vagrant/.ssh/authorized_keys"; 
    vagrant ssh "$vm" -c 'cat /home/vagrant/.ssh/authorized_keys';
    echo "<--------------------------------------------------------------------------->" 
done;

ssh -t "vagrant@$master_public_hostname" "ansible -m ping all -i ~/hosts"
ssh -t "vagrant@$master_public_hostname" "cd ~ && git clone https://github.com/openshift/openshift-ansible"
ssh -t "vagrant@$master_public_hostname" "cd openshift-ansible && git checkout release-3.11"
ssh -t "vagrant@$master_public_hostname" "ansible-playbook -i ~/hosts ~/openshift-ansible/playbooks/prerequisites.yml"
ssh -t "vagrant@$master_public_hostname" "ansible-playbook -i ~/hosts ~/openshift-ansible/playbooks/deploy_cluster.yml"