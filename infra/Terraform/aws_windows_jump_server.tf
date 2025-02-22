data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }
}

resource "null_resource" "ec2_key_pair" {
  provisioner "local-exec" {
    command =  <<EOT
# Remove any previous key-pairs
rm

# Delete the existing key pair if it exists
aws ec2 delete-key-pair --key-name MyKeyPair --region ${var.region} || echo "Key pair MyKeyPair does not exist or was already deleted."

# Create a new key pair and output to a temporary file
aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text --region ${var.region} > temp_key.pem

# If successful, rename the temporary key file to MyKeyPair.pem
if [ $? -eq 0 ]; then
  mv temp_key.pem MyKeyPair.pem
  chmod 400 MyKeyPair.pem # Restrict file permissions
fi
EOT
  }
}

resource "aws_instance" "windows_instance" {
  ami                    = data.aws_ami.windows.image_id
  instance_type          = "t3.xlarge"
  key_name               = "MyKeyPair" # Replace with your key pair name
  vpc_security_group_ids = [aws_security_group.windows_sg.id]
  subnet_id              = aws_subnet.public_subnets[0].id # Associate with the first public subnet - put this in private subnet?
  get_password_data      = true
  root_block_device {
    volume_size = 30 # Adjust the volume size as needed
  }
  tags = {
    Name = "${var.prefix}-windows-instance-${random_id.env_display_id.hex}"
  }

    user_data = <<-EOF
    <powershell>
    # Step 1: Download Oracle XE (with license acceptance headers)
    $oracleXEUrl = "https://download.oracle.com/otn-pub/otn_software/db-express/OracleXE213_Win64.zip"
    $downloadPath = "C:\OracleXE.zip"
    $headers = @{
      "Cookie" = "oraclelicense=accept-securebackup-cookie"
    }
    Invoke-WebRequest -Uri $oracleXEUrl -Headers $headers -OutFile $downloadPath -UseBasicParsing

    # Step 2 & 3: Connect to RDS Oracle and execute PL/SQL
    $connectionParams = "thebestusername/thebestpasswordever!@terraform-20250131031349887600000007.cy56rbcnrbof.us-west-2.rds.amazonaws.com:1521/DEMODB"
    $plsqlCommand = @"
    begin
      rdsadmin.rdsadmin_util.alter_supplemental_logging(
          p_action => 'ADD',
          p_type   => 'ALL');
    end;
    /
    "@

    # Save the SQL command to a file and execute with SQL*Plus
    $plsqlCommand | Out-File -FilePath "C:\run_plsql.sql" -Encoding ASCII
    sqlplus -S $connectionParams "@C:\run_plsql.sql"
    </powershell>
    EOF

  user_data_replace_on_change = true

  depends_on = [null_resource.ec2_key_pair]
}

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
    password = rsadecrypt(aws_instance.windows_instance.password_data, file("${path.module}/MyKeyPair.pem"))
  }
}

