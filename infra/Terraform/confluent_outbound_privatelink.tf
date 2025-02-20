resource "confluent_dns_record" "main" {
  display_name = "dns_record"
  environment {
    id = confluent_environment.staging.id
  }
  domain = "${var.region}.rds.amazonaws.com"
  gateway {
    id = confluent_gateway.confluent_rds_gateway.id
  }
  private_link_access_point {
    id = confluent_access_point.confluent_oracle_db_access_point.id
  }
}

resource "confluent_gateway" "confluent_rds_gateway" {
  display_name = "${var.prefix}-gateway-${random_id.env_display_id.hex}"
  environment {
    id = confluent_environment.staging.id
  }
  aws_egress_private_link_gateway {
    region = var.region
  }
}

resource "confluent_access_point" "confluent_oracle_db_access_point" {
  display_name = "oracledb_privatelink_access_point"
  environment {
    id = confluent_environment.staging.id
  }
  gateway {
    id = confluent_gateway.confluent_rds_gateway.id
  }
  aws_egress_private_link_endpoint {
    vpc_endpoint_service_name = aws_vpc_endpoint_service.rds_endpoint_service.service_name
  }
  depends_on = [aws_vpc_endpoint_service_allowed_principal.allow_confluent_rds_gateway]
}





