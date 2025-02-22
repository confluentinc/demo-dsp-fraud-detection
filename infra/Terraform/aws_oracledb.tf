
# ------------------------------------------------------
# Oracle DB
# ------------------------------------------------------
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.prefix}-oracle-db-subnet-group-${random_id.env_display_id.hex}"
  description = "Subnet group for the Oracle DB instance"
  subnet_ids  = [for priv_subnet in aws_subnet.private_subnets : priv_subnet.id] # Use private subnets only
  tags = {
    Name = "${var.prefix}-oracle-db-subnet-group-${random_id.env_display_id.hex}"
  }
}

resource "aws_db_instance" "oracle_db" {
  # storage vars
  allocated_storage        = 20 # Adjust the value based on your needs
  max_allocated_storage    = 100 # Optional: Enable storage autoscaling

  # engine defaults
  engine                   = "oracle-ee" # Oracle Standard Edition Two
  engine_version           = "19.0.0.0.ru-2024-10.rur-2024-10.r1" # Replace with a supported Oracle version
  parameter_group_name     = "default.oracle-ee-19"
  instance_class           = "db.m5.large" # Adjust based on your workload
  license_model            = "bring-your-own-license"

  # database info
  username                 = var.oracle_db_username # Master username
  password                 = var.oracle_db_password # Master password, replace with a secure value
  db_name                  = var.oracle_db_name

  # backup info (required for oracle connector)
  backup_retention_period  = 7
  backup_window            = "00:00-02:00"

  # don't allow upgrades to avoid redeploy issues
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false

  # misc configs
  skip_final_snapshot      = true # Define if you want to skip backups of the database on deletion
  publicly_accessible      = false # Recommended to keep it private unless required
  apply_immediately        = true

  # networking info
  db_subnet_group_name     = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids   = [
    aws_security_group.db_sg.id
  ]

  # tags
  tags = {
    Environment = "dev"
    Name = "${var.prefix}-oracle-db-${random_id.env_display_id.hex}"
  }

}

# Security Group for oracle DB
resource "aws_security_group" "db_sg" {
  name        = "${var.prefix}-db-sg-${random_id.env_display_id.hex}"
  description = "Allow RDS Oracle access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 1521 # Oracle default port
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Adjust based on your CIDR block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-db-sg-${random_id.env_display_id.hex}"
  }
}

output "oracle_db_details" {
  value = {
    hostname = aws_db_instance.oracle_db.address
    dbname   = aws_db_instance.oracle_db.db_name
    username = aws_db_instance.oracle_db.username
    password = nonsensitive(aws_db_instance.oracle_db.password)
    port = aws_db_instance.oracle_db.port
    connection_string =  nonsensitive("${aws_db_instance.oracle_db.endpoint}/${aws_db_instance.oracle_db.db_name}")
  }
}

output "oracle_connector" {
  value = {
    table_inclusion_regex = "${aws_db_instance.oracle_db.db_name}[.]${upper(aws_db_instance.oracle_db.username)}[.](USER_TRANSACTION|AUTH_USER)"
  }
}

