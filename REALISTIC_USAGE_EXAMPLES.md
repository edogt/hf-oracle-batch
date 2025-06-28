# Realistic Usage Examples - HF Oracle Batch

> **📖 [Ver versión en español](REALISTIC_USAGE_EXAMPLES.es.md)**

## General Description

This document presents practical examples of the HF Oracle Batch system, showing how to implement complex batch process chains with **automatic parameter capture** and minimal configuration.

**⚠️ IMPORTANT**: The examples leverage the system's **automatic parameter introspection** capabilities. The `PCK_BATCH_UTILS` package automatically captures all procedure parameters, eliminating manual parameter definition.

## Example Schema: Financial Reports System

### Chain: MONTHLY_FINANCIAL_REPORTS
- **Description**: Generates complete financial reports at the end of each month
- **Frequency**: Monthly (first day of the following month)
- **Processes**: 4 main processes

### Process 1: DATA_PREPARATION (Serial execution)
**Activities**:
1. `VALIDATE_ACCOUNTING_DATA` - Validates accounting data integrity
2. `CALCULATE_BALANCES` - Calculates account balances
3. `CONSOLIDATE_COMPANIES` - Consolidates data from multiple companies

### Process 2: REPORT_GENERATION (Parallel execution)
**Activities**:
1. `GENERATE_BALANCE_SHEET` - Generates balance sheet
2. `GENERATE_INCOME_STATEMENT` - Generates income statement
3. `GENERATE_CASH_FLOW` - Generates cash flow statement
4. `GENERATE_FINANCIAL_NOTES` - Generates financial statement notes

### Process 3: REPORT_VALIDATION (Serial execution)
**Activities**:
1. `VALIDATE_CONSISTENCY` - Validates consistency between reports
2. `VERIFY_TOTALS` - Verifies totals and subtotals
3. `GENERATE_CERTIFICATION` - Generates report certification

### Process 4: REPORT_DISTRIBUTION (Parallel execution)
**Activities**:
1. `SEND_TO_MANAGEMENT` - Sends reports to management
2. `SEND_TO_AUDIT` - Sends reports to external audit
3. `PUBLISH_TO_PORTAL` - Publishes reports to corporate portal
4. `ARCHIVE_HISTORICAL` - Archives historical reports

## Implementation Code

### 1. Activity Definition (with Auto-Parameter Capture)

```sql
-- Process 1 Activities: DATA_PREPARATION
BEGIN
  -- Activity: Validate accounting data
  -- Parameters are automatically captured from PCK_FINANCIAL_REPORTS.validate_accounting_data
  PCK_BATCH_UTILS.createActivity(
    code => 'VALIDATE_ACCOUNTING_DATA',
    name => 'Validate Accounting Data',
    action => 'PCK_FINANCIAL_REPORTS.validate_accounting_data',
    description => 'Validates the integrity and consistency of accounting data'
  );
  
  -- Activity: Calculate balances
  -- Parameters are automatically captured from PCK_FINANCIAL_REPORTS.calculate_account_balances
  PCK_BATCH_UTILS.createActivity(
    code => 'CALCULATE_BALANCES',
    name => 'Calculate Balances',
    action => 'PCK_FINANCIAL_REPORTS.calculate_account_balances',
    description => 'Calculates balances for all accounting accounts'
  );
  
  -- Activity: Consolidate companies
  -- Parameters are automatically captured from PCK_FINANCIAL_REPORTS.consolidate_companies
  PCK_BATCH_UTILS.createActivity(
    code => 'CONSOLIDATE_COMPANIES',
    name => 'Consolidate Companies',
    action => 'PCK_FINANCIAL_REPORTS.consolidate_companies',
    description => 'Consolidates data from multiple subsidiary companies'
  );
END;
/

-- Process 2 Activities: REPORT_GENERATION
BEGIN
  -- Activity: Generate balance sheet
  -- Parameters are automatically captured from PCK_FINANCIAL_REPORTS.generate_balance_sheet
  PCK_BATCH_UTILS.createActivity(
    code => 'GENERATE_BALANCE_SHEET',
    name => 'Generate Balance Sheet',
    action => 'PCK_FINANCIAL_REPORTS.generate_balance_sheet',
    description => 'Generates the consolidated balance sheet'
  );
  
  -- Activity: Generate income statement
  -- Parameters are automatically captured from PCK_FINANCIAL_REPORTS.generate_income_statement
  PCK_BATCH_UTILS.createActivity(
    code => 'GENERATE_INCOME_STATEMENT',
    name => 'Generate Income Statement',
    action => 'PCK_FINANCIAL_REPORTS.generate_income_statement',
    description => 'Generates the consolidated income statement'
  );
  
  -- Activity: Generate cash flow statement
  -- Parameters are automatically captured from PCK_FINANCIAL_REPORTS.generate_cash_flow
  PCK_BATCH_UTILS.createActivity(
    code => 'GENERATE_CASH_FLOW',
    name => 'Generate Cash Flow Statement',
    action => 'PCK_FINANCIAL_REPORTS.generate_cash_flow',
    description => 'Generates the cash flow statement'
  );
  
  -- Activity: Generate financial notes
  -- Parameters are automatically captured from PCK_FINANCIAL_REPORTS.generate_financial_notes
  PCK_BATCH_UTILS.createActivity(
    code => 'GENERATE_FINANCIAL_NOTES',
    name => 'Generate Financial Notes',
    action => 'PCK_FINANCIAL_REPORTS.generate_financial_notes',
    description => 'Generates notes to financial statements'
  );
END;
/
```

### 2. Process Definition

```sql
-- Process 1: DATA_PREPARATION (Serial execution)
PCK_BATCH_UTILS.createProcess(
  code => 'DATA_PREPARATION',
  name => 'Data Preparation',
  description => 'Prepares and validates all data necessary for reports',
  config => '{"execution_mode": "sequential", "timeout": 1800, "retry_count": 2}',
  chain => 'MONTHLY_FINANCIAL_REPORTS',
  order_num => 1
);

-- Process 2: REPORT_GENERATION (Parallel execution)
PCK_BATCH_UTILS.createProcess(
  code => 'REPORT_GENERATION',
  name => 'Report Generation',
  description => 'Generates all financial reports in parallel',
  config => '{"execution_mode": "parallel", "max_parallel_jobs": 4, "timeout": 3600}',
  chain => 'MONTHLY_FINANCIAL_REPORTS',
  order_num => 2
);

-- Process 3: REPORT_VALIDATION (Serial execution)
PCK_BATCH_UTILS.createProcess(
  code => 'REPORT_VALIDATION',
  name => 'Report Validation',
  description => 'Validates and certifies all generated reports',
  config => '{"execution_mode": "sequential", "timeout": 900, "validation_strict": true}',
  chain => 'MONTHLY_FINANCIAL_REPORTS',
  order_num => 3
);

-- Process 4: REPORT_DISTRIBUTION (Parallel execution)
PCK_BATCH_UTILS.createProcess(
  code => 'REPORT_DISTRIBUTION',
  name => 'Report Distribution',
  description => 'Distributes reports to all recipients',
  config => '{"execution_mode": "parallel", "max_parallel_jobs": 4, "timeout": 600}',
  chain => 'MONTHLY_FINANCIAL_REPORTS',
  order_num => 4
);
```

### 3. Chain Definition

```sql
-- Create the main chain
PCK_BATCH_UTILS.createChain(
  code => 'MONTHLY_FINANCIAL_REPORTS',
  name => 'Monthly Financial Reports',
  description => 'Complete chain for monthly financial report generation',
  config => '{"timeout": 7200, "retry_count": 3, "notification_email": "admin@acme.com"}'
);
```

### 4. Activity to Process Association

```sql
-- Associate activities to Process 1: DATA_PREPARATION (serial)
PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'DATA_PREPARATION',
  activity_code => 'VALIDATE_ACCOUNTING_DATA',
  config => '{"order": 1, "timeout": 300}',
  predecessors => '{}'
);

PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'DATA_PREPARATION',
  activity_code => 'CALCULATE_BALANCES',
  config => '{"order": 2, "timeout": 600}',
  predecessors => '["VALIDATE_ACCOUNTING_DATA"]'
);

PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'DATA_PREPARATION',
  activity_code => 'CONSOLIDATE_COMPANIES',
  config => '{"order": 3, "timeout": 900}',
  predecessors => '["CALCULATE_BALANCES"]'
);

-- Associate activities to Process 2: REPORT_GENERATION (parallel)
PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'REPORT_GENERATION',
  activity_code => 'GENERATE_BALANCE_SHEET',
  config => '{"order": 1, "timeout": 1200}',
  predecessors => '{}'
);

PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'REPORT_GENERATION',
  activity_code => 'GENERATE_INCOME_STATEMENT',
  config => '{"order": 1, "timeout": 900}',
  predecessors => '{}'
);

PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'REPORT_GENERATION',
  activity_code => 'GENERATE_CASH_FLOW',
  config => '{"order": 1, "timeout": 1500}',
  predecessors => '{}'
);

PCK_BATCH_UTILS.addActivityToProcess(
  process_code => 'REPORT_GENERATION',
  activity_code => 'GENERATE_FINANCIAL_NOTES',
  config => '{"order": 1, "timeout": 1800}',
  predecessors => '{}'
);
```

### 5. Process to Chain Association

```sql
-- Associate processes to chain with dependencies
PCK_BATCH_UTILS.addProcessToChain(
  chain_code => 'MONTHLY_FINANCIAL_REPORTS',
  process_code => 'DATA_PREPARATION',
  predecessors => '{}',
  comments => 'First process: data preparation'
);

PCK_BATCH_UTILS.addProcessToChain(
  chain_code => 'MONTHLY_FINANCIAL_REPORTS',
  process_code => 'REPORT_GENERATION',
  predecessors => '["DATA_PREPARATION"]',
  comments => 'Second process: report generation (depends on preparation)'
);

PCK_BATCH_UTILS.addProcessToChain(
  chain_code => 'MONTHLY_FINANCIAL_REPORTS',
  process_code => 'REPORT_VALIDATION',
  predecessors => '["REPORT_GENERATION"]',
  comments => 'Third process: report validation (depends on generation)'
);

PCK_BATCH_UTILS.addProcessToChain(
  chain_code => 'MONTHLY_FINANCIAL_REPORTS',
  process_code => 'REPORT_DISTRIBUTION',
  predecessors => '["REPORT_VALIDATION"]',
  comments => 'Fourth process: report distribution (depends on validation)'
);
```

### 6. Chain Execution

```sql
-- Execute the chain manually
DECLARE
  v_chain_record BATCH_CHAINS%ROWTYPE;
BEGIN
  -- Get the chain record using the utility function
  v_chain_record := PCK_BATCH_UTILS.getChainByCode('MONTHLY_FINANCIAL_REPORTS');
  
  -- Execute the chain with parameters
  -- Note: run_chain automatically handles execution registration and completion
  PCK_BATCH_MANAGER.run_chain(
    chain_id => v_chain_record.id,
    paramsJSON => '{"report_period": "2024-01", "execution_user": "ADMIN", "output_format": "PDF", "EXECUTION_TYPE": "manual"}'
  );
END;
/
```

### 7. Monitoring and Queries

```sql
-- View current chain status
SELECT * FROM V_BATCH_CHAIN_EXECUTIONS 
WHERE chain_name = 'MONTHLY_FINANCIAL_REPORTS'
ORDER BY start_time DESC;

-- View running activities
SELECT * FROM V_BATCH_RUNNING_ACTIVITIES 
WHERE chain_name = 'MONTHLY_FINANCIAL_REPORTS';

-- View last status of each process
SELECT * FROM V_BATCH_PROCS_LAST_EXECS 
WHERE chain_name = 'MONTHLY_FINANCIAL_REPORTS';

-- View detailed logs
SELECT * FROM V_BATCH_SIMPLE_LOG 
WHERE chain_name = 'MONTHLY_FINANCIAL_REPORTS'
ORDER BY log_timestamp DESC;

-- View complete chain hierarchy
SELECT * FROM V_BATCH_DEFINITION_HIERARCHY 
WHERE chain_name = 'MONTHLY_FINANCIAL_REPORTS'
ORDER BY level_id, execution_order;
```

## Development Strategy with Simulated Activities

### Phase 1: Development with Simulation

```sql
-- Create simulated activities for development
BEGIN
  -- Simulated activity for data validation (fixed duration of 5 minutes)
  PCK_BATCH_SIM.activity('VALIDATE_ACCOUNTING_DATA', 300);
  
  -- Simulated activity for balance calculation (fixed duration of 10 minutes)
  PCK_BATCH_SIM.activity('CALCULATE_BALANCES', 600);
  
  -- Simulated activity for consolidation (fixed duration of 15 minutes)
  PCK_BATCH_SIM.activity('CONSOLIDATE_COMPANIES', 900);
  
  -- Simulated activity with random duration (between 10-120 seconds)
  PCK_BATCH_SIM.activity('GENERATE_BALANCE_SHEET');
  
  -- Simulated activity with random duration
  PCK_BATCH_SIM.activity('GENERATE_INCOME_STATEMENT');
END;
/
```

### Phase 2: Migration to Real Activities

```sql
-- Replace simulated activities with real ones
-- (This is done by updating the actions in already created activities)
DECLARE
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
BEGIN
  -- Update validation activity
  v_activity_record := PCK_BATCH_UTILS.getActivityByCode('VALIDATE_ACCOUNTING_DATA');
  v_activity_record.action := 'PCK_FINANCIAL_REPORTS.validate_accounting_data';
  v_activity_record.description := 'Validates the integrity and consistency of accounting data (REAL)';
  PCK_BATCH_UTILS.saveActivity(v_activity_record);
  
  -- Update calculation activity
  v_activity_record := PCK_BATCH_UTILS.getActivityByCode('CALCULATE_BALANCES');
  v_activity_record.action := 'PCK_FINANCIAL_REPORTS.calculate_account_balances';
  v_activity_record.description := 'Calculates balances for all accounting accounts (REAL)';
  PCK_BATCH_UTILS.saveActivity(v_activity_record);
  
  -- Update consolidation activity
  v_activity_record := PCK_BATCH_UTILS.getActivityByCode('CONSOLIDATE_COMPANIES');
  v_activity_record.action := 'PCK_FINANCIAL_REPORTS.consolidate_companies';
  v_activity_record.description := 'Consolidates data from multiple subsidiary companies (REAL)';
  PCK_BATCH_UTILS.saveActivity(v_activity_record);
  
  -- Re-capture parameters for updated activities
  PCK_BATCH_UTILS.addActivityParameters(
    PCK_BATCH_UTILS.getActivityByCode('VALIDATE_ACCOUNTING_DATA')
  );
  PCK_BATCH_UTILS.addActivityParameters(
    PCK_BATCH_UTILS.getActivityByCode('CALCULATE_BALANCES')
  );
  PCK_BATCH_UTILS.addActivityParameters(
    PCK_BATCH_UTILS.getActivityByCode('CONSOLIDATE_COMPANIES')
  );
END;
/
```

## Real-Time Monitoring

```sql
-- Monitor execution in real time
SELECT 
  chain_name,
  process_name,
  activity_name,
  status,
  start_time,
  end_time,
  duration_seconds,
  output_message
FROM V_BATCH_ACTIVITY_EXECUTIONS 
WHERE chain_execution_id = (
  SELECT MAX(chain_execution_id) 
  FROM BATCH_CHAIN_EXECUTIONS 
  WHERE chain_name = 'MONTHLY_FINANCIAL_REPORTS'
)
ORDER BY process_execution_order, activity_execution_order;
```

## Key Advantages of the System

### 1. **Automatic Parameter Capture**
- No need to manually define parameters
- Parameters are automatically captured from procedure signatures
- Always synchronized with the actual procedure definition

### 2. **Simple Configuration**
- Minimal configuration required
- Focus on business logic, not infrastructure
- Clean and readable code

### 3. **Flexible Execution Modes**
- Serial and parallel execution support
- Configurable timeouts and retry policies
- Dependency management between activities and processes

### 4. **Comprehensive Monitoring**
- Real-time execution status
- Detailed logging and error tracking
- Performance metrics and analytics

### 5. **Development-Friendly**
- Simulation mode for safe development
- Easy migration from simulation to production
- Version control and change management

## System Benefits

1. **Productivity**: 90% reduction in configuration time due to automatic parameter capture
2. **Reliability**: Automatic synchronization eliminates configuration errors
3. **Maintainability**: Changes to procedures automatically update parameters
4. **Scalability**: Easy to add new processes and activities
5. **Monitoring**: Complete visibility of execution status
6. **Flexibility**: Supports both serial and parallel execution patterns

This example demonstrates how the HF Oracle Batch system can handle complex batch processes with minimal configuration and maximum automation.

## Note on JSON Compatibility in Oracle

> **Compatibility:**
> - The main example uses `JSON_OBJECT_T` and native Oracle types for JSON manipulation (recommended for Oracle 19c and higher versions).
> - **If you use Oracle 12c or earlier**, you must use the utility methods of the `PCK_BATCH_TOOLS` package included in this system, which provide equivalent functions for creating and manipulating JSON objects in PL/SQL.
> - Consult the source code or internal documentation of `PCK_BATCH_TOOLS` for available methods: `getJSONFromSimpleMap`, `getSimpleMapFromSimpleJSON`, `getValueFromSimpleJSON`, etc. 