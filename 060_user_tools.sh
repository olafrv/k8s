#!/bin/bash

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
sudo apt-get -y update && sudo apt-get install -y apt-transport-https curl ;
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - ;
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get -y update ;
sudo apt-get install -y kubectl ;
sudo apt-mark hold kubelet ;

# https://github.com/ahmetb/kubectx
rm -rf ~/.kubectx
git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
COMPDIR=$(pkg-config --variable=completionsdir bash-completion)
sudo ln -sf ~/.kubectx/completion/kubens.bash $COMPDIR/kubens
sudo ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx
tee -a ~/.bashrc << EOF
#kubectx and kubens
export PATH=~/.kubectx:\$PATH
EOF

# https://github.com/derailed/k9s (Too complex and slow to install!)
# https://snapcraft.io/install/k9s/ubuntu (Does not load config! Bug!)
# https://github.com/derailed/k9s/releases
wget https://github.com/derailed/k9s/releases/download/v0.19.3/k9s_Linux_x86_64.tar.gz
tar xvfz k9s_Linux_x86_64.tar.gz k9s
chmod +x k9s
sudo mv k9s /usr/local/bin/k9s


# https://github.com/ahmetb/kubectl-aliases
wget https://raw.githubusercontent.com/ahmetb/kubectl-alias/master/.kubectl_aliases -O ~/.kubectl_aliases
tee -a ~/.bashrc <<EOF
[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
# Do not work on ubuntu 16.04!
# function kubectl() { echo "+ kubectl $@">&2; command kubectl $@; }
EOF