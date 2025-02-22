# # https://github.com/confluentinc/terraform-provider-confluent/tree/master/examples/configurations/connectors/managed-datagen-source-connector
# resource "confluent_connector" "source" {
#   environment {
#     id = confluent_environment.staging.id
#   }
#   kafka_cluster {
#     id = confluent_kafka_cluster.basic.id
#   }
#
#   config_sensitive = {}
#
#   config_nonsensitive = {
#     "connector.class"          = "DatagenSource"
#     "name"                     = "DatagenSourceConnector_0"
#     "kafka.auth.mode"          = "SERVICE_ACCOUNT"
#     "kafka.service.account.id" = confluent_service_account.app-connector.id
#     "kafka.topic"              = confluent_kafka_topic.orders.topic_name
#     "output.data.format"       = "JSON"
#     "quickstart"               = "ORDERS"
#     "tasks.max"                = "1"
#   }
#
#   depends_on = [
#     confluent_kafka_acl.app-connector-describe-on-cluster,
#     confluent_kafka_acl.app-connector-write-on-target-topic,
#     confluent_kafka_acl.app-connector-create-on-data-preview-topics,
#     confluent_kafka_acl.app-connector-write-on-data-preview-topics,
#   ]
#
#   lifecycle {
#     prevent_destroy = true
#   }
# }


 ## UPDATE ME
# {
#   "config": {
#     "connector.class": "OracleCdcSource",
#     "name": "oraclecdc1",
#     "kafka.auth.mode": "KAFKA_API_KEY",
#     "kafka.api.key": "JI5JIECBIW7TPS66",
#     "kafka.api.secret": "****************************************************************",
#     "schema.context.name": "default",
#     "oracle.server": "terraform-20250127204227733600000007.cy56rbcnrbof.us-west-2.rds.amazonaws.com",
#     "oracle.port": "1521",
#     "oracle.sid": "DEMODB",
#     "oracle.username": "thebestusername",
#     "oracle.password": "********************",
#     "oracle.fan.events.enable": "false",
#     "table.inclusion.regex": "*",
#     "start.from": "snapshot",
#     "oracle.supplemental.log.level": "full",
#     "emit.tombstone.on.delete": "false",
#     "behavior.on.dictionary.mismatch": "fail",
#     "behavior.on.unparsable.statement": "fail",
#     "db.timezone": "UTC",
#     "redo.log.startup.polling.limit.ms": "300000",
#     "heartbeat.interval.ms": "0",
#     "log.mining.end.scn.deviation.ms": "0",
#     "use.transaction.begin.for.mining.session": "false",
#     "log.mining.transaction.age.threshold.ms": "-1",
#     "log.mining.transaction.threshold.breached.action": "warn",
#     "query.timeout.ms": "300000",
#     "max.batch.size": "1000",
#     "poll.linger.ms": "5000",
#     "max.buffer.size": "0",
#     "redo.log.poll.interval.ms": "500",
#     "snapshot.row.fetch.size": "2000",
#     "redo.log.row.fetch.size": "5000",
#     "oracle.validation.result.fetch.size": "5000",
#     "oracle.dictionary.mode": "auto",
#     "output.table.name.field": "table",
#     "output.scn.field": "scn",
#     "output.op.type.field": "op_type",
#     "output.op.ts.field": "op_ts",
#     "output.current.ts.field": "current_ts",
#     "output.row.id.field": "row_id",
#     "output.username.field": "username",
#     "output.op.type.read.value": "R",
#     "output.op.type.insert.value": "I",
#     "output.op.type.update.value": "U",
#     "output.op.type.delete.value": "D",
#     "snapshot.by.table.partitions": "false",
#     "snapshot.threads.per.task": "4",
#     "enable.large.lob.object.support": "false",
#     "numeric.mapping": "none",
#     "numeric.default.scale": "127",
#     "oracle.date.mapping": "timestamp",
#     "output.data.key.format": "JSON_SR",
#     "output.data.value.format": "JSON_SR",
#     "tasks.max": "10"
#   }
# }




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

