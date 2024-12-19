#!/bin/bash
exec > /var/log/user_data.log 2>&1
set -x

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y apt-transport-https ca-certificates curl \
    software-properties-common git python3-pip python3-venv \
    build-essential make

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker ubuntu
sudo -i -u ubuntu bash <<EOF
curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
EOF

sudo -i -u ubuntu bash <<EOF
cd ~
git clone https://github.com/Sollimann/chatty-llama.git
cd chatty-llama

# Install Python virtual environment and dependencies
python3 -m venv venv
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
