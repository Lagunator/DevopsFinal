#!/bin/bash
exec > /var/log/user_data.log 2>&1
set -x

# Update and upgrade the system
sudo yum update -y
sudo yum upgrade -y

# Install required system packages
sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras enable python3.8
sudo yum install -y python3.8 python3-pip python3-venv \
    git gcc gcc-c++ make curl tar

# Install Docker
sudo amazon-linux-extras enable docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Add 'ec2-user' to Docker group
sudo usermod -aG docker ec2-user

# Install Rust (as the 'ec2-user')
sudo -i -u ec2-user bash <<EOF
curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
EOF

# Clone the repository and set up Python environment
sudo -i -u ec2-user bash <<EOF
cd ~
git clone https://github.com/Sollimann/chatty-llama
cd chatty-llama

# Install Python virtual environment and dependencies
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
