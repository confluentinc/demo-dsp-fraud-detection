

UPDATE THE NAME OF:

- Environment NAME -- frauddetectiondemo-environment-a73b48f1
- Cluster Name -- frauddetectiondemo-cluster-a73b48f1
- Topic Name -- <prefix_set_in_connector>.FRAUD_TRANSACTION (this is a reference to the table name)

- TEST USER_TRANSACTION TABLE
```sql
SELECT * FROM `fd.USER_TRANSACTION`
```

- TEST AUTH_USER TABLE
```sql
SELECT * FROM `fd.AUTH_USER`
```

- Update WaterMark
```sql
ALTER TABLE `frauddetectiondemo-environment-a73b48f1`.`frauddetectiondemo-cluster-a73b48f1`.`fd.USER_TRANSACTION` 
    MODIFY WATERMARK FOR `RECEIVED_AT` AS `RECEIVED_AT`;

```

- FLAGGED_TRANSACTION TABLE SETUP
```sql
SET 'client.statement-name' = 'flagged-transaction-materializer';
CREATE TABLE flagged_transaction(
  ID STRING, 
  AMOUNT DOUBLE,
  RECEIVED_AT TIMESTAMP_LTZ(3),
  IP_ADDRESS STRING,
  ACCOUNT_ID BIGINT,
  DETECTED_AT TIMESTAMP_LTZ(3),
  TIME_TO_DETECT_MILLISECONDS BIGINT
) AS 
SELECT ID, AMOUNT, RECEIVED_AT, IP_ADDRESS, ACCOUNT_ID, CURRENT_TIMESTAMP AS DETECTED_AT, TIMESTAMPDIFF(NANOSECOND, RECEIVED_AT, CURRENT_TIMESTAMP)/100000 AS TIME_TO_DETECT_MILLISECONDS
FROM `frauddetectiondemo-environment-a73b48f1`.`frauddetectiondemo-cluster-a73b48f1`.`gko1.FRAUD_TRANSACTION` t
WHERE IP_ADDRESS NOT IN (
            '8.8.8.8',
            '8.8.4.4',
            '34.192.0.0',
            '34.201.0.0',
            '35.160.0.0',
            '35.167.0.0',
            '52.0.0.0',
            '52.25.0.0',
            '64.233.160.0',
            '66.102.0.0',
            '104.16.0.0',
            '172.217.0.0',
            '13.52.0.0',
            '13.57.0.0',
            '23.0.0.0',
            '199.36.153.8',
            '45.56.0.1',
            '192.0.2.0',
            '198.51.100.0',
            '203.0.113.0'
        );
```

- TEST FLAGGED_TRANSACTION TABLE

```sql
SELECT * FROM `flagged_transaction`
```

- FLAGGED USER TABLE SETUP
```sql

SET 'client.statement-name' = 'flagged-user-materializer';
CREATE TABLE flagged_user (
  ACCOUNT_ID BIGINT, 
  user_name STRING,
  email STRING,
  total_amount DOUBLE,
  transaction_count BIGINT,
  updated_at TIMESTAMP_LTZ(3),
  PRIMARY KEY (ACCOUNT_ID) NOT ENFORCED
)
AS 
WITH transactions_per_customer_10m AS 
(
  SELECT 
    ACCOUNT_ID,
    SUM(AMOUNT) OVER w AS total_amount,
    COUNT(*) OVER w AS transaction_count,
    RECEIVED_AT AS transaction_time
  FROM `gko1.FRAUD_TRANSACTION`
  WINDOW w AS (
    PARTITION BY ACCOUNT_ID
    ORDER BY RECEIVED_AT
    RANGE BETWEEN INTERVAL '10' MINUTE PRECEDING AND CURRENT ROW
  )
) 
SELECT 
  COALESCE(ACCOUNT_ID, 0) AS ACCOUNT_ID,
  u.USERNAME AS user_name,
  u.EMAIL AS email,
  transanactions.total_amount,
  transanactions.transaction_count,
  transanactions.transaction_time AS updated_at
FROM 
  transactions_per_customer_10m AS transanactions
JOIN `gko1.AUTH_USER` AS u 
  ON transanactions.ACCOUNT_ID = u.`key`
WHERE 
  transanactions.total_amount > 1000 OR transanactions.transaction_count > 10;

```

- TEST FLAGGED_USER TABLE CREATED
```sql
SELECT * FROM `flagged_user`
```