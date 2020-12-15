#! /bin/bash
set -e

echo "Provisioning the machines"
vagrant destroy --force
vagrant up
echo "<--------------------------------------------------------------------------->"

echo "Creating ssh public key in master and adding to hosts"
master="master.192.168.0.10.nip.io"
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

ssh "vagrant@$master" "ansible -m ping all -i ~/hosts"
ssh "vagrant@$master" "cd ~ && git clone https://github.com/openshift/openshift-ansible"
ssh "vagrant@$master" "cd openshift-ansible && git checkout release-3.11"
ssh "vagrant@$master" "ansible-playbook -i ~/hosts ~/openshift-ansible/playbooks/prerequisites.yml"
ssh "vagrant@$master" "ansible-playbook -i ~/hosts ~/openshift-ansible/playbooks/deploy_cluster.yml"