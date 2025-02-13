output "resource-ids" {
  value = <<-EOT




EOT

  sensitive = true
}
# Environment ID:   ${confluent_environment.staging.id}
# Kafka Cluster ID: ${confluent_kafka_cluster.cluster.id}
#
# Service Accounts and their Kafka API Keys (API Keys inherit the permissions granted to the owner):
# ${confluent_service_account.app-manager.display_name}:                     ${confluent_service_account.app-manager.id}
#
# Oracle Database created for use in Private Link Demo for Fully Managed Oracle DB Connector:
# DOMAIN_FQDN: ${aws_db_instance.oracle_db.domain_fqdn}
# ADDRESS: ${aws_db_instance.oracle_db.address}
# DOMAIN: ${aws_db_instance.oracle_db.domain}
# RDS


# Confluent Gateway Account ID: ${confluent_gateway.confluent_rds_gateway.aws_egress_private_link_gateway[0].principal_arn}
