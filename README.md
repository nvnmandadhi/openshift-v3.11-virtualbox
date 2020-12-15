# openshift-v3.11-virtualbox

## This repository helps install an Openshift v3.11 cluster using Ansible, VirtualBox instances and nip.io DNS

#### Instructions:
     1. vagrant up
     2. vagrant ssh master
     3. From the master run, sudo htpasswd -c /etc/origin/master/htpasswd
     4. Follow the prompt and change the password for admin user
     5. Add cluster-admin role using, oc adm policy add-cluster-role-user cluster-admin admin
     6. Access the cluster from https://console.apps.192.168.0.10.nip.io

#### References and Credts:
     1. https://www.vagrantup.com/
     2. https://nip.io/
     3. https://www.ansible.com/
     4. https://docs.okd.io/3.11/install/index.html
