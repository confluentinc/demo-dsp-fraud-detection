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

# other logs - C:\UserData.log
# boot logs - C:\ProgramData\Amazon\EC2Launch\log\agent.log
# User Data Script Format - C:\Windows\system32\config\systemprofile\AppData\Local\Temp\EC2Launch3950882895\UserScript.ps1
# User Data Error Format - C:\Windows\system32\config\systemprofile\AppData\Local\Temp\EC2Launch3950882895\err.tmp
# User Data Output Format - C:\Windows\system32\config\systemprofile\AppData\Local\Temp\EC2Launch3950882895\output.tmp
resource "aws_instance" "windows_instance" {
  ami                    = data.aws_ami.windows.image_id
  instance_type          = "t3.xlarge"
  key_name               = "MyKeyPair" # Replace with your key pair name
  vpc_security_group_ids = [aws_security_group.windows_sg.id]
  subnet_id              = aws_subnet.public_subnets[0].id # Associate with the first public subnet - put this in private subnet?
  get_password_data      = true
  root_block_device {
    volume_size = 60 # Adjust the volume size as needed
  }
  tags = {
    Name = "${var.prefix}-windows-instance-${random_id.env_display_id.hex}"
  }
  user_data_replace_on_change = true
  # Enable WinRM
  user_data = <<-EOF
<powershell>
Start-Transcript -Path "C:\UserData.log" -Append
# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator"
    exit
}

# Create temporary directory for downloads
$tempDir = "C:\temp\python_oracle_setup"
New-Item -ItemType Directory -Force -Path $tempDir

# Download and install Python
Write-Host "Downloading Python..."
$pythonUrl = "https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe"
$pythonInstaller = "$tempDir\python_installer.exe"
Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller

Write-Host "Installing Python..."
Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install cx_Oracle using pip
Write-Host "Installing cx_Oracle..."
python -m pip install cx_Oracle

# Download and extract Oracle Instant Client
Write-Host "Downloading Oracle Instant Client..."
$oracleUrl = "https://download.oracle.com/otn_software/nt/instantclient/219000/instantclient-basic-windows.x64-21.9.0.0.0dbru.zip"
$oracleZip = "$tempDir\oracle_client.zip"
Invoke-WebRequest -Uri $oracleUrl -OutFile $oracleZip

# Extract Oracle Instant Client
$oracleClientPath = "C:\oracle"
New-Item -ItemType Directory -Force -Path $oracleClientPath
Expand-Archive -Path $oracleZip -DestinationPath $oracleClientPath -Force

# Add Oracle Instant Client to PATH
$instantClientPath = (Get-ChildItem -Path $oracleClientPath -Filter "instantclient*" | Select-Object -First 1).FullName
[Environment]::SetEnvironmentVariable("PATH", $env:Path + ";$instantClientPath", "Machine")
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

# Create Python script
$pythonScript = @"
# -*- coding: utf-8 -*-
import cx_Oracle

connection = cx_Oracle.connect(
    user="${aws_db_instance.oracle_db.username}",
    password="${aws_db_instance.oracle_db.password}",
    dsn="${aws_db_instance.oracle_db.address}:${aws_db_instance.oracle_db.port}/${aws_db_instance.oracle_db.db_name}"
)

cursor = connection.cursor()

# Check database log mode
print("Checking database log mode prior...")
cursor.execute("SELECT log_mode FROM v`$database")
log_mode = cursor.fetchone()
print(f"Current database log mode: {log_mode[0]}")

# Configure supplemental logging
print("\nConfiguring supplemental logging...")
cursor.execute("""
begin
 rdsadmin.rdsadmin_util.alter_supplemental_logging(
     p_action => 'ADD',
     p_type   => 'ALL');
end;
""")
connection.commit()

print("Checking database log mode post...")
cursor.execute("SELECT log_mode FROM v`$database")
log_mode = cursor.fetchone()
print(f"Current database log mode: {log_mode[0]}")

cursor.close()
connection.close()
print("Supplemental logging configuration completed successfully")
"@

# Save and run the Python script
Write-Host "Creating Python script..."
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines("$tempDir\oracle_config.py", $pythonScript, $Utf8NoBomEncoding)

Write-Host "Running Oracle configuration..."
python "$tempDir\oracle_config.py"

# Cleanup
Write-Host "Cleaning up temporary files..."
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "Setup completed successfully!"
</powershell>
EOF

  depends_on = [null_resource.ec2_key_pair, aws_db_instance.oracle_db]
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
    password = rsadecrypt(aws_instance.windows_instance.password_data, file("${path.module}/MyKeyPair.pem"))
  }
}

