#!/bin/bash

echo "Enter the Vagrant box you want to install (default 'ubuntu/jammy64'): "
read -r BOX_NAME
BOX_NAME=${BOX_NAME:-ubuntu/jammy64}

# Convert the box name to a directory name format
DIR_NAME=${BOX_NAME//\//_}

echo "Enter the name for the project directory (default '${DIR_NAME}'): "
read -r PROJECT_DIR
PROJECT_DIR=${PROJECT_DIR:-$DIR_NAME}

# Check if directory exists and create a unique directory name if necessary
COUNTER=1
ORIGINAL_PROJECT_DIR=$PROJECT_DIR
while [ -d "$PROJECT_DIR" ]; do
  PROJECT_DIR="${ORIGINAL_PROJECT_DIR}_${COUNTER}"
  let COUNTER=COUNTER+1
done

# Create the project directory
mkdir "$PROJECT_DIR"
echo "Project directory created: $PROJECT_DIR"

cd "$PROJECT_DIR" || exit

echo "Enter the username (default 'vagrant'): "
read -r USERNAME
USERNAME=${USERNAME:-vagrant}

echo "Choose authentication type [key/SSH] (default 'SSH'): "
read -r AUTH_TYPE
AUTH_TYPE=${AUTH_TYPE:-SSH}

if [ "$AUTH_TYPE" == "SSH" ]; then
  echo "Enter SSH password (leave blank to generate a random one): "
  read -r SSH_PASS
  if [ -z "$SSH_PASS" ]; then
    SSH_PASS=$(openssl rand -base64 12)
    echo "Generated SSH password: $SSH_PASS"
  fi
else
  SSH_PASS="Using Key Authentication"
fi

# Generate the Vagrantfile
cat > Vagrantfile <<EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "$BOX_NAME"
  config.vm.network "public_network"

  # Provisioning script to update SSH settings
  config.vm.provision "shell", inline: <<-SHELL
    echo "$USERNAME:$SSH_PASS" | sudo chpasswd
    echo -e "PasswordAuthentication yes\nPubkeyAuthentication yes" | sudo tee /etc/ssh/sshd_config.d/0000000_config.conf > /dev/null
    sudo systemctl restart sshd
  SHELL
  
  # SSH configuration, uncomment the following for convenience after provisioning
  # config.ssh.username = "$USERNAME"
  # config.ssh.password = "$SSH_PASS"

  # Uncomment the following for port-forwards
  # config.vm.network "forwarded_port", guest: 80, host: 80
  # config.vm.network "forwarded_port", guest: 443, host: 443
  # config.vm.network "forwarded_port", guest: 22, host: 12345
  # config.vm.network "forwarded_port", guest: 54252, host: 54252
  # config.vm.network "forwarded_port", guest: 54252, host: 54252, protocol: "udp"
  # config.vm.network :forwarded_port, guest: 54252, guest_ip: "10.0.x.x", host: 54252, host_ip: "0.0.0.0", protocol: "udp"
  # config.vm.network :forwarded_port, guest: 55555, guest_ip: "10.0.x.x", host: 55555, host_ip: "x.x.x.x", protocol: "udp"
end
EOF

# Store configuration for reference
cat > config_info.txt <<EOF
Project Directory: $PROJECT_DIR
Vagrant Box: $BOX_NAME
Username: $USERNAME
Authentication Type: $AUTH_TYPE
SSH Password: $SSH_PASS
EOF

echo "Vagrant project setup complete."
echo "Change Vagrantfile to finalize the settings."
echo $'\n' $'\n' $'\n' $'\n' $'\n'

vagrant up
vagrant ssh
