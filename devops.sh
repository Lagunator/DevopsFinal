#!/bin/bash
exec > /var/log/user_data.log 2>&1
set -x

# Update the system
sudo yum update -y

# Install required packages
sudo yum install -y git gcc gcc-c++ make tar
sudo amazon-linux-extras enable python3.8
sudo yum install -y python3.8 python3.8-pip

# Install Docker
sudo amazon-linux-extras enable docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

sudo -i -u ec2-user bash <<EOF
cd ~
git clone https://github.com/Sollimann/chatty-llama.git
cd chatty-llama

# Create Python virtual environment
python3.8 -m venv venv
source venv/bin/activate
pip install --upgrade pip

# Install dependencies and HuggingFace CLI
make install-huggingface-cli

# Export HuggingFace token and download the model
export HF_TOKEN="${huggingface_token}"
make download-model

# Start chatty-llama
make chatty-llama
EOF
