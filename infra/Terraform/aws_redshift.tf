# Redshift cluster security group
resource "aws_security_group" "redshift_sg" {
  name        = "${var.prefix}-redshift-sg-${random_id.env_display_id.hex}"
  description = "Security group for Redshift cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5439
    to_port     = 5439
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
    Name = "${var.prefix}-redshift-sg-${random_id.env_display_id.hex}"
  }
}

# Redshift subnet group
resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "${var.prefix}-redshift-subnet-group-${random_id.env_display_id.hex}"
  subnet_ids = [for subnet in aws_subnet.public_subnets : subnet.id]

  tags = {
    Name = "${var.prefix}-redshift-subnet-group-${random_id.env_display_id.hex}"
  }
}

# Redshift cluster
resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier     = "${var.prefix}-redshift-cluster-${random_id.env_display_id.hex}"
  database_name         = "frauddetection"
  master_username       = "admin"
  master_password       = "Admin123456!"
  node_type            = "dc2.large"
  cluster_type         = "single-node"
  skip_final_snapshot  = true
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.redshift_sg.id]

  tags = {
    Name = "${var.prefix}-redshift-cluster-${random_id.env_display_id.hex}"
  }
}

# Output the Redshift cluster endpoint
output "redshift_endpoint" {
  value = aws_redshift_cluster.redshift_cluster.endpoint
  description = "The connection endpoint for the Redshift cluster"
} 