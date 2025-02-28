provider "aws" {
  region = var.region
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "riverhotels"
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"  # Recommended at least 2 vCPU and 4GB RAM for Oracle XE
}
# Get default VPC
data "aws_vpc" "default" {
  default = true
}
# Security group for EC2 instance
resource "aws_security_group" "allow_ssh_oracle" {
  name        = "${var.prefix}_allow_ssh_oracle"
  description = "Allow SSH and Oracle inbound traffic"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Oracle SQL*Net access"
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Oracle EM Express access"
    from_port   = 5500
    to_port     = 5500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.prefix}-oracle-sg"
  }
}
# Local provisioner to create key pair
resource "null_resource" "ec2_key_pair" {
  provisioner "local-exec" {
    command = <<EOT
# Delete the existing key pair if it exists
aws ec2 delete-key-pair --key-name ${var.prefix}-key --region ${var.region} || echo "Key pair does not exist or was already deleted."
# Create a new key pair and output to a file
aws ec2 create-key-pair --key-name ${var.prefix}-key --query 'KeyMaterial' --output text --region ${var.region} > ${var.prefix}-key.pem
# Restrict file permissions
chmod 400 ${var.prefix}-key.pem
EOT
  }
}
# EC2 instance for Oracle
resource "aws_instance" "oracle_instance" {
  ami           = "ami-027951e78de46a00e"
  instance_type = var.instance_type
  key_name      = "${var.prefix}-key"
  security_groups = [aws_security_group.allow_ssh_oracle.name]
  depends_on = [null_resource.ec2_key_pair]
  root_block_device {
    volume_size = 30  # Oracle XE needs at least 12GB, adding extra space
    volume_type = "gp3"
  }
  user_data = <<-EOF
    #!/bin/bash
    # Update system
    dnf update -y

    # Install Docker
    dnf install -y docker
    systemctl enable docker
    systemctl start docker

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Create directory for Oracle data
    mkdir -p /opt/oracle/oradata
    chmod -R 777 /opt/oracle/oradata

    # Create docker-compose.yml file
    cat > /opt/oracle/docker-compose.yml <<'DOCKER_COMPOSE'
    version: '3'
    services:
      oracle-xe:
        image: container-registry.oracle.com/database/express:21.3.0-xe
        container_name: oracle-xe
        ports:
          - "1521:1521"
          - "5500:5500"
        environment:
          - ORACLE_PWD=Welcome1
          - ORACLE_CHARACTERSET=AL32UTF8
        volumes:
          - /opt/oracle/oradata:/opt/oracle/oradata
        restart: always
    DOCKER_COMPOSE

    # Pull Oracle XE image and start container
    cd /opt/oracle
    docker-compose up -d

    # Set up a welcome message
    echo "Oracle XE 21c setup complete. Connect using:"
    echo "Hostname: $(curl -s http://169.254.169.254/latest/meta-data/public-hostname)"
    echo "Port: 1521"
    echo "SID: XE"
    echo "PDB: XEPDB1"
    echo "Username: system"
    echo "Password: Welcome1"
    echo "EM Express URL: https://$(curl -s http://169.254.169.254/latest/meta-data/public-hostname):5500/em"
  EOF
  tags = {
    Name        = "${var.prefix}-oracle-xe"
    Owner_email = "azamzam@confluent.io"
    Event       = "Current2025"
  }
}
# Output the public DNS
output "oracle_public_dns" {
  value = aws_instance.oracle_instance.public_dns
}
output "oracle_connection_string" {
  value = "sqlplus system/Welcome1@${aws_instance.oracle_instance.public_dns}:1521/XEPDB1"
}
output "em_express_url" {
  value = "https://${aws_instance.oracle_instance.public_dns}:5500/em"
}