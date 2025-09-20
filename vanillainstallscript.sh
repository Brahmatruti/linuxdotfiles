#!/bin/bash
# Deb11 Dev Environment Setup with autofs, dotfiles, env shortcuts, and Gemini CLI

set -e

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y \
  apt-transport-https ca-certificates curl gnupg2 lsb-release \
  software-properties-common wget unzip make gcc g++ libssl-dev jq git \
  build-essential python3 python3-pip python3-venv zsh nfs-common autofs

# Docker + Compose
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER

# Ansible & Terraform
sudo apt-get install -y ansible
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform

# NVM, Node.js, npm, JS tools
export NVM_VERSION="v0.40.1"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
nvm use default
npm install -g npm yarn pnpm eslint prettier

# OpenJDK
sudo apt-get install -y openjdk-17-jdk

# --- AUTOFs CONFIG ---
sudo mkdir -p /media/
echo "/media/ /etc/auto.nfs --timeout=180 --ghost" | sudo tee -a /etc/auto.master
sudo tee /etc/auto.nfs > /dev/null <<EOTA
# It is recommended to replace these hardcoded values with variables.
dlq_pod_data_sync    -fstype=nfs,nconnect=4,proto=tcp,rw,async     172.172.172.251:/dlq_prxmx_pod_data
dlq_db_data_sync    -fstype=nfs,nconnect=4,proto=tcp,rw,async     172.172.172.251:/dlq_prxmx_vm_data
nfs_dock_data_sync    -fstype=nfs,nconnect=4,proto=tcp,rw,async     172.172.172.250:/volume2/dashlab_PRXMX_SYN_NFS
EOTA
sudo systemctl restart autofs && sudo systemctl enable autofs

# --- COPY DOTFILES and FOLDERS ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for file in .zshrc .zshenv .vimrc .hushlogin .gitconfig .config; do
  [ -f "${SCRIPT_DIR}/${file}" ] && cp -f "${SCRIPT_DIR}/${file}" "$HOME/"
done
for dir in .config .zsh .ssh .npm .nvm .dotnet .vscode .ansible; do
  [ -d "${SCRIPT_DIR}/${dir}" ] && cp -rT "${SCRIPT_DIR}/${dir}" "$HOME/${dir}/"
done

# --- ENVIRONMENT SHORTCUT EXAMPLES ---
cat <<EOF > "$HOME/.exportenv"
export DEV_BIN=\$HOME/bin
export PROJECTS=\$HOME/projects
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=\$DEV_BIN:\$PATH
EOF

echo "Add '. ~/.exportenv' to your shell config to use shortcut variables."

# --- VS CODE EXTENSIONS dot FILE ---
cat << EOL > .vscode/vscode-extensions.dot
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
EOL

# --- GOOGLE GEMINI CLI ---
pip install --upgrade google-generativeai

echo "Debian 11 developer setup complete. Autofs and dotfiles are ready."