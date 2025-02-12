1. HostName: host
2. PID: DBNAME
3. UserName & Password
4. Table Query: <DB_NAME>[.]<DB_USERNAME>[.](TABLE_1| TABLE_2) -- `DEMODB[.]THEBESTUSERNAME[.](USER_TRANSACTION|AUTH_USER)`
5. TABLE Name Template: `<your_unique_prefix_here>.${tableName}`
6. OutPut Type For Both: `JSON_SR`
7. Advanced Options: `Map NUMERIC values by precision and scale` is set to `best_fit_or_string`

7. Advanced Settings: 
Example Config:
{
  "config": {
    "connector.class": "OracleCdcSource",
    "name": "OracleCdcSourceConnector_1",
    "kafka.auth.mode": "KAFKA_API_KEY",
    "kafka.api.key": "2Z6ALTIGGTAMF4DJ",
    "kafka.api.secret": "****************************************************************",
    "schema.context.name": "default",
    "oracle.server": "terraform-20250127204227733600000007.cy56rbcnrbof.us-west-2.rds.amazonaws.com",
    "oracle.port": "1521",
    "oracle.sid": "DEMODB",
    "oracle.username": "thebestusername",
    "oracle.password": "********************",
    "oracle.fan.events.enable": "false",
    "table.inclusion.regex": " DEMODB[.]THEBESTUSERNAME[.](USER_TRANSACTION| AUTH_USER)",
    "start.from": "snapshot",
    "oracle.supplemental.log.level": "full",
    "emit.tombstone.on.delete": "false",
    "behavior.on.dictionary.mismatch": "fail",
    "behavior.on.unparsable.statement": "fail",
    "db.timezone": "UTC",
    "redo.log.startup.polling.limit.ms": "300000",
    "heartbeat.interval.ms": "0",
    "log.mining.end.scn.deviation.ms": "0",
    "use.transaction.begin.for.mining.session": "false",
    "log.mining.transaction.age.threshold.ms": "-1",
    "log.mining.transaction.threshold.breached.action": "warn",
    "query.timeout.ms": "300000",
    "max.batch.size": "1000",
    "poll.linger.ms": "5000",
    "max.buffer.size": "0",
    "redo.log.poll.interval.ms": "500",
    "snapshot.row.fetch.size": "2000",
    "redo.log.row.fetch.size": "5000",
    "oracle.validation.result.fetch.size": "5000",
    "table.topic.name.template": "fraud_demo.${tableName}",
    "oracle.dictionary.mode": "auto",
    "output.table.name.field": "table",
    "output.scn.field": "scn",
    "output.op.type.field": "op_type",
    "output.op.ts.field": "op_ts",
    "output.current.ts.field": "current_ts",
    "output.row.id.field": "row_id",
    "output.username.field": "username",
    "output.op.type.read.value": "R",
    "output.op.type.insert.value": "I",
    "output.op.type.update.value": "U",
    "output.op.type.delete.value": "D",
    "snapshot.by.table.partitions": "false",
    "snapshot.threads.per.task": "4",
    "enable.large.lob.object.support": "false",
    "numeric.mapping": "none",
    "numeric.default.scale": "127",
    "oracle.date.mapping": "timestamp",
    "output.data.key.format": "JSON_SR",
    "output.data.value.format": "JSON_SR",
    "tasks.max": "2"
  }
}