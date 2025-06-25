# HF Oracle Batch - API Documentation

## 📋 Overview

This document provides comprehensive API documentation for all PL/SQL packages in the HF Oracle Batch system.

## 🏗️ Package Architecture

### Core Packages
- **PCK_BATCH_MANAGER** - Main orchestration package
- **PCK_BATCH_MGR_CHAINS** - Chain management
- **PCK_BATCH_MGR_PROCESSES** - Process management
- **PCK_BATCH_MGR_ACTIVITIES** - Activity management
- **PCK_BATCH_MGR_LOG** - Logging system
- **PCK_BATCH_MGR_REPORT** - Reporting system
- **PCK_BATCH_COMPANIES** - Company management
- **PCK_BATCH_CHECK** - Validation utilities
- **PCK_BATCH_DSI** - Data source interface

### Monitoring & Utilities
- **PCK_BATCH_MONITOR** - Real-time monitoring
- **PCK_BATCH_TOOLS** - Utility functions
- **PCK_BATCH_UTILS** - Helper utilities

## 📦 Package Documentation

### PCK_BATCH_MANAGER

Main orchestration package for batch processing.

#### Key Functions

##### `CREATE_CHAIN`
```sql
FUNCTION create_chain(
    p_chain_name IN VARCHAR2,
    p_description IN VARCHAR2 DEFAULT NULL,
    p_company_id IN NUMBER DEFAULT NULL
) RETURN NUMBER;
```
**Purpose**: Creates a new batch chain
**Parameters**:
- `p_chain_name`: Unique name for the chain
- `p_description`: Optional description
- `p_company_id`: Company ID (for multi-tenant)
**Returns**: Chain ID
**Example**:
```sql
DECLARE
    v_chain_id NUMBER;
BEGIN
    v_chain_id := pck_batch_manager.create_chain(
        p_chain_name => 'ETL_PROCESSING',
        p_description => 'Extract, Transform, Load workflow',
        p_company_id => 1
    );
    DBMS_OUTPUT.PUT_LINE('Chain created with ID: ' || v_chain_id);
END;
/
```

##### `START_CHAIN_EXECUTION`
```sql
FUNCTION start_chain_execution(
    p_chain_name IN VARCHAR2,
    p_company_id IN NUMBER,
    p_execution_type IN VARCHAR2 DEFAULT 'MANUAL'
) RETURN NUMBER;
```
**Purpose**: Starts execution of a batch chain
**Parameters**:
- `p_chain_name`: Name of the chain to execute
- `p_company_id`: Company context
- `p_execution_type`: Type of execution (MANUAL, SCHEDULED, etc.)
**Returns**: Execution ID
**Example**:
```sql
DECLARE
    v_exec_id NUMBER;
BEGIN
    v_exec_id := pck_batch_manager.start_chain_execution(
        p_chain_name => 'ETL_PROCESSING',
        p_company_id => 1,
        p_execution_type => 'MANUAL'
    );
    DBMS_OUTPUT.PUT_LINE('Execution started with ID: ' || v_exec_id);
END;
/
```

#### Key Procedures

##### `ADD_PROCESS_TO_CHAIN`
```sql
PROCEDURE add_process_to_chain(
    p_chain_name IN VARCHAR2,
    p_process_name IN VARCHAR2,
    p_description IN VARCHAR2 DEFAULT NULL,
    p_order_number IN NUMBER DEFAULT NULL
);
```
**Purpose**: Adds a process to a chain
**Example**:
```sql
BEGIN
    pck_batch_manager.add_process_to_chain(
        p_chain_name => 'ETL_PROCESSING',
        p_process_name => 'EXTRACT_DATA',
        p_description => 'Extract data from source systems',
        p_order_number => 1
    );
END;
/
```

### PCK_BATCH_MGR_CHAINS

Chain management and orchestration.

#### Key Functions

##### `GET_CHAIN_BY_CODE`
```sql
FUNCTION get_chain_by_code(
    p_chain_code IN VARCHAR2,
    p_company_id IN NUMBER DEFAULT NULL
) RETURN BATCH_CHAINS%ROWTYPE;
```
**Purpose**: Retrieves chain information by code
**Returns**: Chain record

##### `GET_CHAIN_PROCESSES`
```sql
FUNCTION get_chain_processes(
    p_chain_id IN NUMBER
) RETURN SYS_REFCURSOR;
```
**Purpose**: Gets all processes in a chain
**Returns**: Cursor with process information

### PCK_BATCH_MGR_PROCESSES

Process management and execution.

#### Key Functions

##### `CREATE_PROCESS`
```sql
FUNCTION create_process(
    p_process_name IN VARCHAR2,
    p_description IN VARCHAR2 DEFAULT NULL,
    p_company_id IN NUMBER DEFAULT NULL
) RETURN NUMBER;
```
**Purpose**: Creates a new process
**Returns**: Process ID

##### `ADD_ACTIVITY_TO_PROCESS`
```sql
PROCEDURE add_activity_to_process(
    p_process_name IN VARCHAR2,
    p_activity_name IN VARCHAR2,
    p_order_number IN NUMBER DEFAULT NULL
);
```
**Purpose**: Adds an activity to a process

### PCK_BATCH_MGR_ACTIVITIES

Activity management and execution.

#### Key Functions

##### `CREATE_ACTIVITY`
```sql
FUNCTION create_activity(
    p_activity_name IN VARCHAR2,
    p_action IN VARCHAR2,
    p_description IN VARCHAR2 DEFAULT NULL,
    p_company_id IN NUMBER DEFAULT NULL
) RETURN NUMBER;
```
**Purpose**: Creates a new activity
**Parameters**:
- `p_action`: PL/SQL procedure call (e.g., 'MY_PACKAGE.MY_PROCEDURE')

##### `EXECUTE_ACTIVITY`
```sql
PROCEDURE execute_activity(
    p_activity_id IN NUMBER,
    p_parameters IN VARCHAR2 DEFAULT NULL
);
```
**Purpose**: Executes a specific activity

### PCK_BATCH_MGR_LOG

Logging and audit trail management.

#### Key Procedures

##### `LOG_INFO`
```sql
PROCEDURE log_info(
    p_message IN VARCHAR2,
    p_source IN VARCHAR2 DEFAULT NULL,
    p_source_id IN NUMBER DEFAULT NULL
);
```
**Purpose**: Logs informational messages

##### `LOG_ERROR`
```sql
PROCEDURE log_error(
    p_message IN VARCHAR2,
    p_source IN VARCHAR2 DEFAULT NULL,
    p_source_id IN NUMBER DEFAULT NULL
);
```
**Purpose**: Logs error messages

##### `LOG_DEBUG`
```sql
PROCEDURE log_debug(
    p_message IN VARCHAR2,
    p_source IN VARCHAR2 DEFAULT NULL,
    p_source_id IN NUMBER DEFAULT NULL
);
```
**Purpose**: Logs debug messages

### PCK_BATCH_MGR_REPORT

Reporting and analytics.

#### Key Functions

##### `GET_EXECUTION_SUMMARY`
```sql
FUNCTION get_execution_summary(
    p_chain_name IN VARCHAR2,
    p_date_from IN DATE,
    p_date_to IN DATE
) RETURN SYS_REFCURSOR;
```
**Purpose**: Gets execution summary for a chain
**Returns**: Cursor with summary data

##### `GET_PERFORMANCE_METRICS`
```sql
FUNCTION get_performance_metrics(
    p_chain_id IN NUMBER,
    p_days_back IN NUMBER DEFAULT 30
) RETURN SYS_REFCURSOR;
```
**Purpose**: Gets performance metrics for a chain

### PCK_BATCH_COMPANIES

Company and multi-tenant management.

#### Key Functions

##### `CREATE_COMPANY`
```sql
FUNCTION create_company(
    p_company_name IN VARCHAR2,
    p_company_code IN VARCHAR2,
    p_fiscal_id IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER;
```
**Purpose**: Creates a new company
**Returns**: Company ID

##### `SET_COMPANY_PARAMETER`
```sql
PROCEDURE set_company_parameter(
    p_company_id IN NUMBER,
    p_param_key IN VARCHAR2,
    p_param_value IN VARCHAR2,
    p_param_type IN VARCHAR2 DEFAULT 'STRING'
);
```
**Purpose**: Sets a company-specific parameter

### PCK_BATCH_MONITOR

Real-time monitoring and status checking.

#### Key Functions

##### `GET_RUNNING_CHAINS`
```sql
FUNCTION get_running_chains(
    p_company_id IN NUMBER DEFAULT NULL
) RETURN SYS_REFCURSOR;
```
**Purpose**: Gets currently running chains
**Returns**: Cursor with running chain information

##### `GET_RUNNING_PROCESSES`
```sql
FUNCTION get_running_processes(
    p_chain_id IN NUMBER DEFAULT NULL
) RETURN SYS_REFCURSOR;
```
**Purpose**: Gets currently running processes

##### `GET_RUNNING_ACTIVITIES`
```sql
FUNCTION get_running_activities(
    p_process_id IN NUMBER DEFAULT NULL
) RETURN SYS_REFCURSOR;
```
**Purpose**: Gets currently running activities

### PCK_BATCH_TOOLS

Utility functions and tools.

#### Key Functions

##### `GET_NEW_ID`
```sql
FUNCTION get_new_id RETURN NUMBER;
```
**Purpose**: Generates a new unique ID
**Returns**: New ID from sequence

##### `ENLAPSED_TIME_STRING`
```sql
FUNCTION enlapsed_time_string(
    p_start_time IN TIMESTAMP,
    p_end_time IN TIMESTAMP
) RETURN VARCHAR2;
```
**Purpose**: Calculates elapsed time as formatted string
**Returns**: Formatted time string (e.g., "2h 15m 30s")

##### `SPLIT`
```sql
FUNCTION split(
    p_string IN VARCHAR2,
    p_delimiter IN VARCHAR2 DEFAULT ','
) RETURN tabMaxV2_type;
```
**Purpose**: Splits a string by delimiter
**Returns**: Table of strings

### PCK_BATCH_UTILS

Helper utilities and common functions.

#### Key Functions

##### `VALIDATE_CHAIN`
```sql
FUNCTION validate_chain(
    p_chain_id IN NUMBER
) RETURN BOOLEAN;
```
**Purpose**: Validates chain configuration
**Returns**: TRUE if valid, FALSE otherwise

##### `CLEANUP_OLD_EXECUTIONS`
```sql
PROCEDURE cleanup_old_executions(
    p_days_to_keep IN NUMBER DEFAULT 90
);
```
**Purpose**: Cleans up old execution records

## 🔧 Common Usage Patterns

### Creating a Complete Workflow

```sql
-- 1. Create company
DECLARE
    v_company_id NUMBER;
    v_chain_id NUMBER;
    v_process_id NUMBER;
    v_activity_id NUMBER;
BEGIN
    -- Create company
    v_company_id := pck_batch_companies.create_company(
        p_company_name => 'My Company',
        p_company_code => 'COMP001'
    );
    
    -- Create chain
    v_chain_id := pck_batch_manager.create_chain(
        p_chain_name => 'DATA_PROCESSING',
        p_description => 'Main data processing workflow',
        p_company_id => v_company_id
    );
    
    -- Create process
    v_process_id := pck_batch_mgr_processes.create_process(
        p_process_name => 'EXTRACT_AND_LOAD',
        p_description => 'Extract and load data',
        p_company_id => v_company_id
    );
    
    -- Add process to chain
    pck_batch_manager.add_process_to_chain(
        p_chain_name => 'DATA_PROCESSING',
        p_process_name => 'EXTRACT_AND_LOAD'
    );
    
    -- Create activity
    v_activity_id := pck_batch_mgr_activities.create_activity(
        p_activity_name => 'EXTRACT_DATA',
        p_action => 'MY_PACKAGE.EXTRACT_DATA_PROCEDURE',
        p_description => 'Extract data from source',
        p_company_id => v_company_id
    );
    
    -- Add activity to process
    pck_batch_mgr_processes.add_activity_to_process(
        p_process_name => 'EXTRACT_AND_LOAD',
        p_activity_name => 'EXTRACT_DATA'
    );
    
    -- Set company parameters
    pck_batch_companies.set_company_parameter(
        p_company_id => v_company_id,
        p_param_key => 'SOURCE_PATH',
        p_param_value => '/data/sources'
    );
    
    DBMS_OUTPUT.PUT_LINE('Workflow created successfully');
END;
/
```

### Monitoring Execution

```sql
-- Monitor running chains
DECLARE
    v_cursor SYS_REFCURSOR;
    v_chain_name VARCHAR2(100);
    v_start_time TIMESTAMP;
    v_status VARCHAR2(20);
BEGIN
    v_cursor := pck_batch_monitor.get_running_chains();
    
    LOOP
        FETCH v_cursor INTO v_chain_name, v_start_time, v_status;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Chain: ' || v_chain_name || 
                            ', Started: ' || v_start_time || 
                            ', Status: ' || v_status);
    END LOOP;
    
    CLOSE v_cursor;
END;
/
```

### Error Handling

```sql
-- Example with proper error handling
DECLARE
    v_exec_id NUMBER;
BEGIN
    -- Start execution
    v_exec_id := pck_batch_manager.start_chain_execution(
        p_chain_name => 'DATA_PROCESSING',
        p_company_id => 1
    );
    
    -- Log success
    pck_batch_mgr_log.log_info(
        p_message => 'Chain execution started successfully',
        p_source => 'MY_APPLICATION',
        p_source_id => v_exec_id
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        pck_batch_mgr_log.log_error(
            p_message => 'Failed to start chain execution: ' || SQLERRM,
            p_source => 'MY_APPLICATION'
        );
        RAISE;
END;
/
```

## 📊 Data Types

### Common Types

```sql
-- Execution state enumeration
TYPE execution_state_type IS TABLE OF VARCHAR2(20) INDEX BY PLS_INTEGER;

-- Parameter map
TYPE parameter_map_type IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(100);

-- Execution context
TYPE execution_context_type IS RECORD (
    chain_id NUMBER,
    process_id NUMBER,
    activity_id NUMBER,
    company_id NUMBER,
    execution_type VARCHAR2(20)
);
```

## 🔍 Troubleshooting

### Common Issues

1. **Chain Not Found**
   - Verify chain exists: `SELECT * FROM BATCH_CHAINS WHERE code = 'CHAIN_NAME';`
   - Check company context: Ensure correct company_id

2. **Permission Denied**
   - Verify user has HFOBATCH_USER or HFOBATCH_DEVELOPER role
   - Check specific object permissions

3. **Execution Hangs**
   - Check for locks: `SELECT * FROM V_BATCH_RUNNING_CHAINS;`
   - Review logs: `SELECT * FROM BATCH_SIMPLE_LOG ORDER BY timestamp DESC;`

### Debug Queries

```sql
-- Check chain status
SELECT * FROM V_BATCH_CHAIN_EXECUTIONS 
WHERE chain_name = 'YOUR_CHAIN' 
ORDER BY start_time DESC;

-- Check process status
SELECT * FROM V_BATCH_PROCESS_EXECUTIONS 
WHERE chain_exec_id = :chain_exec_id;

-- Check activity status
SELECT * FROM V_BATCH_ACTIVITY_EXECUTIONS 
WHERE process_exec_id = :process_exec_id;

-- Check recent logs
SELECT * FROM BATCH_SIMPLE_LOG 
WHERE timestamp > SYSDATE - 1 
ORDER BY timestamp DESC;
```

## 📞 Support

For API questions or issues:
- **Documentation**: See README.md and SYSTEM_ARCHITECTURE.md
- **Issues**: Create an issue in the project repository
- **Contact**: Eduardo Gutiérrez Tapia (edogt@hotmail.com)

---

**Note**: This API documentation is maintained alongside the codebase and will be updated with each release. 