
# ------------------------------------------------------
# Oracle DB
# ------------------------------------------------------
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.prefix}-oracle-db-subnet-group-${random_id.env_display_id.hex}"
  description = "Subnet group for the Oracle DB instance"
  subnet_ids  = [for priv_subnet in aws_subnet.private_subnets : priv_subnet.id] # Use private subnets only
  tags = {
    Name = "${var.prefix}-oracle-db-subnet-group"
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
    Name        = var.oracle_db_name
  }

  # Provisioner to initialize database
  # provisioner "remote-exec" {
  #   connection {
  #     type = "winrm"
  #     host = aws_instance.windows_instance.public_ip
  #     user = "Administrator"
  #     password = rsadecrypt(aws_instance.windows_instance.password_data, file("${path.module}/MyKeyPair.pem"))
  #     # Should match the password defined above
  #     # port = 5986
  #     # ssl  = true
  #     # winrm_transport = ["basic"]       # Use the appropriate transport protocol
  #     #private_key = file("${path.module}/MyKeyPair.pem")
  #   }
  #
  #   inline = [
  #     "ehco 'Database provisioning in progress'",
  #     "sqlplus ${var.oracle_db_username}/${var.oracle_db_password}@XE <<EOF"
  #   ]
  #
  # }
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
}

output "oracle_db_hostname" {
  value = aws_db_instance.oracle_db.address
}

output "oracle_db_username" {
  value = aws_db_instance.oracle_db.username
}

output "oracle_db_dbname" {
  value = aws_db_instance.oracle_db.db_name
}

output "oracle_db_password" {
  value = nonsensitive(aws_db_instance.oracle_db.password)
}

output "oracle_db_connection_string" {
  value = nonsensitive("${aws_db_instance.oracle_db.endpoint}/${aws_db_instance.oracle_db.db_name}")
}

output "oracle_db_port" {
  value = aws_db_instance.oracle_db.port
}

output "oracle_connector_table_inclusion_regex" {
  value = "${aws_db_instance.oracle_db.db_name}[.]${upper(aws_db_instance.oracle_db.username)}[.](USER_TRANSACTION|AUTH_USER)"
}



    # Use for Oracle Connector V2 (XStream)
    # inline = [
    #   # Example SQL commands to initialize the database
    #   "sqlplus ${var.oracle_db_username}/${var.oracle_db_password}@XE <<EOF",
    #   "CREATE PLUGGABLE DATABASE my_pdb ADMIN USER ${var.oracle_db_username} IDENTIFIED BY pasword FILE_NAME_CONVERT=('/var/oracle/data/', '/var/oracle/data/${var.oracle_db_name}/');",
    #   "CALTER SYSTEM SET enable_goldengate_replication=TRUE SCOPE=BOTH;",
    #   "SELECT LOG_MODE FROM V$DATABASE;",
    #   "SHUTDOWN IMMEDIATE;",
    #   "STARTUP MOUNT;",
    #   "ALTER DATABASE ARCHIVELOG;",
    #   "ALTER DATABASE OPEN;",
    #   "SELECT LOG_MODE FROM V$DATABASE;",
    #   "ALTER SESSION SET CONTAINER = CDB$ROOT;",
    #   "ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;",
    #   "SELECT SUPPLEMENTAL_LOG_DATA_MIN, SUPPLEMENTAL_LOG_DATA_ALL FROM V$DATABASE;",
    #   "CREATE TABLESPACE xstream_adm_tbs DATAFILE '/opt/oracle/oradata/${var.oracle_db_name}/xstream_adm_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;",
    #   "CREATE USER c##cfltadmin IDENTIFIED BY password DEFAULT TABLESPACE xstream_adm_tbs QUOTA UNLIMITED ON xstream_adm_tbs CONTAINER=ALL;",
    #   "GRANT CREATE SESSION, SET CONTAINER TO c##cfltadmin CONTAINER=ALL;",
    #   "BEGIN",
    #     "DBMS_XSTREAM_AUTH.GRANT_ADMIN_PRIVILEGE(",
    #     "grantee                 => 'c##cfltadmin',",
    #     "privilege_type          => 'CAPTURE',",
    #     "grant_select_privileges => TRUE,",
    #     "container               => 'ALL');",
    #   "END;",
    #
    #   "CREATE TABLESPACE xstream_tbs DATAFILE '/opt/oracle/oradata/${var.oracle_db_name}/xstream_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;",
    #
    #   "CREATE USER c##cfltuser IDENTIFIED BY password",
    #   "DEFAULT TABLESPACE xstream_tbs",
    #   "QUOTA UNLIMITED ON xstream_tbs",
    #   "CONTAINER=ALL;",
    #
    #   "GRANT CREATE SESSION, SET CONTAINER TO c##cfltuser CONTAINER=ALL;",
    #   "GRANT SELECT_CATALOG_ROLE TO c##cfltuser CONTAINER=ALL;",
    #   "GRANT FLASHBACK ANY TABLE TO c##cfltuser CONTAINER=ALL;",
    #   "GRANT SELECT ANY TABLE TO c##cfltuser CONTAINER=ALL;",
    #   "GRANT LOCK ANY TABLE TO c##cfltuser CONTAINER=ALL;",
    #
    #   "DECLARE",
    #     "tables  DBMS_UTILITY.UNCL_ARRAY;",
    #     "schemas DBMS_UTILITY.UNCL_ARRAY;",
    #   "BEGIN",
    #     "tables(1)  := 'sample.employees';",
    #     "schemas(1) := NULL;",
    #    "DBMS_XSTREAM_ADM.CREATE_OUTBOUND(",
    #     "server_name           =>  'xout',",
    #     "source_container_name =>  '${var.oracle_db_name}',",
    #     "table_names           =>  tables,",
    #     "schema_names          =>  schemas);",
    #   "END;",
    #
    #   "BEGIN",
    #     "DBMS_XSTREAM_ADM.ALTER_OUTBOUND(",
    #     "server_name  => 'xout',",
    #     "connect_user => 'c##cfltuser');",
    #   "END;",
    #
    #   "BEGIN",
	#     "DBMS_CAPTURE_ADM.ALTER_CAPTURE(",
    #       "capture_name => 'CAP$_XOUT_624',",
	#       "checkpoint_retention_time => 7",
	#     ");",
    #   "END;",
    #
    #   "SELECT CAPTURE_NAME FROM ALL_XSTREAM_OUTBOUND WHERE SERVER_NAME = 'XOUT';",
    #
    #   "EXIT;",
    #   "EOF"
