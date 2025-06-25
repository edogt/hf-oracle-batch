# Types Directory - Batch Management System

## Overview

This directory contains Oracle object types and collections used throughout the batch management system. These types provide structured data handling, logging capabilities, and scheduler functionality.

## Type Categories

### 1. Core Types
- **BATCH_LOGGER**: Advanced logging object with automatic context detection and configurable error handling
  - Supports multiple log levels (ERROR, ALERT, INFO, LOG, DEBUG)
  - Automatic execution context detection
  - Structured error handling with optional auto-raise

### 2. Scheduler Types (TYP_SCHED_*)
A comprehensive set of types for Oracle Scheduler integration:

#### Chain Management
- **TYP_SCHED_CHAINS**: Individual chain definition
- **TYP_SCHED_CHAINS_SET**: Collection of chains
- **TYP_SCHED_CHAIN_RULES**: Chain execution rules
- **TYP_SCHED_CHAIN_RULES_SET**: Collection of chain rules
- **TYP_SCHED_CHAIN_STEPS**: Chain execution steps
- **TYP_SCHED_CHAIN_STEPS_SET**: Collection of chain steps

#### Job Management
- **TYP_SCHED_JOBS**: Individual job definition
- **TYP_SCHED_JOBS_SET**: Collection of jobs
- **TYP_SCHED_JOB_DESTS**: Job destinations
- **TYP_SCHED_JOB_DESTS_SET**: Collection of job destinations
- **TYP_SCHED_JOB_LOG**: Job execution logs
- **TYP_SCHED_JOB_LOG_SET**: Collection of job logs
- **TYP_SCHED_JOB_RUN_DETAILS**: Detailed job execution information
- **TYP_SCHED_JOB_RUN_DETAILS_SET**: Collection of job run details

#### Program Management
- **TYP_SCHED_PROGRAMS**: Program definitions
- **TYP_SCHED_PROGRAMS_SET**: Collection of programs

#### Runtime Monitoring
- **TYP_SCHED_RUNNING_CHAINS**: Currently running chains
- **TYP_SCHED_RUNNING_CHAINS_SET**: Collection of running chains
- **TYP_SCHED_RUNNING_JOBS**: Currently running jobs
- **TYP_SCHED_RUNNING_JOBS_SET**: Collection of running jobs

## Usage Patterns

### Collection Pattern (*_SET types)
All scheduler types follow a consistent pattern with individual types and their corresponding collection types:

```sql
-- Individual type usage
DECLARE
  v_chain TYP_SCHED_CHAINS;
BEGIN
  v_chain.chain_id := 1;
  v_chain.chain_name := 'MY_CHAIN';
  -- ... set other properties
END;

-- Collection type usage
DECLARE
  v_chains TYP_SCHED_CHAINS_SET;
BEGIN
  v_chains := TYP_SCHED_CHAINS_SET();
  v_chains.EXTEND;
  v_chains(v_chains.LAST) := TYP_SCHED_CHAINS(1, 'CHAIN1', 'Description');
END;
```

### Logger Usage Pattern
The BATCH_LOGGER type provides the most complex functionality:

```sql
-- Basic logging
DECLARE
  v_logger BATCH_LOGGER;
BEGIN
  v_logger := BATCH_LOGGER(execution_id);
  v_logger.info('Operation started');
  v_logger.error('Error occurred', '{"details": "error_info"}');
END;
```

## Integration Points

### With Packages
- **PCK_BATCH_MGR_ACTIVITIES**: Uses BATCH_LOGGER for activity execution logging
- **PCK_BATCH_MGR_PROCESSES**: Uses BATCH_LOGGER for process execution logging
- **PCK_BATCH_MGR_CHAINS**: Uses BATCH_LOGGER for chain execution logging
- **PCK_BATCH_MGR_LOG**: Core logging package that BATCH_LOGGER depends on

### With Tables
- **BATCH_SIMPLE_LOG**: Target table for all logger output
- **BATCH_ACTIVITY_EXECUTIONS**: Referenced by logger for context
- **BATCH_PROCESS_EXECUTIONS**: Referenced by logger for context
- **BATCH_CHAIN_EXECUTIONS**: Referenced by logger for context

## Best Practices

1. **Logger Usage**:
   - Always initialize BATCH_LOGGER with appropriate execution ID
   - Use appropriate log levels (ERROR for critical issues, DEBUG for troubleshooting)
   - Include structured data in CLOB format for complex information

2. **Scheduler Types**:
   - Use collection types for bulk operations
   - Validate data before assigning to types
   - Follow naming conventions consistently

3. **Error Handling**:
   - Use BATCH_LOGGER.error() for critical errors
   - Consider using setAutoRaise(FALSE) for non-critical logging
   - Include context information in log messages

## Deployment Order

When deploying the system, types should be created in this order:

1. Core types (BATCH_LOGGER)
2. Individual scheduler types
3. Collection scheduler types
4. Packages that depend on types
5. Views that use types

## Examples

See individual type files for specific usage examples and the BATCH_LOGGER type for comprehensive logging examples.

---

**Author**: Eduardo Gutiérrez Tapia (edogt@hotmail.com)  
**Last Updated**: [Current Date] 