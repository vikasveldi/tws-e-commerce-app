#!/bin/bash

# Prevent interactive prompts during installation
export DEBIAN_FRONTEND=noninteractive

echo "========= System Update & Locks ========="
# Wait for automatic background updates to finish
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 5; done
sudo apt-get update -y

echo "========= Jenkins Setup ========="
sudo apt-get install openjdk-21-jdk -y
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "========= Docker Setup ========="
curl -fsSL https://get.docker.com -o install-docker.sh
sudo sh install-docker.sh
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
sudo systemctl restart docker
sudo systemctl restart jenkins

echo "========= AWS CLI ========="
sudo apt-get install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

echo "========= Kubectl ========="
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

echo "========= Trivy ========="
# Installed via official apt repo to automatically handle dependencies
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://github.io | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://github.io $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install trivy -y

echo "========= Helm ========="
curl https://baltocdn.com | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update -y
sudo apt-get install helm -y

echo "========= Setup Complete ========="
