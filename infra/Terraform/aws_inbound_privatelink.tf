
# VPC Endpoint Service
resource "aws_vpc_endpoint_service" "rds_endpoint_service" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.rds_oracle_nlb.arn]

  tags = {
    Name = "${var.prefix}-rds-endpoint-services-${random_id.env_display_id.hex}"
  }
}

resource "null_resource" "reject_connections" {
  triggers = {
    service_id = aws_vpc_endpoint_service.rds_endpoint_service.id
  }

  provisioner "local-exec" {
    command = "${var.reject_connections_script} ${aws_vpc_endpoint_service.rds_endpoint_service.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Add service permission policy
resource "aws_vpc_endpoint_service_allowed_principal" "allow_confluent_rds_gateway" {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.rds_endpoint_service.id
  principal_arn           = confluent_gateway.confluent_rds_gateway.aws_egress_private_link_gateway[0].principal_arn
}

# Network Load Balancer
resource "aws_lb" "rds_oracle_nlb" {
  name                             = "${var.prefix}-nlb-${random_id.env_display_id.hex}"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = [for subnet in aws_subnet.private_subnets : subnet.id]
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.prefix}-rds-oracle-nlb-${random_id.env_display_id.hex}"
  }
}

# NLB Listener
resource "aws_lb_listener" "rds_lb_listener" {
  load_balancer_arn = aws_lb.rds_oracle_nlb.arn
  port              = 1521
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rds_oracle_target_group.arn
  }
  tags = {
    Name = "${var.prefix}-rds-oracle-lb-listener-${random_id.env_display_id.hex}"
  }
}

# NLB Target Group
resource "aws_lb_target_group" "rds_oracle_target_group" {
  name        = "${var.prefix}-tg-${random_id.env_display_id.hex}"
  port        = 1521
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Name = "${var.prefix}-rds-oracle-target-group-${random_id.env_display_id.hex}"
  }
}

# Target Group Attachment for the RDS instance
resource "aws_lb_target_group_attachment" "oracle_xstream_db_target_group_attachment" {
  target_group_arn = aws_lb_target_group.rds_oracle_target_group.arn
  target_id        = aws_instance.oracle_instance.private_ip
  port             = 1521
}
