provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2_key"
  public_key = file("ec2key.pub")
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "huggingface_token" {
  description = "HuggingFace API Token"
  type        = string
  sensitive   = true
}



resource "aws_instance" "lagu_llama" {
  ami           = "ami-01816d07b1128cd2d" 
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_key.key_name

  root_block_device {
    volume_size = 20
  }

  user_data = templatefile("devops.sh", {
    huggingface_token = var.huggingface_token
  })

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "lagu-llama-ec2-ultimo"
  }
}

terraform {
 backend "s3" {
   bucket         = "deployfinaltest"
   key            = "global/s3/terraform.tfstate"
   region         = "us-east-1"
   dynamodb_table = "deployfinaltest"
   encrypt        = true
 }
}


output "instance_ip" {
  value = aws_instance.lagu_llama.public_ip
}
