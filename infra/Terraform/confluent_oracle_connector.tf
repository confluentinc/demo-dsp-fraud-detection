#
# # Service Account for the connector
# resource "confluent_service_account" "oracle-cdc-sa" {
#   display_name = "oracle-cdc-sa"
#   description  = "Service account for Oracle CDC Source Connector"
# }
#
# # Create API Key for the service account
# resource "confluent_api_key" "oracle-cdc-api-key" {
#   display_name = "oracle-cdc-api-key"
#   description  = "API Key for Oracle CDC Source Connector"
#   owner {
#     id          = confluent_service_account.oracle-cdc-sa.id
#     api_version = confluent_service_account.oracle-cdc-sa.api_version
#     kind        = confluent_service_account.oracle-cdc-sa.kind
#   }
#
#   managed_resource {
#     id          = confluent_kafka_cluster.cluster.id
#     api_version = "cmk/v2"
#     kind        = "Cluster"
#     environment {
#       id = confluent_environment.staging.id
#     }
#   }
# }
#
# # Oracle CDC Source Connector
# resource "confluent_connector" "oracle-cdc-source" {
#   environment {
#     id = confluent_environment.staging.id
#   }
#   kafka_cluster {
#     id = confluent_kafka_cluster.cluster.id
#   }
#
#   config_sensitive = {
#     "oracle.username"     = aws_db_instance.oracle_db.username
#     "oracle.password"     = aws_db_instance.oracle_db.password
#     "kafka.api.key"      = confluent_api_key.oracle-cdc-api-key.id
#     "kafka.api.secret"   = confluent_api_key.oracle-cdc-api-key.secret
#   }
#
#   config_nonsensitive = {
#     "connector.class"                = "OracleCdcSource"
#     "name"                          = "OracleCdcSourceConnector"
#     "kafka.auth.mode"               = "SERVICE_ACCOUNT"
#     "kafka.service.account.id"      = confluent_service_account.oracle-cdc-sa.id
#     "oracle.server"                 = aws_db_instance.oracle_db.address
#     "oracle.port"                   = aws_db_instance.oracle_db.port
#     "oracle.pdb"                    = aws_db_instance.oracle_db.db_name
#     "oracle.redo.log.topic.name"    = "oracle.redolog"
#     "oracle.redo.log.consumer.bootstrap.servers" = "${confluent_kafka_cluster.cluster.id}.confluent.cloud:9092"
#     "table.inclusion.regex"         = "${aws_db_instance.oracle_db.db_name}[.]${upper(aws_db_instance.oracle_db.username)}[.](USER_TRANSACTION|AUTH_USER)"
#     "start.from"                    = "LATEST"
#     "topic.creation.default.partitions" = "6"
#     "topic.creation.default.replication.factor" = "3"
#     "topic.creation.redo.log.replication.factor" = "3"
#     "topic.creation.redo.log.partitions" = "6"
#     "topic.creation.redo.log.cleanup.policy" = "delete"
#     "topic.creation.redo.log.retention.ms" = "1209600000" # 14 days
#     "data.format"                   = "JSON"
#     "data.output.format"            = "JSON_SR"
#     "data.output.properties"        = "true"
#     "data.output.key.format"        = "JSON_SR"
#     "oracle.dictionary.mode"        = "AUTO"
#     "oracle.logminer.buffer.size.mb" = "128"
#     "oracle.logminer.batch.size.ms" = "1000"
#     "oracle.redo.log.row.fetch.size" = "1000"
#     "oracle.redo.log.topic.partitioning" = "TRANSACTION"
#     "oracle.multitenant"           = "true"
#     "oracle.supplemental.log.level" = "ALL"
#     "errors.tolerance"             = "ALL"
#     "errors.log.enable"            = "true"
#     "errors.log.include.messages"  = "true"
#     "errors.deadletterqueue.topic.name" = "dlq-oracle-cdc"
#     "errors.deadletterqueue.topic.replication.factor" = "3"
#     "tasks.max"                    = "1"
#   }
# }
#
# # Dead Letter Queue Topic
# resource "confluent_kafka_topic" "dlq_topic" {
#   kafka_cluster {
#     id = var.cluster_id
#   }
#   topic_name         = "dlq-oracle-cdc"
#   partitions_count   = 6
#   rest_endpoint      = var.kafka_rest_endpoint
#   config = {
#     "cleanup.policy"      = "compact"
#     "retention.ms"        = "604800000" # 7 days
#     "retention.bytes"     = "-1"
#   }
#   credentials {
#     key    = confluent_api_key.oracle-cdc-api-key.id
#     secret = confluent_api_key.oracle-cdc-api-key.secret
#   }
# }
#
# # Outputs
# output "oracle_connector_details" {
#   data = {
#
#   }
#   # description = "The ID of the created Oracle CDC connector"
#   # value       = confluent_connector.oracle-cdc-source.id
# }
#
# # output "oracle_cdc_connector_status" {
# #   description = "The status of the Oracle CDC connector"
# #   value       = confluent_connector.oracle-cdc-source.status
# # }
# #
# # output "service_account_id" {
# #   description = "The ID of the service account used by the connector"
# #   value       = confluent_service_account.oracle-cdc-sa.id
# # }
# #
# # output "dead_letter_queue_topic" {
# #   description = "The name of the Dead Letter Queue topic"
# #   value       = confluent_kafka_topic.dlq_topic.topic_name
# # }