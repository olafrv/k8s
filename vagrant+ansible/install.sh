# https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.deb

dpkg -i vagrant_2.2.9_x86_64.deb

# https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/
# vagrant up
# vagrant ssh k8s-master
# vagrant ssh node-1
# vagrant ssh node-2