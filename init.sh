#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get install -y gnupg software-properties-common curl wget unzip

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update -y
sudo apt-get install -y terraform docker.io

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  KIND_ARCH="amd64"
  KUBECTL_ARCH="amd64"
else
  KIND_ARCH="arm64"
  KUBECTL_ARCH="arm64"
fi

curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-${KIND_ARCH}"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${KUBECTL_ARCH}/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
