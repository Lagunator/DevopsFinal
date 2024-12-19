#!/bin/bash
exec > /var/log/user_data.log 2>&1
set -x

# Update the system
sudo yum update -y

# Install required packages
sudo yum install -y git gcc gcc-c++ make tar
sudo amazon-linux-extras enable python3.8  # Ensure Amazon Linux provides Python 3
sudo yum install -y python3 python3-pip

# Install Docker and Docker Compose
sudo amazon-linux-extras enable docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
DOCKER_COMPOSE_VERSION="2.20.2"
sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found. Adding to PATH manually."
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

docker-compose --version

# Switch to ec2-user and set up the environment
sudo -i -u ec2-user bash <<EOF
cd ~
git clone https://github.com/Sollimann/chatty-llama.git
cd chatty-llama

# Create Python virtual environment
python3 -m venv venv
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
docker-compose up -d
EOF
