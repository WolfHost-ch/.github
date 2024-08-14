#!/bin/bash
echo "/--------------------------\\"
echo "| Starting server setup... |"
echo "\\--------------------------/"
echo ""

echo "Update/grade packages..."
# Add alias to .bashrc
if ! grep -q "alias 'update'='sudo apt-get update;sudo apt-get upgrade -y'" ~/.bashrc; then
    echo "alias 'update'='sudo apt-get update;sudo apt-get upgrade -y'" >> ~/.bashrc
fi

# Update package list
sudo apt-get -qq update
# Upgrade installed packages
sudo apt-get -qq upgrade -y

# Install specified packages
sudo apt-get -qq install -y nano git curl wget tree sl htop nmap net-tools iputils-ping apt-transport-https ca-certificates curl software-properties-common glusterfs-client

echo "Installing Docker..."
# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -qq update
sudo apt -qq install docker-ce

# Add user to docker group
sudo usermod -aG docker ${USER}

# su - ${USER}

# Source .bashrc to apply the alias
source ~/.bashrc

echo "Setting up hostname..."
# add hostnames to /etc/hosts
HOSTS=(
    "10.10.100.51 manager1"
    "10.10.100.52 manager2"
    "10.10.100.53 manager3"
    "10.10.100.61 worker1"
    "10.10.100.62 worker2"
    "10.10.100.63 worker3"
    "10.10.100.71 storage1"
    "10.10.100.72 storage2"
    "10.10.100.73 storage3"
)

for HOST in "${HOSTS[@]}"; do
    if ! grep -q "$HOST" /etc/hosts; then
        echo "$HOST" | sudo tee -a /etc/hosts
    fi
done

echo "Setting up GlusterFS..."
# Add mount point for GlusterFS
sudo mkdir -p /mnt/dockerdata
sudo mount -t glusterfs storage1:/gv0 /mnt/dockerdata
df -h /mnt/glusterfs
echo "storage1:/gv0 /mnt/glusterfs glusterfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

echo ""
echo "/--------------------------\\"
echo "|  Server setup complete!  |"
echo "\\--------------------------/"