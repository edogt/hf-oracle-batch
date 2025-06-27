# Realistic Usage Examples - HF Oracle Batch

> **📖 [Ver versión en español](REALISTIC_USAGE_EXAMPLES.es.md)**

## General Description

This document presents practical examples of the HF Oracle Batch system, showing how to implement complex batch process chains with serial and parallel execution.

**⚠️ IMPORTANT**: The examples are based on the real API of the system. For complete documentation of each package, consult the specifications in the `packages/` directory.

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

### 1. Activity Definition

```sql
-- Process 1 Activities: DATA_PREPARATION
DECLARE
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
BEGIN
  -- Activity: Validate accounting data
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Validate Accounting Data',
    p_action => 'PCK_FINANCIAL_REPORTS.validate_accounting_data',
    p_code => 'VALIDATE_ACCOUNTING_DATA',
    p_description => 'Validates the integrity and consistency of accounting data',
    p_parameters => '{"timeout": 300, "validation_level": "strict"}'
  );
  
  -- Activity: Calculate balances
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Calculate Balances',
    p_action => 'PCK_FINANCIAL_REPORTS.calculate_account_balances',
    p_code => 'CALCULATE_BALANCES',
    p_description => 'Calculates balances for all accounting accounts',
    p_parameters => '{"timeout": 600, "include_subaccounts": true}'
  );
  
  -- Activity: Consolidate companies
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Consolidate Companies',
    p_action => 'PCK_FINANCIAL_REPORTS.consolidate_companies',
    p_code => 'CONSOLIDATE_COMPANIES',
    p_description => 'Consolidates data from multiple subsidiary companies',
    p_parameters => '{"timeout": 900, "consolidation_method": "full"}'
  );
END;
/

-- Process 2 Activities: REPORT_GENERATION
DECLARE
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
BEGIN
  -- Activity: Generate balance sheet
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Generate Balance Sheet',
    p_action => 'PCK_FINANCIAL_REPORTS.generate_balance_sheet',
    p_code => 'GENERATE_BALANCE_SHEET',
    p_description => 'Generates the consolidated balance sheet',
    p_parameters => '{"timeout": 1200, "format": "PDF", "include_charts": true}'
  );
  
  -- Activity: Generate income statement
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Generate Income Statement',
    p_action => 'PCK_FINANCIAL_REPORTS.generate_income_statement',
    p_code => 'GENERATE_INCOME_STATEMENT',
    p_description => 'Generates the consolidated income statement',
    p_parameters => '{"timeout": 900, "format": "PDF", "include_charts": true}'
  );
  
  -- Activity: Generate cash flow statement
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Generate Cash Flow Statement',
    p_action => 'PCK_FINANCIAL_REPORTS.generate_cash_flow',
    p_code => 'GENERATE_CASH_FLOW',
    p_description => 'Generates the cash flow statement',
    p_parameters => '{"timeout": 1500, "format": "PDF", "include_charts": true}'
  );
  
  -- Activity: Generate financial notes
  v_activity_record := PCK_BATCH_MGR_CHAINS.create_activity(
    p_name => 'Generate Financial Notes',
    p_action => 'PCK_FINANCIAL_REPORTS.generate_financial_notes',
    p_code => 'GENERATE_FINANCIAL_NOTES',
    p_description => 'Generates notes to financial statements',
    p_parameters => '{"timeout": 1800, "format": "PDF", "include_legal_text": true}'
  );
END;
/
```

### 2. Process Definition

```sql
-- Process 1: DATA_PREPARATION (Serial execution)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
BEGIN
  v_process_record := PCK_BATCH_MGR_CHAINS.create_process(
    p_name => 'Data Preparation',
    p_code => 'DATA_PREPARATION',
    p_description => 'Prepares and validates all data necessary for reports',
    p_config => '{"execution_mode": "sequential", "timeout": 1800, "retry_count": 2}',
    p_chain => 'MONTHLY_FINANCIAL_REPORTS',
    p_order => '1'
  );
END;
/

-- Process 2: REPORT_GENERATION (Parallel execution)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
BEGIN
  v_process_record := PCK_BATCH_MGR_CHAINS.create_process(
    p_name => 'Report Generation',
    p_code => 'REPORT_GENERATION',
    p_description => 'Generates all financial reports in parallel',
    p_config => '{"execution_mode": "parallel", "max_parallel_jobs": 4, "timeout": 3600}',
    p_chain => 'MONTHLY_FINANCIAL_REPORTS',
    p_order => '2'
  );
END;
/

-- Process 3: REPORT_VALIDATION (Serial execution)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
BEGIN
  v_process_record := PCK_BATCH_MGR_CHAINS.create_process(
    p_name => 'Report Validation',
    p_code => 'REPORT_VALIDATION',
    p_description => 'Validates and certifies all generated reports',
    p_config => '{"execution_mode": "sequential", "timeout": 900, "validation_strict": true}',
    p_chain => 'MONTHLY_FINANCIAL_REPORTS',
    p_order => '3'
  );
END;
/

-- Process 4: REPORT_DISTRIBUTION (Parallel execution)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
BEGIN
  v_process_record := PCK_BATCH_MGR_CHAINS.create_process(
    p_name => 'Report Distribution',
    p_code => 'REPORT_DISTRIBUTION',
    p_description => 'Distributes reports to all recipients',
    p_config => '{"execution_mode": "parallel", "max_parallel_jobs": 4, "timeout": 600}',
    p_chain => 'MONTHLY_FINANCIAL_REPORTS',
    p_order => '4'
  );
END;
/
```

### 3. Chain Definition

```sql
-- Create the main chain
DECLARE
  v_chain_record BATCH_CHAINS%ROWTYPE;
BEGIN
  v_chain_record := PCK_BATCH_MGR_CHAINS.create_chain(
    p_name => 'Monthly Financial Reports',
    p_code => 'MONTHLY_FINANCIAL_REPORTS',
    p_description => 'Complete chain for monthly financial report generation',
    p_config => '{"timeout": 7200, "retry_count": 3, "notification_email": "admin@acme.com"}'
  );
END;
/
```

### 4. Activity to Process Association

```sql
-- Associate activities to Process 1: DATA_PREPARATION (serial)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
  v_proc_activ_record BATCH_PROCESS_ACTIVITIES%ROWTYPE;
BEGIN
  -- Get existing process and activities
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'DATA_PREPARATION';
  
  -- Add activity 1: Validate accounting data
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'VALIDATE_ACCOUNTING_DATA';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Validate Accounting Data',
    p_config => '{"order": 1, "timeout": 300}',
    p_predecessors => '{}'
  );
  
  -- Add activity 2: Calculate balances (depends on validation)
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'CALCULATE_BALANCES';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Calculate Balances',
    p_config => '{"order": 2, "timeout": 600}',
    p_predecessors => '["VALIDATE_ACCOUNTING_DATA"]'
  );
  
  -- Add activity 3: Consolidate companies (depends on calculation)
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'CONSOLIDATE_COMPANIES';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Consolidate Companies',
    p_config => '{"order": 3, "timeout": 900}',
    p_predecessors => '["CALCULATE_BALANCES"]'
  );
END;
/

-- Associate activities to Process 2: REPORT_GENERATION (parallel)
DECLARE
  v_process_record BATCH_PROCESSES%ROWTYPE;
  v_activity_record BATCH_ACTIVITIES%ROWTYPE;
  v_proc_activ_record BATCH_PROCESS_ACTIVITIES%ROWTYPE;
BEGIN
  -- Get existing process
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'REPORT_GENERATION';
  
  -- Add activities in parallel (all with same order)
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'GENERATE_BALANCE_SHEET';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Generate Balance Sheet',
    p_config => '{"order": 1, "timeout": 1200}',
    p_predecessors => '{}'
  );
  
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'GENERATE_INCOME_STATEMENT';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Generate Income Statement',
    p_config => '{"order": 1, "timeout": 900}',
    p_predecessors => '{}'
  );
  
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'GENERATE_CASH_FLOW';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Generate Cash Flow Statement',
    p_config => '{"order": 1, "timeout": 1500}',
    p_predecessors => '{}'
  );
  
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'GENERATE_FINANCIAL_NOTES';
  v_proc_activ_record := PCK_BATCH_MGR_CHAINS.add_activity_to_process(
    p_process => v_process_record,
    p_activity => v_activity_record,
    p_name => 'Generate Financial Notes',
    p_config => '{"order": 1, "timeout": 1800}',
    p_predecessors => '{}'
  );
END;
/
```

### 5. Process to Chain Association

```sql
-- Associate processes to chain with dependencies
DECLARE
  v_chain_record BATCH_CHAINS%ROWTYPE;
  v_process_record BATCH_PROCESSES%ROWTYPE;
BEGIN
  -- Get existing chain
  SELECT * INTO v_chain_record FROM BATCH_CHAINS WHERE code = 'MONTHLY_FINANCIAL_REPORTS';
  
  -- Add Process 1: DATA_PREPARATION (no predecessors)
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'DATA_PREPARATION';
  PCK_BATCH_MGR_CHAINS.add_process_to_chain(
    p_chain => v_chain_record,
    p_process => v_process_record,
    p_predecesors => '{}',
    comments => 'First process: data preparation'
  );
  
  -- Add Process 2: REPORT_GENERATION (depends on DATA_PREPARATION)
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'REPORT_GENERATION';
  PCK_BATCH_MGR_CHAINS.add_process_to_chain(
    p_chain => v_chain_record,
    p_process => v_process_record,
    p_predecesors => '["DATA_PREPARATION"]',
    comments => 'Second process: report generation (depends on preparation)'
  );
  
  -- Add Process 3: REPORT_VALIDATION (depends on REPORT_GENERATION)
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'REPORT_VALIDATION';
  PCK_BATCH_MGR_CHAINS.add_process_to_chain(
    p_chain => v_chain_record,
    p_process => v_process_record,
    p_predecesors => '["REPORT_GENERATION"]',
    comments => 'Third process: report validation (depends on generation)'
  );
  
  -- Add Process 4: REPORT_DISTRIBUTION (depends on REPORT_VALIDATION)
  SELECT * INTO v_process_record FROM BATCH_PROCESSES WHERE code = 'REPORT_DISTRIBUTION';
  PCK_BATCH_MGR_CHAINS.add_process_to_chain(
    p_chain => v_chain_record,
    p_process => v_process_record,
    p_predecesors => '["REPORT_VALIDATION"]',
    comments => 'Fourth process: report distribution (depends on validation)'
  );
END;
/
```

### 6. Chain Execution

```sql
-- Execute the chain manually
DECLARE
  v_chain_exec_id NUMBER;
BEGIN
  -- Register chain execution start
  v_chain_exec_id := PCK_BATCH_MANAGER.chain_execution_register(
    chain_code => 'MONTHLY_FINANCIAL_REPORTS',
    execution_type => 'manual',
    sim_mode => FALSE,
    execution_comments => 'Manual execution of financial reports - January 2024'
  );
  
  -- Execute the chain with parameters
  PCK_BATCH_MANAGER.run_chain(
    chain_id => v_chain_exec_id,
    paramsJSON => '{"report_period": "2024-01", "execution_user": "ADMIN", "output_format": "PDF"}'
  );
  
  -- Register successful completion
  PCK_BATCH_MANAGER.chain_exec_end_register(
    chain_exec_id => v_chain_exec_id,
    end_type => 'finished',
    end_comments => 'Financial reports generated successfully'
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
  SELECT * INTO v_activity_record FROM BATCH_ACTIVITIES WHERE code = 'VALIDATE_ACCOUNTING_DATA';
  UPDATE BATCH_ACTIVITIES 
  SET action = 'PCK_FINANCIAL_REPORTS.validate_accounting_data',
      description = 'Validates the integrity and consistency of accounting data (REAL)'
  WHERE code = 'VALIDATE_ACCOUNTING_DATA';
  
  -- Update calculation activity
  UPDATE BATCH_ACTIVITIES 
  SET action = 'PCK_FINANCIAL_REPORTS.calculate_account_balances',
      description = 'Calculates balances for all accounting accounts (REAL)'
  WHERE code = 'CALCULATE_BALANCES';
  
  -- Update consolidation activity
  UPDATE BATCH_ACTIVITIES 
  SET action = 'PCK_FINANCIAL_REPORTS.consolidate_companies',
      description = 'Consolidates data from multiple subsidiary companies (REAL)'
  WHERE code = 'CONSOLIDATE_COMPANIES';
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

## System Benefits

1. **Flexibility**: Allows serial and parallel execution according to needs
2. **Scalability**: Easy to add new processes and activities
3. **Monitoring**: Complete visibility of execution status
4. **Maintainability**: Clear separation between business logic and orchestration
5. **Reliability**: Robust error handling and dependencies
6. **Development**: Simulation strategy for safe development

This example demonstrates how the HF Oracle Batch system can handle complex batch processes efficiently and reliably.

## Note on JSON Compatibility in Oracle

> **Compatibility:**
> - The main example uses `JSON_OBJECT_T` and native Oracle types for JSON manipulation (recommended for Oracle 19c and higher versions).
> - **If you use Oracle 12c or earlier**, you must use the utility methods of the `PCK_BATCH_TOOLS` package included in this system, which provide equivalent functions for creating and manipulating JSON objects in PL/SQL.
> - Consult the source code or internal documentation of `PCK_BATCH_TOOLS` for available methods: `getJSONFromSimpleMap`, `getSimpleMapFromSimpleJSON`, `getValueFromSimpleJSON`, etc. 