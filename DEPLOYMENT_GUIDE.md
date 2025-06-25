# HF Oracle Batch - Deployment Guide

## 📋 Overview

This guide provides detailed instructions for deploying the HF Oracle Batch system in your Oracle database environment.

## 🎯 Prerequisites

### Database Requirements
- **Oracle Database**: 12c or higher (19c recommended)
- **Character Set**: AL32UTF8 recommended
- **National Character Set**: AL16UTF16 recommended
- **Block Size**: 8KB or higher

### User Privileges
The deployment user must have the following privileges:
```sql
-- System privileges
CREATE SESSION
CREATE TABLE
CREATE VIEW
CREATE SEQUENCE
CREATE PROCEDURE
CREATE TRIGGER
CREATE ROLE
CREATE ANY DIRECTORY (if using file operations)

-- Object privileges
SELECT ANY DICTIONARY
SELECT ANY TABLE
INSERT ANY TABLE
UPDATE ANY TABLE
DELETE ANY TABLE
```

### Tablespace Requirements
Ensure sufficient space in the following tablespaces:
- **SYSTEM**: For system objects
- **SYSAUX**: For monitoring data
- **USERS**: For application data (default)
- **TEMP**: For temporary operations

Estimated space requirements:
- **Tables**: ~50MB initial
- **Indexes**: ~30MB initial
- **Logs**: Variable (depends on usage)

## 🚀 Deployment Steps

### Step 1: Environment Preparation

1. **Connect to Oracle Database**
   ```sql
   CONNECT username/password@database
   ```

2. **Verify Database Version**
   ```sql
   SELECT version, version_full FROM v$instance;
   ```

3. **Check Available Tablespace Space**
   ```sql
   SELECT tablespace_name, bytes/1024/1024 MB 
   FROM dba_data_files 
   WHERE tablespace_name IN ('SYSTEM', 'SYSAUX', 'USERS');
   ```

### Step 2: Execute Master Script

1. **Navigate to Project Directory**
   ```bash
   cd /path/to/batch-man
   ```

2. **Execute Master Script**
   ```sql
   @00_MASTER_SCRIPT.sql
   ```

3. **Monitor Execution**
   - The script will display progress messages
   - Check for any error messages
   - Verify completion message

### Step 3: Post-Deployment Verification

1. **Verify Tables Creation**
   ```sql
   SELECT table_name, status 
   FROM user_tables 
   WHERE table_name LIKE 'BATCH_%' 
   ORDER BY table_name;
   ```

2. **Verify Packages Creation**
   ```sql
   SELECT object_name, object_type, status 
   FROM user_objects 
   WHERE object_name LIKE 'PCK_BATCH_%' 
   ORDER BY object_name;
   ```

3. **Verify Views Creation**
   ```sql
   SELECT view_name, status 
   FROM user_views 
   WHERE view_name LIKE 'V_BATCH_%' 
   ORDER BY view_name;
   ```

4. **Verify Sequences Creation**
   ```sql
   SELECT sequence_name, min_value, max_value, increment_by 
   FROM user_sequences;
   ```

## ⚙️ Configuration

### Step 4: Initial Setup

1. **Create Company Configuration**
   ```sql
   INSERT INTO BATCH_COMPANIES (ID, NAME, CODE, FISCAL_ID, STATE)
   VALUES (1, 'Your Company Name', 'COMP001', '12345678-9', 'ACTIVE');
   ```

2. **Set Company Parameters**
   ```sql
   INSERT INTO BATCH_COMPANY_PARAMETERS (ID, COMPANY_ID, PARAM_KEY, PARAM_VALUE, PARAM_TYPE)
   VALUES (1, 1, 'DEFAULT_OUTPUT_DIR', '/data/batch/output', 'STRING');
   ```

3. **Create Initial Chain**
   ```sql
   EXEC PCK_BATCH_MANAGER.CREATE_CHAIN('SAMPLE_CHAIN', 'Sample processing chain');
   ```

## 🔧 Troubleshooting

### Common Issues

1. **ORA-00955: name is already being used**
   - Drop existing objects: `DROP TABLE table_name CASCADE;`
   - Or use different schema

2. **ORA-01031: insufficient privileges**
   - Grant required privileges to user
   - Check role assignments

3. **ORA-00942: table or view does not exist**
   - Verify script execution order
   - Check for missing dependencies

4. **ORA-02291: integrity constraint violated**
   - Verify foreign key relationships
   - Check data consistency

### Verification Queries

```sql
-- Check for invalid objects
SELECT object_name, object_type, status 
FROM user_objects 
WHERE status != 'VALID';

-- Check for missing constraints
SELECT table_name, constraint_name, constraint_type 
FROM user_constraints 
WHERE table_name LIKE 'BATCH_%';

-- Check for missing indexes
SELECT table_name, index_name, uniqueness 
FROM user_indexes 
WHERE table_name LIKE 'BATCH_%';
```

## 📊 Performance Considerations

### Initial Configuration

1. **Set Appropriate Initial Extents**
   ```sql
   ALTER TABLE BATCH_SIMPLE_LOG STORAGE (INITIAL 10M NEXT 5M);
   ```

2. **Configure Logging Levels**
   ```sql
   UPDATE BATCH_COMPANY_PARAMETERS 
   SET PARAM_VALUE = 'INFO' 
   WHERE PARAM_KEY = 'LOG_LEVEL';
   ```

3. **Set Retention Policies**
   ```sql
   UPDATE BATCH_COMPANY_PARAMETERS 
   SET PARAM_VALUE = '30' 
   WHERE PARAM_KEY = 'LOG_RETENTION_DAYS';
   ```

### Monitoring Setup

1. **Create Monitoring Views Access**
   ```sql
   GRANT SELECT ON V_BATCH_RUNNING_CHAINS TO monitoring_user;
   GRANT SELECT ON V_BATCH_RUNNING_PROCESSES TO monitoring_user;
   ```

2. **Set Up Alerts**
   ```sql
   -- Example: Alert for failed executions
   INSERT INTO BATCH_COMPANY_PARAMETERS (COMPANY_ID, PARAM_KEY, PARAM_VALUE)
   VALUES (1, 'ALERT_FAILED_EXECUTIONS', 'Y');
   ```

## 🔒 Security Considerations

1. **Role-Based Access Control**
   ```sql
   -- Create application roles
   CREATE ROLE BATCH_OPERATOR;
   CREATE ROLE BATCH_ADMIN;
   
   -- Grant appropriate privileges
   GRANT SELECT ON V_BATCH_* TO BATCH_OPERATOR;
   GRANT ALL ON BATCH_* TO BATCH_ADMIN;
   ```

2. **Audit Configuration**
   ```sql
   -- Enable auditing for critical tables
   AUDIT INSERT, UPDATE, DELETE ON BATCH_COMPANIES;
   AUDIT INSERT, UPDATE, DELETE ON BATCH_CHAINS;
   ```

3. **Encryption for Sensitive Data**
   ```sql
   -- Configure encryption for company parameters
   UPDATE BATCH_COMPANY_PARAMETERS 
   SET IS_ENCRYPTED = 'Y' 
   WHERE PARAM_KEY LIKE '%PASSWORD%';
   ```

## 📈 Post-Deployment Testing

### Basic Functionality Test

1. **Test Chain Creation**
   ```sql
   DECLARE
     v_chain_id NUMBER;
   BEGIN
     v_chain_id := PCK_BATCH_MANAGER.CREATE_CHAIN('TEST_CHAIN', 'Test chain');
     DBMS_OUTPUT.PUT_LINE('Chain created with ID: ' || v_chain_id);
   END;
   /
   ```

2. **Test Process Creation**
   ```sql
   EXEC PCK_BATCH_MANAGER.ADD_PROCESS_TO_CHAIN('TEST_CHAIN', 'TEST_PROCESS', 'Test process');
   ```

3. **Test Execution**
   ```sql
   DECLARE
     v_exec_id NUMBER;
   BEGIN
     v_exec_id := PCK_BATCH_MANAGER.START_CHAIN_EXECUTION('TEST_CHAIN', 1);
     DBMS_OUTPUT.PUT_LINE('Execution started with ID: ' || v_exec_id);
   END;
   /
   ```

### Monitoring Test

```sql
-- Check running chains
SELECT * FROM V_BATCH_RUNNING_CHAINS;

-- Check recent executions
SELECT * FROM V_BATCH_CHAIN_EXECUTIONS 
WHERE start_time > SYSDATE - 1;

-- Check log entries
SELECT * FROM V_BATCH_SIMPLE_LOG 
WHERE timestamp > SYSDATE - 1;
```

## 📞 Support

For deployment issues or questions:

- **Documentation**: See `README.md` and `SYSTEM_ARCHITECTURE.md`
- **Issues**: Create an issue in the project repository
- **Contact**: Eduardo Gutiérrez Tapia (edogt@hotmail.com)

## 📝 Version History

- **v1.0**: Initial deployment guide
- **v1.1**: Added troubleshooting section
- **v1.2**: Added security considerations
- **v1.3**: Added performance optimization tips 