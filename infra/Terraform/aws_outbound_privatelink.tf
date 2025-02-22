# ------------------------------------------------------
# VPC Endpoint
# ------------------------------------------------------
resource "aws_vpc_endpoint" "privatelink" {
  vpc_id            = aws_vpc.main.id
  service_name      = confluent_private_link_attachment.pla.aws[0].vpc_endpoint_service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg.id,
  ]

  subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id]

  private_dns_enabled = false

  tags = {
    Name = "${var.prefix}-confluent-private-link-endpoint-${random_id.env_display_id.hex}"
  }
}

# ------------------------------------------------------
# VPC Endpoint
# ------------------------------------------------------
resource "aws_route53_zone" "privatelink" {
  name = confluent_private_link_attachment.pla.dns_domain

  vpc {
    vpc_id = aws_vpc.main.id
  }
}


resource "aws_route53_record" "privatelink" {
  zone_id = aws_route53_zone.privatelink.zone_id
  name = "*.${aws_route53_zone.privatelink.name}"
  type = "CNAME"
  ttl  = "60"
  records = [
    aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"]
  ]
}
