#!/bin/bash
# Comprehensive Debian 11 Dev Environment Setup

set -e

# --------------------
# System Update & Prerequisites
sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    wget \
    unzip \
    make \
    gcc \
    g++ \
    libssl-dev \
    jq \
    git \
    build-essential

# --------------------
# Python3, pip, and venv
sudo apt-get install -y python3 python3-pip python3-venv

# (Optional) Conda install (uncomment if needed)
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
# bash ~/miniconda.sh -b -p $HOME/miniconda
# export PATH="$HOME/miniconda/bin:$PATH"
# conda init

# --------------------
# Docker & Docker Compose (plugin)
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER

# (Optional) Docker Compose via pip or conda (uncomment if needed)
# python3 -m venv ~/envs/docker
# source ~/envs/docker/bin/activate
# pip install docker-compose
# conda install -c conda-forge docker-compose

# --------------------
# Ansible and Terraform
sudo apt-get install -y ansible
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform

# --------------------
# Zsh and NFS utils
sudo apt-get install -y zsh nfs-common

# --------------------
# NVM, Node.js, npm, and JS Package Managers
export NVM_VERSION="v0.40.1"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
nvm use default
npm install -g npm yarn pnpm eslint prettier

# --------------------
# Java Development Kit (OpenJDK)
sudo apt-get install -y openjdk-17-jdk

# --------------------
# (Optional) Database clients (uncomment if needed)
# sudo apt-get install -y postgresql-client mysql-client sqlite3

# --------------------
# VS Code Extension List (.dot file)
cat << EOF > vscode-extensions.dot
dbaeumer.vscode-eslint
esbenp.prettier-vscode
ms-azuretools.vscode-docker
ms-python.python
redhat.ansible
hashicorp.terraform
eamodio.gitlens
ms-vscode-remote.remote-containers
zhuangtongfa.material-theme
ritwickdey.LiveServer
formulahendry.auto-rename-tag
xabikos.JavaScriptSnippets
vscodevim.vim
golang.go
vscjava.vscode-java-pack
donjayamanne.githistory
msjsdiag.debugger-for-chrome
ms-toolsai.jupyter
EOF

# Instructions for VS Code extension install (after installing VS Code):
# while read extension; do code --install-extension \$extension; done < vscode-extensions.dot

echo "Full-stack development environment setup complete on Debian 11."
