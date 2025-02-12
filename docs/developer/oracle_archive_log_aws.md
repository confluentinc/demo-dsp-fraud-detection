 - Database Setup on AWS managed Oracle RDS for Confluent Cloud Connector


1.  Enable Automated backups
   2. Done with Terraform (backup_retention_period)

2. Ran supplemental logging

As Admin User Log into Database and complete the following

```oracle
begin
    rdsadmin.rdsadmin_util.alter_supplemental_logging(
        p_action => 'ADD',
        p_type   => 'ALL');
end;
```

3. Grant SELECT privileges for specified tables to the user specified in the Oracle Confluent Connector

**NOTE:** the username will be in all capitals, ie `username` -> `USERNAME`

```oracle
GRANT SELECT ON THEBESTUSERNAME.AUTH_USER TO THEBESTUSERNAME;
GRANT SELECT ON THEBESTUSERNAME.FRAUD_TRANSACTION TO THEBESTUSERNAME;
```

4. Grant SELECT privileges for other required internal tables to the user specified in the Oracle Confluent Connector 

```oracle
BEGIN
	rdsadmin.rdsadmin_util.grant_sys_object('V_$DATABASE', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$INSTANCE', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$THREAD', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$PARAMETER', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$NLS_PARAMETERS', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$TIMEZONE_NAMES', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$TRANSACTION', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$LOG', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGFILE', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_LOGS', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$LOGMNR_CONTENTS','THEBESTUSERNAME','SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$ARCHIVED_LOG', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('V_$ARCHIVE_DEST_STATUS', 'THEBESTUSERNAME', 'SELECT');
	rdsadmin.rdsadmin_util.grant_sys_object('DBMS_LOGMNR', 'THEBESTUSERNAME', 'EXECUTE');
	rdsadmin.rdsadmin_util.alter_supplemental_logging(p_action => 'ADD');
END;
```







