#!/bin/bash
# Installs latest versions of packer and terraform and various other tools and config options


if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# packages
apt-get --yes install vim jq unzip
pip install aws

# app config  
cat << EOF > ~/.vimrc
colo desert
syntax on
EOF

# terraform
LATEST_URL=$(curl -4 -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | egrep -v 'rc|beta' | egrep 'linux.*amd64' |tail -1)
curl -4 ${LATEST_URL} > /tmp/terraform.zip
mkdir -p ${HOME}/bin
(cd ${HOME}/bin && unzip /tmp/terraform.zip)
if [[ -z $(grep 'export PATH=${HOME}/bin:${PATH}' ~/.bashrc) ]]; then
  echo 'export PATH=${HOME}/bin:${PATH}' >> ~/.bashrc
fi
echo "Installed: `${HOME}/bin/terraform version`"
  

# packer 
OS=$(uname -s)
LATEST_URL=$(curl -4 -sL https://releases.hashicorp.com/packer/index.json | jq -r '.versions[].builds[].url' | sort -n | egrep -v 'rc|beta' | egrep "${OS,,}.*amd64" |tail -1)
curl -4 ${LATEST_URL} > /tmp/packer.zip
mkdir -p ${HOME}/bin
(cd ${HOME}/bin && unzip /tmp/packer.zip)
if [[ -z $(grep 'export PATH=${HOME}/bin:${PATH}' ~/.bashrc 2>/dev/null) ]]; then
  echo 'export PATH=${HOME}/bin:${PATH}' >> ~/.bashrc
fi
  
echo "Installed: `${HOME}/bin/packer version`"

echo "Please run: source ~/.bashrc"

