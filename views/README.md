# Views Directory - Batch Management System

## Overview

This directory contains Oracle views that provide simplified access to batch management data, monitoring capabilities, and reporting interfaces. These views abstract complex joins and provide business-friendly data access patterns.

## View Categories

### 1. Monitoring Views (V_BATCH_RUNNING_*)
Real-time monitoring of active executions:

- **V_BATCH_RUNNING_ACTIVITIES**: Currently executing activities with context
- **V_BATCH_RUNNING_CHAINS**: Currently executing chains with status
- **V_BATCH_RUNNING_CHAINS2**: Alternative chain monitoring view
- **V_BATCH_RUNNING_PROCESSES**: Currently executing processes with context

### 2. Execution History Views (V_BATCH_*_EXECUTIONS)
Historical execution data with enriched context:

- **V_BATCH_ACTIVITY_EXECUTIONS**: Activity execution history with timing and context
- **V_BATCH_CHAIN_EXECUTIONS**: Chain execution history with status
- **V_BATCH_CHAIN_EXECS**: Simplified chain execution view
- **V_BATCH_PROCESS_EXECUTIONS**: Process execution history with context

### 3. Last Execution Views (V_BATCH_*_LAST_EXECS)
Latest execution information for quick status checks:

- **V_BATCH_ACTIVS_LAST_EXECS**: Most recent activity executions
- **V_BATCH_PROCS_LAST_EXECS**: Most recent process executions
- **V_BATCH_CHAIN_LAST_EXECS_VIEW**: Most recent chain executions

### 4. Scheduler Integration Views (V_BATCH_SCHED_*)
Oracle Scheduler integration and monitoring:

- **V_BATCH_SCHED_CHAINS**: Scheduler chain definitions
- **V_BATCH_SCHED_CHAIN_RULES**: Chain execution rules
- **V_BATCH_SCHED_CHAIN_STEPS**: Chain execution steps
- **V_BATCH_SCHED_JOBS**: Scheduler job definitions
- **V_BATCH_SCHED_JOB_DESTS**: Job destinations
- **V_BATCH_SCHED_JOB_LOG**: Job execution logs
- **V_BATCH_SCHED_JOB_RUN_DETAILS**: Detailed job execution information
- **V_BATCH_SCHED_PROGRAMS**: Program definitions
- **V_BATCH_SCHED_RUNNING_CHAINS**: Currently running scheduler chains
- **V_BATCH_SCHED_RUNNING_JOBS**: Currently running scheduler jobs

### 5. Logging Views (V_BATCH_*_LOG)
Log access and analysis:

- **V_BATCH_SIMPLE_LOG**: Application log entries
- **V_BATCH_LAST_SIMPLE_LOG**: Most recent log entries

### 6. Utility Views
Specialized utility and testing views:

- **V_BATCH_DEFINITION_HIERARCHY**: Hierarchical view of batch definitions
- **V_BATCH_TOOLS**: Utility functions and tools
- **V_BORRAR**: Cleanup utility view
- **V_TEST_CHAINS**: Testing view for chains
- **V_TEST_TABLE**: Testing view

## Usage Patterns

### Monitoring Queries
```sql
-- Check currently running activities
SELECT * FROM V_BATCH_RUNNING_ACTIVITIES 
WHERE execution_state = 'RUNNING';

-- Monitor chain execution status
SELECT * FROM V_BATCH_RUNNING_CHAINS 
WHERE chain_execution_state = 'RUNNING';
```

### Historical Analysis
```sql
-- Analyze activity execution performance
SELECT actividad_descripcion, tiempo_transcurrido, execution_state
FROM V_BATCH_ACTIVITY_EXECUTIONS 
WHERE start_time >= SYSDATE - 1
ORDER BY start_time DESC;

-- Review recent process executions
SELECT proceso_nombre, execution_state, start_time, end_time
FROM V_BATCH_PROCESS_EXECUTIONS 
WHERE start_time >= SYSDATE - 7
ORDER BY start_time DESC;
```

### Scheduler Integration
```sql
-- Check scheduler job status
SELECT job_name, state, last_start_date, next_run_date
FROM V_BATCH_SCHED_JOBS 
WHERE enabled = 'TRUE';

-- Monitor running scheduler chains
SELECT chain_name, state, start_date
FROM V_BATCH_SCHED_RUNNING_CHAINS;
```

## View Relationships

### Execution Hierarchy
```
V_BATCH_CHAIN_EXECUTIONS
    ↓ (chain_exec_id)
V_BATCH_PROCESS_EXECUTIONS  
    ↓ (process_exec_id)
V_BATCH_ACTIVITY_EXECUTIONS
```

### Monitoring Flow
```
V_BATCH_RUNNING_CHAINS → V_BATCH_RUNNING_PROCESSES → V_BATCH_RUNNING_ACTIVITIES
```

### Scheduler Integration
```
V_BATCH_SCHED_CHAINS → V_BATCH_SCHED_CHAIN_STEPS → V_BATCH_SCHED_JOBS
```

## Performance Considerations

1. **Indexed Columns**: Views use indexed columns for optimal performance
2. **Filtering**: Use date/time filters for large result sets
3. **Execution State**: Filter by execution_state for current status
4. **Company Context**: Use company_id filters for multi-tenant environments

## Common Use Cases

### 1. Dashboard Monitoring
```sql
-- Real-time dashboard query
SELECT 
  (SELECT COUNT(*) FROM V_BATCH_RUNNING_CHAINS WHERE chain_execution_state = 'RUNNING') as running_chains,
  (SELECT COUNT(*) FROM V_BATCH_RUNNING_PROCESSES WHERE execution_state = 'RUNNING') as running_processes,
  (SELECT COUNT(*) FROM V_BATCH_RUNNING_ACTIVITIES WHERE execution_state = 'RUNNING') as running_activities
FROM dual;
```

### 2. Performance Analysis
```sql
-- Execution time analysis
SELECT 
  actividad_descripcion,
  AVG(EXTRACT(SECOND FROM (end_time - start_time))) as avg_duration_seconds,
  COUNT(*) as execution_count
FROM V_BATCH_ACTIVITY_EXECUTIONS 
WHERE start_time >= SYSDATE - 30
GROUP BY actividad_descripcion
ORDER BY avg_duration_seconds DESC;
```

### 3. Error Monitoring
```sql
-- Recent errors
SELECT log_date, log_message, reference_type, reference_id
FROM V_BATCH_SIMPLE_LOG 
WHERE log_level = 'ERROR' 
  AND log_date >= SYSDATE - 1
ORDER BY log_date DESC;
```

## Integration Points

### With Packages
- **PCK_BATCH_MONITOR**: Uses monitoring views for status checks
- **PCK_BATCH_MGR_REPORT**: Uses execution views for reporting
- **PCK_BATCH_TOOLS**: Uses utility views for operations

### With Types
- **BATCH_LOGGER**: Writes to tables accessed by log views
- **TYP_SCHED_***: Used by scheduler integration views

## Best Practices

1. **Use Appropriate Views**: Choose views based on your specific needs
2. **Apply Filters**: Always filter by date/time for historical data
3. **Monitor Performance**: Use execution state filters for current status
4. **Consider Context**: Use company_id filters in multi-tenant environments
5. **Join Carefully**: Some views already include complex joins

## Deployment Order

Views should be created after:
1. All tables are created
2. All types are created
3. All packages are compiled
4. All indexes are created

---

**Author**: Eduardo Gutiérrez Tapia (edogt@hotmail.com)  
**Last Updated**: [Current Date] 