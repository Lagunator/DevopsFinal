#!/bin/bash
exec > /var/log/user_data.log 2>&1
set -x

# Update the system
sudo yum update -y

# Install required packages
sudo yum install -y git gcc gcc-c++ make tar
sudo amazon-linux-extras enable python3.8
sudo yum install -y python3.8 python3-pip

# Install Docker and Docker Compose
sudo amazon-linux-extras enable docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K[0-9.v]+')" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Switch to ec2-user and set up the environment
sudo -i -u ec2-user bash <<EOF
cd ~
git clone https://github.com/Sollimann/chatty-llama.git
cd chatty-llama

# Create Python virtual environment
python3.8 -m venv venv
source venv/bin/activate
pip install --upgrade pip

# Install Python dependencies
pip install -r requirements.txt

# Install HuggingFace CLI
pip install huggingface-hub
huggingface-cli login --token "${huggingface_token}"

# Export HuggingFace token and download the model
export HF_TOKEN="${huggingface_token}"
python3 scripts/download_model.py

# Start chatty-llama using Docker Compose
docker-compose up -d
EOF
