
# Optional: Define a variable for mapping AMIs to the correct SSH user
variable "ssh_user" {
  description = "SSH user based on AMI type"
  type        = map(string)
  default     = {
    # Amazon Linux
    "ami-0c55b159cbfafe1f0" = "ec2-user"
    # Ubuntu
    "ami-0885b1f6bd170450c" = "ubuntu"
    # RHEL
    "ami-0b0af3577fe5e3532" = "ec2-user"
    # Debian
    "ami-0bd9223868b4778d7" = "admin"
    # CentOS
    "ami-0f2b4fc905b0bd1f1" = "centos"
    # Oracle Linux
    "ami-07af4f1c7eb1971ff" = "ec2-user"
  }
}
# Security group for EC2 instance
resource "aws_security_group" "allow_ssh_oracle" {
  name        = "${var.prefix}_allow_ssh_oracle"
  description = "Allow SSH and Oracle inbound traffic"
  vpc_id      = aws_vpc.main.id
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

# EC2 instance for Oracle
# /var/log/cloud-init.log
#/var/log/cloud-init-output.log
# /var/lib/cloud/instances/i-0c42e1665ff8e11f2/user-data.txt
# sudo cat /var/lib/cloud/instance/scripts/part-001
resource "aws_instance" "oracle_instance" {
  ami           = var.oracle_ami

  instance_type = "t3.large"
  key_name      = aws_key_pair.tf_key.key_name
  subnet_id              = aws_subnet.public_subnets[0].id # Associate with the first public subnet - put this in private subnet?


  vpc_security_group_ids = [aws_security_group.allow_ssh_oracle.id]
  security_groups = [aws_security_group.allow_ssh_oracle.id]
  root_block_device {
    volume_size = 30  # Oracle XE needs at least 12GB, adding extra space
    volume_type = "gp3"
  }

  user_data_replace_on_change = true
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

sudo docker exec -it oracle-xe sqlplus sys/Welcome1@localhost:1521/XEPDB1 as sysdba



# Oracle Setup


CREATE TABLESPACE xstream_adm_tbs DATAFILE '/opt/oracle/oradata/XE/xstream_adm_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;


ALTER SESSION SET CONTAINER=XEPDB1;

CREATE TABLESPACE xstream_adm_tbs DATAFILE '/opt/oracle/oradata/XE/XEPDB1/xstream_adm_tbs_2.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

ALTER SESSION SET CONTAINER=CDB$ROOT;


CREATE USER c##cfltadmin IDENTIFIED BY Welcome1 DEFAULT TABLESPACE xstream_adm_tbs QUOTA UNLIMITED ON xstream_adm_tbs CONTAINER=ALL;


GRANT CREATE SESSION, SET CONTAINER TO c##cfltadmin CONTAINER=ALL;


BEGIN
DBMS_XSTREAM_AUTH.GRANT_ADMIN_PRIVILEGE(grantee => 'c##cfltadmin', privilege_type => 'CAPTURE', grant_select_privileges => TRUE, container => 'ALL');
END;
/



CREATE TABLESPACE xstream_tbs DATAFILE '/opt/oracle/oradata/XE/xstream_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;


ALTER SESSION SET CONTAINER=XEPDB1;


CREATE TABLESPACE xstream_tbs DATAFILE '/opt/oracle/oradata/XE/XEPDB1/xstream_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

ALTER SESSION SET CONTAINER=CDB$ROOT;


CREATE USER c##cfltuser IDENTIFIED BY Welcome1 DEFAULT TABLESPACE xstream_tbs QUOTA UNLIMITED ON xstream_tbs CONTAINER=ALL;


GRANT CREATE SESSION, SET CONTAINER TO c##cfltuser CONTAINER=ALL;

GRANT SELECT_CATALOG_ROLE TO c##cfltuser CONTAINER=ALL;


GRANT FLASHBACK ANY TABLE TO c##cfltuser CONTAINER=ALL;

GRANT SELECT ANY TABLE TO c##cfltuser CONTAINER=ALL;

GRANT LOCK ANY TABLE TO c##cfltuser CONTAINER=ALL;

# Run this by logging to SQLPLUS using c##cfltadmin

BEGIN
  DBMS_XSTREAM_ADM.ALTER_OUTBOUND(
    server_name    => 'xout',
    table_names    => NULL,
    schema_names   => 'sample',
    add            => TRUE,
    inclusion_rule => TRUE);
END;
/


BEGIN
  DBMS_XSTREAM_ADM.ALTER_OUTBOUND(
     server_name  => 'xout',
     connect_user => 'c##cfltuser');
END;
/
  EOF
  tags = {
    Name        = "${var.prefix}-oracle-xe"
    Owner_email = "azamzam@confluent.io"
    Event       = "Current2025"
  }
}

output "oracle_vm_db_details" {
  value = {
    "public_dns": aws_instance.oracle_instance.public_dns
    "connection_string": "sqlplus system/Welcome1@${aws_instance.oracle_instance.public_dns}:1521/XEPDB1"
    "express_url": "https://${aws_instance.oracle_instance.public_dns}:5500/em"
    "ssh": "ssh -i ${local_file.tf_key.filename} ${lookup(var.ssh_user, var.oracle_ami, "ec2-user")}@${aws_instance.oracle_instance.public_ip}"
  }
}
