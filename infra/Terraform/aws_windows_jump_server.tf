data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }
}

# resource "null_resource" "ec2_key_pair" {
#   provisioner "local-exec" {
#     command =  <<EOT
# # Remove any previous key-pairs
#
# # Delete the existing key pair if it exists
# aws ec2 delete-key-pair --key-name ${var.prefix}-key-${random_id.env_display_id.hex}.pem --region ${var.region} || echo "Key pair ${var.prefix}-key-${random_id.env_display_id.hex}.pem does not exist or was already deleted."
#
# # Create a new key pair and output to a temporary file
# aws ec2 create-key-pair --key-name ${var.prefix}-key-${random_id.env_display_id.hex} --query 'KeyMaterial' --output text --region ${var.region} > ${var.prefix}-key-${random_id.env_display_id.hex}.pem
# EOT
#   }
# }

# other logs - C:\UserData.log
# boot logs - C:\ProgramData\Amazon\EC2Launch\log\agent.log
# User Data Script Format - C:\Windows\system32\config\systemprofile\AppData\Local\Temp\EC2Launch3950882895\UserScript.ps1
# User Data Error Format - C:\Windows\system32\config\systemprofile\AppData\Local\Temp\EC2Launch3950882895\err.tmp
# User Data Output Format - C:\Windows\system32\config\systemprofile\AppData\Local\Temp\EC2Launch3950882895\output.tmp
resource "aws_instance" "windows_instance" {
  ami                    = data.aws_ami.windows.image_id
  instance_type          = "t3.xlarge"
  key_name               = aws_key_pair.tf_key.key_name # Replace with your key pair name
  vpc_security_group_ids = [aws_security_group.windows_sg.id]
  subnet_id              = aws_subnet.public_subnets[0].id # Associate with the first public subnet - put this in private subnet?
  get_password_data      = true
  root_block_device {
    volume_size = 60 # Adjust the volume size as needed
  }
  tags = {
    Name = "${var.prefix}-windows-instance-${random_id.env_display_id.hex}"
  }
  
  depends_on = [aws_instance.oracle_instance]
}
# $ used to equal \$

resource "aws_security_group" "windows_sg" {
  name        = "${var.prefix}-windows-sg-${random_id.env_display_id.hex}"
  description = "Allow RDP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5985
    to_port     = 5986
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
    Name = "${var.prefix}-windows-sg-${random_id.env_display_id.hex}"
  }
}



output "windows_jump_server_details" {
  value = {
    ip       = aws_instance.windows_instance.public_ip
    username = "Administrator"
    password = nonsensitive(rsadecrypt(aws_instance.windows_instance.password_data, local_file.tf_key.content))
  }
}

