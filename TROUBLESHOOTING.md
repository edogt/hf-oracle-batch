# HF Oracle Batch - Troubleshooting Guide

## 🔍 Quick Diagnostics

### System Health Check

```sql
-- Check if all objects are valid
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_name LIKE 'BATCH_%' OR object_name LIKE 'PCK_BATCH_%'
ORDER BY object_type, object_name;

-- Check for invalid objects
SELECT object_name, object_type, status 
FROM user_objects 
WHERE status != 'VALID' 
AND (object_name LIKE 'BATCH_%' OR object_name LIKE 'PCK_BATCH_%');
```

### Basic Connectivity Test

```sql
-- Test basic package access
DECLARE
    v_id NUMBER;
BEGIN
    v_id := pck_batch_tools.get_new_id();
    DBMS_OUTPUT.PUT_LINE('System is working. New ID: ' || v_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
```

## 🚨 Common Issues and Solutions

### Installation Issues

#### Issue: ORA-00955: name is already being used
**Symptoms**: Error during table creation
**Cause**: Objects already exist in the database
**Solution**:
```sql
-- Drop existing objects (use with caution)
DROP TABLE BATCH_COMPANIES CASCADE;
DROP TABLE BATCH_CHAINS CASCADE;
-- ... repeat for all tables

-- Or use different schema
ALTER SESSION SET CURRENT_SCHEMA = NEW_SCHEMA;
```

#### Issue: ORA-01031: insufficient privileges
**Symptoms**: Permission denied errors
**Cause**: User lacks required privileges
**Solution**:
```sql
-- Grant required privileges
GRANT CREATE TABLE TO your_user;
GRANT CREATE SEQUENCE TO your_user;
GRANT CREATE PROCEDURE TO your_user;
GRANT CREATE VIEW TO your_user;
GRANT CREATE ROLE TO your_user;
```

#### Issue: ORA-00942: table or view does not exist
**Symptoms**: References to non-existent objects
**Cause**: Missing dependencies or incorrect execution order
**Solution**:
1. Verify script execution order
2. Check for missing objects
3. Re-run deployment scripts

### Runtime Issues

#### Issue: Chain Execution Fails
**Symptoms**: Chain starts but fails immediately
**Diagnosis**:
```sql
-- Check chain definition
SELECT * FROM BATCH_CHAINS WHERE code = 'CHAIN_NAME';

-- Check chain processes
SELECT * FROM BATCH_CHAIN_PROCESSES WHERE chain_id = :chain_id;

-- Check recent executions
SELECT * FROM BATCH_CHAIN_EXECUTIONS 
WHERE chain_id = :chain_id 
ORDER BY start_time DESC;
```

**Common Solutions**:
1. **Missing Processes**: Add processes to chain
2. **Invalid Process**: Check process definition
3. **Permission Issues**: Verify user permissions

#### Issue: Process Execution Hangs
**Symptoms**: Process starts but never completes
**Diagnosis**:
```sql
-- Check running processes
SELECT * FROM V_BATCH_RUNNING_PROCESSES;

-- Check process activities
SELECT * FROM BATCH_PROCESS_ACTIVITIES WHERE process_id = :process_id;

-- Check for locks
SELECT * FROM V$LOCK WHERE sid IN (
    SELECT sid FROM V$SESSION WHERE username = 'YOUR_USER'
);
```

**Solutions**:
1. **Activity Hanging**: Check activity implementation
2. **Resource Contention**: Check for locks
3. **Infinite Loop**: Review activity logic

#### Issue: Activity Execution Fails
**Symptoms**: Activity fails with error
**Diagnosis**:
```sql
-- Check activity definition
SELECT * FROM BATCH_ACTIVITIES WHERE code = 'ACTIVITY_NAME';

-- Check activity parameters
SELECT * FROM BATCH_ACTIVITY_PARAMETERS WHERE activity_id = :activity_id;

-- Check recent activity executions
SELECT * FROM BATCH_ACTIVITY_EXECUTIONS 
WHERE activity_id = :activity_id 
ORDER BY start_time DESC;
```

**Common Solutions**:
1. **Invalid Action**: Check procedure exists and is accessible
2. **Parameter Issues**: Verify parameter values
3. **Permission Issues**: Check procedure permissions

### Performance Issues

#### Issue: Slow Chain Execution
**Symptoms**: Chains take too long to complete
**Diagnosis**:
```sql
-- Check execution times
SELECT 
    chain_name,
    start_time,
    end_time,
    pck_batch_tools.enlapsed_time_string(start_time, end_time) as duration
FROM V_BATCH_CHAIN_EXECUTIONS 
WHERE start_time > SYSDATE - 7
ORDER BY start_time DESC;

-- Check process execution times
SELECT 
    process_name,
    start_time,
    end_time,
    pck_batch_tools.enlapsed_time_string(start_time, end_time) as duration
FROM V_BATCH_PROCESS_EXECUTIONS 
WHERE start_time > SYSDATE - 7
ORDER BY start_time DESC;
```

**Solutions**:
1. **Optimize Activities**: Review slow activities
2. **Parallel Execution**: Configure parallel processing
3. **Resource Tuning**: Adjust database parameters

#### Issue: High Memory Usage
**Symptoms**: Database memory consumption increases
**Diagnosis**:
```sql
-- Check session memory usage
SELECT 
    username,
    program,
    machine,
    memory_used,
    memory_max
FROM V$SESSION 
WHERE username = 'YOUR_USER';

-- Check table sizes
SELECT 
    table_name,
    num_rows,
    blocks,
    avg_row_len
FROM USER_TABLES 
WHERE table_name LIKE 'BATCH_%';
```

**Solutions**:
1. **Cleanup Old Data**: Implement data retention policies
2. **Optimize Queries**: Review view definitions
3. **Memory Tuning**: Adjust PGA/SGA parameters

### Logging Issues

#### Issue: No Log Entries
**Symptoms**: Missing log entries for operations
**Diagnosis**:
```sql
-- Check log table
SELECT COUNT(*) FROM BATCH_SIMPLE_LOG;

-- Check recent logs
SELECT * FROM BATCH_SIMPLE_LOG 
WHERE timestamp > SYSDATE - 1 
ORDER BY timestamp DESC;

-- Check log configuration
SELECT * FROM BATCH_COMPANY_PARAMETERS 
WHERE param_key LIKE '%LOG%';
```

**Solutions**:
1. **Enable Logging**: Set log level parameters
2. **Check Permissions**: Verify insert permissions on log table
3. **Review Logging Code**: Check logging procedure calls

#### Issue: Too Many Log Entries
**Symptoms**: Excessive logging affecting performance
**Solutions**:
```sql
-- Adjust log level
UPDATE BATCH_COMPANY_PARAMETERS 
SET param_value = 'ERROR' 
WHERE param_key = 'LOG_LEVEL';

-- Implement log rotation
EXEC pck_batch_utils.cleanup_old_logs(30); -- Keep 30 days
```

### Multi-Tenant Issues

#### Issue: Wrong Company Context
**Symptoms**: Data from wrong company
**Diagnosis**:
```sql
-- Check company configuration
SELECT * FROM BATCH_COMPANIES;

-- Check company parameters
SELECT * FROM BATCH_COMPANY_PARAMETERS 
WHERE company_id = :company_id;

-- Check chain company assignment
SELECT c.name as chain_name, comp.name as company_name
FROM BATCH_CHAINS c
JOIN BATCH_COMPANIES comp ON c.company_id = comp.id;
```

**Solutions**:
1. **Set Company Context**: Ensure correct company_id
2. **Review Company Assignment**: Check chain/process company assignment
3. **Isolate Data**: Verify company isolation

### Permission Issues

#### Issue: Role Not Working
**Symptoms**: User cannot access system despite having role
**Diagnosis**:
```sql
-- Check user roles
SELECT * FROM USER_ROLE_PRIVS;

-- Check object permissions
SELECT * FROM USER_TAB_PRIVS WHERE table_name LIKE 'BATCH_%';
SELECT * FROM USER_PROC_PRIVS WHERE table_name LIKE 'PCK_BATCH_%';

-- Check role permissions
SELECT * FROM ROLE_TAB_PRIVS WHERE role = 'HFOBATCH_USER';
SELECT * FROM ROLE_PROC_PRIVS WHERE role = 'HFOBATCH_USER';
```

**Solutions**:
1. **Grant Role**: `GRANT HFOBATCH_USER TO username;`
2. **Check Role Permissions**: Verify role has required privileges
3. **Refresh Permissions**: Re-run permission grants

## 🔧 Diagnostic Queries

### System Health Check
```sql
-- Overall system status
SELECT 
    'Tables' as object_type,
    COUNT(*) as count
FROM USER_TABLES 
WHERE table_name LIKE 'BATCH_%'
UNION ALL
SELECT 
    'Packages' as object_type,
    COUNT(*) as count
FROM USER_OBJECTS 
WHERE object_type = 'PACKAGE' 
AND object_name LIKE 'PCK_BATCH_%'
UNION ALL
SELECT 
    'Views' as object_type,
    COUNT(*) as count
FROM USER_VIEWS 
WHERE view_name LIKE 'V_BATCH_%';
```

### Execution Status
```sql
-- Current execution status
SELECT 
    'Running Chains' as status_type,
    COUNT(*) as count
FROM V_BATCH_RUNNING_CHAINS
UNION ALL
SELECT 
    'Running Processes' as status_type,
    COUNT(*) as count
FROM V_BATCH_RUNNING_PROCESSES
UNION ALL
SELECT 
    'Running Activities' as status_type,
    COUNT(*) as count
FROM V_BATCH_RUNNING_ACTIVITIES;
```

### Error Analysis
```sql
-- Recent errors
SELECT 
    timestamp,
    text,
    type,
    activity_execution_id,
    process_execution_id,
    chain_execution_id
FROM BATCH_SIMPLE_LOG 
WHERE type = 'ERROR' 
AND timestamp > SYSDATE - 1
ORDER BY timestamp DESC;
```

## 🛠️ Maintenance Procedures

### Regular Maintenance
```sql
-- Cleanup old executions (keep 90 days)
EXEC pck_batch_utils.cleanup_old_executions(90);

-- Cleanup old logs (keep 30 days)
EXEC pck_batch_utils.cleanup_old_logs(30);

-- Analyze tables for better performance
BEGIN
    FOR t IN (SELECT table_name FROM USER_TABLES WHERE table_name LIKE 'BATCH_%') LOOP
        EXECUTE IMMEDIATE 'ANALYZE TABLE ' || t.table_name || ' COMPUTE STATISTICS';
    END LOOP;
END;
/
```

### Performance Monitoring
```sql
-- Create performance baseline
CREATE TABLE BATCH_PERFORMANCE_BASELINE AS
SELECT 
    chain_name,
    AVG(EXTRACT(SECOND FROM (end_time - start_time))) as avg_duration_seconds,
    COUNT(*) as execution_count
FROM V_BATCH_CHAIN_EXECUTIONS 
WHERE start_time > SYSDATE - 30
GROUP BY chain_name;
```

## 📞 Getting Help

### Before Contacting Support

1. **Collect Information**:
   - Error messages and stack traces
   - Execution logs
   - System configuration
   - Steps to reproduce

2. **Check Documentation**:
   - README.md
   - SYSTEM_ARCHITECTURE.md
   - API_DOCUMENTATION.md

3. **Search Issues**:
   - Check existing GitHub issues
   - Search for similar problems

### Contact Information

- **Email**: edogt@hotmail.com
- **GitHub Issues**: Create detailed issue with reproduction steps
- **Response Time**: 48 hours for non-critical issues

### Issue Template

When reporting issues, include:

```markdown
## Issue Description
Brief description of the problem

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Oracle Version: [e.g., 19c]
- HF Oracle Batch Version: [e.g., 1.0.0]
- Operating System: [e.g., Linux]
- Database Size: [e.g., 100GB]

## Error Messages
```
[Paste error messages here]
```

## Additional Information
Any other relevant information
```

---

**Note**: This troubleshooting guide is updated regularly based on common issues and user feedback. 