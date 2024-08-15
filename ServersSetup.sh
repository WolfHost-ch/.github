#!/bin/bash
echo "/--------------------------\\"
echo "| Starting server setup... |"
echo "\\--------------------------/"
echo ""

# Check if user has sudo permissions
echo "Getting SUDO permissions..."
if [ $(id -u) -ne 0 ]; then
    sudo echo "" > /dev/null
fi

# Add alias to .bashrc
echo "Adding aliases..."
if ! grep -q "alias 'update'='sudo apt-get update;sudo apt-get upgrade -y'" ~/.bashrc; then
    echo "alias 'update'='sudo apt-get update;sudo apt-get upgrade -y'" >> ~/.bashrc
fi
source ~/.bashrc

# Upgrade installed packages
echo "Update/grade packages..."
sudo apt-get update > /dev/null
sudo apt-get upgrade -y > /dev/null

# Install specified packages
PACKAGES=(
    "nano"
    "git"
    "curl"
    "wget"
    "tree"
    "sl"
    "htop"
    "nmap"
    "net-tools"
    "iputils-ping"
    "apt-transport-https"
    "ca-certificates"
    "curl"
    "software-properties-common"
    "glusterfs-client"
)

echo "Installing packages..."
for PACKAGE in "${PACKAGES[@]}"; do
    if ! dpkg -l | grep -q $PACKAGE; then
        sudo apt-get install $PACKAGE -y > /dev/null
    fi
done

# Install Docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update > /dev/null
sudo apt-get install docker-ce -y > /dev/null

# Add user to docker group
sudo usermod -aG docker ${USER}

# su - ${USER}

# add hostnames to /etc/hosts
echo "Setting up hostname..."
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
        echo "$HOST" | sudo tee -a /etc/hosts > /dev/null
    fi
done

# Add mount point for GlusterFS
echo "Setting up GlusterFS..."
sudo mkdir -p /mnt/dockerdata
# TODO: verify /gv0
sudo mount -t glusterfs storage1:/gv0 /mnt/dockerdata > /dev/null
echo "storage1:/gv0 /mnt/dockerdata glusterfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab > /dev/null

# Change ownership and set permissions
sudo chown ${USER}:${USER} /mnt/dockerdata
sudo chmod 775 /mnt/dockerdata

echo ""
echo "/--------------------------\\"
echo "|  Server setup complete!  |"
echo "\\--------------------------/"