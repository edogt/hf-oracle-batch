/**
 * View: V_BATCH_PROCS_LAST_EXECS
 * Description: Last process executions view with chain context and timing information.
 *              Provides recent process execution history including chain relationships
 *              and formatted timing for monitoring and analysis of process performance.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor recent process execution history and status
 *   - Provide process execution timing analysis and reporting
 *   - Support process performance monitoring and trend analysis
 *   - Enable process execution tracking with chain context
 *
 * Query Description:
 *   - Joins process executions with processes, chain executions, and chains
 *   - Uses outer joins to include processes not associated with chains
 *   - Formats timestamps and calculates elapsed time using PCK_BATCH_TOOLS
 *   - Orders results by execution ID descending (most recent first)
 *
 * Usage Examples:
 * 
 * -- Get all recent process executions
 * SELECT * FROM V_BATCH_PROCS_LAST_EXECS 
 * ORDER BY EXEC_ID DESC;
 *
 * -- Get completed processes
 * SELECT * FROM V_BATCH_PROCS_LAST_EXECS 
 * WHERE EXECUTION_STATE = 'COMPLETED'
 * ORDER BY EXEC_ID DESC;
 *
 * -- Get processes for a specific chain
 * SELECT * FROM V_BATCH_PROCS_LAST_EXECS 
 * WHERE CHAIN = 'DAILY_BATCH_CHAIN'
 * ORDER BY START_TIME DESC;
 *
 * -- Get long-running processes (> 1 hour)
 * SELECT * FROM V_BATCH_PROCS_LAST_EXECS 
 * WHERE EXECUTION_STATE = 'RUNNING'
 * AND START_TIME < SYSTIMESTAMP - INTERVAL '0 1:0:0' DAY TO SECOND
 * ORDER BY START_TIME;
 *
 * -- Get process execution summary by chain
 * SELECT CHAIN, COUNT(*) as total_executions,
 *        SUM(CASE WHEN EXECUTION_STATE = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
 *        SUM(CASE WHEN EXECUTION_STATE = 'FAILED' THEN 1 ELSE 0 END) as failed
 * FROM V_BATCH_PROCS_LAST_EXECS 
 * WHERE CHAIN IS NOT NULL
 * GROUP BY CHAIN
 * ORDER BY total_executions DESC;
 *
 * -- Get recent executions for a specific process
 * SELECT * FROM V_BATCH_PROCS_LAST_EXECS 
 * WHERE CODE = 'DATA_PROCESSING'
 * ORDER BY EXEC_ID DESC;
 *
 * -- Get failed processes with details
 * SELECT * FROM V_BATCH_PROCS_LAST_EXECS 
 * WHERE EXECUTION_STATE = 'FAILED'
 * ORDER BY START_TIME DESC;
 *
 * -- Get process performance analysis
 * SELECT PROCESS_NAME, COUNT(*) as execution_count,
 *        AVG(EXTRACT(SECOND FROM (END_TIME - START_TIME))) as avg_duration_seconds
 * FROM V_BATCH_PROCS_LAST_EXECS 
 * WHERE END_TIME IS NOT NULL
 * GROUP BY PROCESS_NAME
 * ORDER BY avg_duration_seconds DESC;
 *
 * Related Objects:
 * - Tables: BATCH_PROCESS_EXECUTIONS, BATCH_PROCESSES, BATCH_CHAIN_EXECUTIONS, BATCH_CHAINS
 * - Views: V_BATCH_PROCESS_EXECUTIONS, V_BATCH_RUNNING_PROCESSES
 * - Packages: PCK_BATCH_MGR_PROCESSES, PCK_BATCH_TOOLS, PCK_BATCH_MONITOR
 */

--------------------------------------------------------
--  DDL for View V_BATCH_PROCS_LAST_EXECS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_PROCS_LAST_EXECS (
    EXEC_ID,              -- Unique execution identifier
    CHAIN,                -- Chain code for identification
    CODE,                 -- Process code for identification
    PROCESS_NAME,         -- Process name and description
    EXECUTION_TYPE,       -- Type of execution (MANUAL, SCHEDULED, etc.)
    EXECUTION_STATE,      -- Current execution state (RUNNING, COMPLETED, FAILED, etc.)
    START_TIME,           -- Formatted execution start timestamp
    END_TIME,             -- Formatted execution end timestamp
    ENLAPSED_TIME         -- Calculated elapsed time (formatted string)
) AS
select      procexec.id exec_id,
         chain.code chain,
         proc.code,
             proc.name process_name,
             procexec.execution_type execution_type,
             procexec.execution_state execution_state,
             to_char(procexec.start_time,'dd/mm/yyyy hh:mi:ss') start_time,
             to_char(procexec.end_time,'dd/mm/yyyy hh:mi:ss') end_time,
             pck_batch_tools.enlapsedTimeString(procexec.start_time, procexec.end_time) enlapsed_time
     from BATCH_PROCESS_EXECUTIONS procexec,
             BATCH_PROCESSES proc,
             batch_chain_executions chainexec,
             batch_chains chain
     where ( 1 = 1 )
         and chain.id (+) = chainexec.chain_id
         and chainexec.id (+) = procexec.chain_exec_id
         and proc.id = procexec.process_id
     order by 1 desc
;
GRANT SELECT ON V_BATCH_PROCS_LAST_EXECS TO ROLE_BATCH_MAN;
