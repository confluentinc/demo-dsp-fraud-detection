# resource "confluent_connector" "sink" {
#   environment {
#     id = confluent_environment.staging.id
#   }
#   kafka_cluster {
#     id = confluent_kafka_cluster.cluster.id
#   }
#
#   // Block for custom *sensitive* configuration properties that are labelled with "Type: password" under "Configuration Properties" section in the docs:
#   // https://docs.confluent.io/cloud/current/connectors/cc-s3-sink.html#configuration-properties
#   config_sensitive = {
#     "kafka.api.secret": "****************************************************************",
#     "database.password" : "${var.oracle_db_password}",
#     "aws.secret.access.key" = "***REDACTED***"
#   }
#
#   // Block for custom *nonsensitive* configuration properties that are *not* labelled with "Type: password" under "Configuration Properties" section in the docs:
#   // https://docs.confluent.io/cloud/current/connectors/cc-s3-sink.html#configuration-properties
#   config_nonsensitive = {
#     "connector.class" : "OracleXStreamSource",
#     "name" : "${var.prefix}-oracle-xstream-connector",
#     "kafka.auth.mode" : "KAFKA_API_KEY",
#     "kafka.api.key" : "ENYGJS7MLLKWKTST",
#     "schema.context.name" : "default",
#
#     "database.hostname" : "${aws_db_instance.oracle_db.address}",
#     "database.port" : "${aws_db_instance.oracle_db.port}",
#     "database.user" : "${var.oracle_db_username}",
#     "database.dbname" : "${var.oracle_db_name}",
#
#     "database.out.server.name" : "xstream",
#     "output.data.key.format" : "JSON",
#     "output.data.value.format" : "JSON",
#     "topic.prefix" : "${var.prefix}",
#     "snapshot.mode" : "initial",
#     "schema.history.internal.skip.unparseable.ddl" : "false",
#     "snapshot.database.errors.max.retries" : "0",
#     "tombstones.on.delete" : "true",
#     "schema.name.adjustment.mode" : "none",
#     "field.name.adjustment.mode" : "none",
#     "heartbeat.interval.ms" : "0",
#     "database.os.timezone" : "UTC",
#     "decimal.handling.mode" : "precise",
#     "time.precision.mode" : "adaptive",
#     "tasks.max" : "1"
#   }
#
#   # depends_on = [
#   #   confluent_kafka_acl.app-connector-describe-on-cluster,
#   #   confluent_kafka_acl.app-connector-read-on-target-topic,
#   #   confluent_kafka_acl.app-connector-create-on-dlq-lcc-topics,
#   #   confluent_kafka_acl.app-connector-write-on-dlq-lcc-topics,
#   #   confluent_kafka_acl.app-connector-create-on-success-lcc-topics,
#   #   confluent_kafka_acl.app-connector-write-on-success-lcc-topics,
#   #   confluent_kafka_acl.app-connector-create-on-error-lcc-topics,
#   #   confluent_kafka_acl.app-connector-write-on-error-lcc-topics,
#   #   confluent_kafka_acl.app-connector-read-on-connect-lcc-group,
#   # ]
#
#   lifecycle {
#     prevent_destroy = true
#   }
# }
