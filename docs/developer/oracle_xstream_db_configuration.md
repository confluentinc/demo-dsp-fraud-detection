



# Use for Oracle Connector V2 (XStream)

## Example SQL commands to connect to DB

## Example SQL commands to configure the database
    #   "sqlplus ${var.oracle_db_username}/${var.oracle_db_password}@XE <<EOF",
    #   "CREATE PLUGGABLE DATABASE my_pdb ADMIN USER ${var.oracle_db_username} IDENTIFIED BY pasword FILE_NAME_CONVERT=('/var/oracle/data/', '/var/oracle/data/${var.oracle_db_name}/');",
    #   "CALTER SYSTEM SET enable_goldengate_replication=TRUE SCOPE=BOTH;",
    #   "SELECT LOG_MODE FROM V$DATABASE;",
    #   "SHUTDOWN IMMEDIATE;",
    #   "STARTUP MOUNT;",
    #   "ALTER DATABASE ARCHIVELOG;",
    #   "ALTER DATABASE OPEN;",
    #   "SELECT LOG_MODE FROM V$DATABASE;",
    #   "ALTER SESSION SET CONTAINER = CDB$ROOT;",
    #   "ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;",
    #   "SELECT SUPPLEMENTAL_LOG_DATA_MIN, SUPPLEMENTAL_LOG_DATA_ALL FROM V$DATABASE;",
    #   "CREATE TABLESPACE xstream_adm_tbs DATAFILE '/opt/oracle/oradata/${var.oracle_db_name}/xstream_adm_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;",
    #   "CREATE USER c##cfltadmin IDENTIFIED BY password DEFAULT TABLESPACE xstream_adm_tbs QUOTA UNLIMITED ON xstream_adm_tbs CONTAINER=ALL;",
    #   "GRANT CREATE SESSION, SET CONTAINER TO c##cfltadmin CONTAINER=ALL;",
    #   "BEGIN",
    #     "DBMS_XSTREAM_AUTH.GRANT_ADMIN_PRIVILEGE(",
    #     "grantee                 => 'c##cfltadmin',",
    #     "privilege_type          => 'CAPTURE',",
    #     "grant_select_privileges => TRUE,",
    #     "container               => 'ALL');",
    #   "END;",
    #
    #   "CREATE TABLESPACE xstream_tbs DATAFILE '/opt/oracle/oradata/${var.oracle_db_name}/xstream_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;",
    #
    #   "CREATE USER c##cfltuser IDENTIFIED BY password",
    #   "DEFAULT TABLESPACE xstream_tbs",
    #   "QUOTA UNLIMITED ON xstream_tbs",
    #   "CONTAINER=ALL;",
    #
    #   "GRANT CREATE SESSION, SET CONTAINER TO c##cfltuser CONTAINER=ALL;",
    #   "GRANT SELECT_CATALOG_ROLE TO c##cfltuser CONTAINER=ALL;",
    #   "GRANT FLASHBACK ANY TABLE TO c##cfltuser CONTAINER=ALL;",
    #   "GRANT SELECT ANY TABLE TO c##cfltuser CONTAINER=ALL;",
    #   "GRANT LOCK ANY TABLE TO c##cfltuser CONTAINER=ALL;",
    #
    #   "DECLARE",
    #     "tables  DBMS_UTILITY.UNCL_ARRAY;",
    #     "schemas DBMS_UTILITY.UNCL_ARRAY;",
    #   "BEGIN",
    #     "tables(1)  := 'sample.employees';",
    #     "schemas(1) := NULL;",
    #    "DBMS_XSTREAM_ADM.CREATE_OUTBOUND(",
    #     "server_name           =>  'xout',",
    #     "source_container_name =>  '${var.oracle_db_name}',",
    #     "table_names           =>  tables,",
    #     "schema_names          =>  schemas);",
    #   "END;",
    #
    #   "BEGIN",
    #     "DBMS_XSTREAM_ADM.ALTER_OUTBOUND(",
    #     "server_name  => 'xout',",
    #     "connect_user => 'c##cfltuser');",
    #   "END;",
    #
    #   "BEGIN",
	#     "DBMS_CAPTURE_ADM.ALTER_CAPTURE(",
    #       "capture_name => 'CAP$_XOUT_624',",
	#       "checkpoint_retention_time => 7",
	#     ");",
    #   "END;",
    #
    #   "SELECT CAPTURE_NAME FROM ALL_XSTREAM_OUTBOUND WHERE SERVER_NAME = 'XOUT';",
    #
    #   "EXIT;",
    #   "EOF"
