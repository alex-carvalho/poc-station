#!/bin/bash
set -e

sudo dnf update -y
sudo dnf install -y dnf-plugins-core git curl wget unzip

sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo dnf install -y terraform

sudo dnf install -y docker
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user

curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey="${tailscale_auth_key}" --accept-routes

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  KIND_ARCH="amd64"
  KUBECTL_ARCH="amd64"
else
  KIND_ARCH="arm64"
  KUBECTL_ARCH="arm64"
fi

curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-$${KIND_ARCH}"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$${KUBECTL_ARCH}/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

sudo -u ec2-user git clone https://github.com/alex-carvalho/sandbox.git /home/ec2-user/sandbox
