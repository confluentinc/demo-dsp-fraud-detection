
# # Service Account for the connector
# resource "confluent_service_account" "oracle-xstream-cdc-sa" {
#   display_name = "oracle-xstream-cdc-sa"
#   description  = "Service account for Oracle Xstream CDC Source Connector"
# }

# # Create API Key for the service account
# resource "confluent_api_key" "oracle-xstream-cdc-api-key" {
#   display_name = "oracle-xstream-cdc-api-key"
#   description  = "API Key for Oracle Xstream CDC Source Connector"
#   owner {
#     id          = confluent_service_account.oracle-xstream-cdc-sa.id
#     api_version = confluent_service_account.oracle-xstream-cdc-sa.api_version
#     kind        = confluent_service_account.oracle-xstream-cdc-sa.kind
#   }

#   managed_resource {
#     id          = confluent_kafka_cluster.cluster.id
#     api_version = "cmk/v2"
#     kind        = "Cluster"
#     environment {
#       id = confluent_environment.staging.id
#     }
#   }
# }

# # Oracle CDC Source Connector
# resource "confluent_connector" "oracle-xstream-cdc-source" {
#   environment {
#     id = confluent_environment.staging.id
#   }
#   kafka_cluster {
#     id = confluent_kafka_cluster.cluster.id
#   }

#   config_sensitive = {
#     "database.user"      = var.oracle_xstream_user_username
#     "database.password"  = var.oracle_xstream_user_password
#     "kafka.api.key"      = confluent_api_key.oracle-xstream-cdc-api-key.id
#     "kafka.api.secret"   = confluent_api_key.oracle-xstream-cdc-api-key.secret
#   }

#   config_nonsensitive = {
#     "connector.class"                                 = "OracleXStreamSource"
#     "name"                                            = "OracleXstreamCdcSourceConnector"
#     "kafka.auth.mode"                                 = "SERVICE_ACCOUNT"
#     "kafka.service.account.id"                        = confluent_service_account.oracle-xstream-cdc-sa.id
#     "schema.context.name"                             = "default"
#     "database.hostname"                               = aws_instance.oracle_instance.private_ip
#     "database.port"                                   = "1521"
#     "database.dbname"                                 = "XE"
#     "database.service.name"                           = "XE"
#     "database.pdb.name"                               = var.oracle_pdb_name
#     "database.out.server.name"                        = "xout"
#     "database.tls.mode"                               = "disable",
#     "database.processor.licenses"                     = "1",
#     "output.key.format"                               = "JSON_SR",
#     "output.data.format"                              = "JSON_SR",
#     "topic.prefix"                                    = "oracle",
#     "table.include.list"                              = var.oracle_db_table_include_list,
#     "snapshot.mode"                                   = "no_data",
#     "schema.history.internal.skip.unparseable.ddl"    = "false",
#     "snapshot.database.errors.max.retries"            = "0",
#     "tombstones.on.delete"                            = "true",
#     "skipped.operations"                              = "t",
#     "schema.name.adjustment.mode"                     = "none",
#     "field.name.adjustment.mode"                      = "none",
#     "heartbeat.interval.ms"                           = "0",
#     "database.os.timezone"                            = "UTC",
#     "decimal.handling.mode"                           = "precise",
#     "time.precision.mode"                             = "adaptive",
#     "tasks.max"                                       = "1",
#     "auto.restart.on.user.error"                      = "true",
#     "value.converter.decimal.format"                  = "BASE64",
#     "value.converter.reference.subject.name.strategy" = "DefaultReferenceSubjectNameStrategy",
#     "value.converter.value.subject.name.strategy"     = "TopicNameStrategy",
#     "key.converter.key.subject.name.strategy"         = "TopicNameStrategy"
#   }

# }

# # Outputs
# output "oracle_xstream_cdc_connector_details" {
#     description = "The ID of the created Oracle Xstream CDC connector"
#     value       = confluent_connector.oracle-xstream-cdc-source.id

# }

# output "oracle_xstream_cdc_connector_status" {
#   description = "The status of the Oracle Xstream CDC connector"
#   value       = confluent_connector.oracle-xstream-cdc-source.status
# }

# output "service_account_id" {
#   description = "The ID of the service account used by the connector"
#   value       = confluent_service_account.oracle-xstream-cdc-sa.id
# }