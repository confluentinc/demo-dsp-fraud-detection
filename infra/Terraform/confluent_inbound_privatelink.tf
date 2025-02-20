resource "confluent_private_link_attachment" "pla" {
  cloud = "AWS"
  region = var.region
  display_name = "${var.prefix}-staging-aws-platt-${random_id.env_display_id.hex}"
  environment {
    id = confluent_environment.staging.id
  }
}

resource "confluent_private_link_attachment_connection" "plac" {
  display_name = "${var.prefix}-staging-aws-plattc-${random_id.env_display_id.hex}"
  environment {
    id = confluent_environment.staging.id
  }
  aws {
    vpc_endpoint_id = aws_vpc_endpoint.privatelink.id
  }

  private_link_attachment {
    id = confluent_private_link_attachment.pla.id
  }
}
