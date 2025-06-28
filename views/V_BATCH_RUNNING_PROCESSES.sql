/**
 * View: V_BATCH_RUNNING_PROCESSES
 * Description: Real-time view of currently running batch processes with hierarchical context.
 *              Provides immediate visibility into active process executions
 *              including timing, chain context, and company information for operational monitoring.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor currently running process executions in real-time
 *   - Provide operational visibility into active batch processes
 *   - Support process execution monitoring and alerting
 *   - Enable real-time performance analysis of running processes
 *
 * Query Description:
 *   - Filters process executions to show only RUNNING state
 *   - Joins with processes, chain executions, chains, and companies for complete context
 *   - Uses PCK_BATCH_TOOLS.ENLAPSEDTIMESTRING for elapsed time calculation
 *   - Provides immediate operational visibility for monitoring dashboards
 *
 * Usage Examples:
 * 
 * -- Get all currently running processes
 * SELECT * FROM V_BATCH_RUNNING_PROCESSES 
 * ORDER BY START_TIME;
 *
 * -- Get running processes for a specific company
 * SELECT * FROM V_BATCH_RUNNING_PROCESSES 
 * WHERE COMPANIA_DESCRIPCION = 'ACME Corp'
 * ORDER BY START_TIME;
 *
 * -- Get long-running processes (> 1 hour)
 * SELECT * FROM V_BATCH_RUNNING_PROCESSES 
 * WHERE START_TIME < SYSTIMESTAMP - INTERVAL '0 1:0:0' DAY TO SECOND
 * ORDER BY START_TIME;
 *
 * -- Get process execution summary by company
 * SELECT COMPANIA_DESCRIPCION, COUNT(*) as running_processes,
 *        AVG(EXTRACT(SECOND FROM (SYSTIMESTAMP - START_TIME))) as avg_running_seconds
 * FROM V_BATCH_RUNNING_PROCESSES 
 * GROUP BY COMPANIA_DESCRIPCION
 * ORDER BY running_processes DESC;
 *
 * -- Get processes by chain
 * SELECT CADENA_DESCRIPCION, COUNT(*) as running_processes,
 *        MIN(START_TIME) as earliest_start,
 *        MAX(START_TIME) as latest_start
 * FROM V_BATCH_RUNNING_PROCESSES 
 * GROUP BY CADENA_DESCRIPCION
 * ORDER BY running_processes DESC;
 *
 * -- Get potentially stuck processes (> 3 hours)
 * SELECT * FROM V_BATCH_RUNNING_PROCESSES 
 * WHERE START_TIME < SYSTIMESTAMP - INTERVAL '0 3:0:0' DAY TO SECOND
 * ORDER BY START_TIME;
 *
 * -- Get process performance analysis
 * SELECT PROCESO_NOMBRE, COUNT(*) as running_count,
 *        AVG(EXTRACT(SECOND FROM (SYSTIMESTAMP - START_TIME))) as avg_running_seconds
 * FROM V_BATCH_RUNNING_PROCESSES 
 * GROUP BY PROCESO_NOMBRE
 * ORDER BY running_count DESC;
 *
 * Related Objects:
 * - Tables: BATCH_PROCESS_EXECUTIONS, BATCH_PROCESSES, BATCH_CHAIN_EXECUTIONS
 * - Tables: BATCH_CHAINS, BATCH_COMPANIES
 * - Views: V_BATCH_PROCESS_EXECUTIONS, V_BATCH_PROCS_LAST_EXECS
 * - Packages: PCK_BATCH_MGR_PROCESSES, PCK_BATCH_TOOLS, PCK_BATCH_MONITOR
 */

--------------------------------------------------------
--  DDL for View V_BATCH_RUNNING_PROCESSES
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_RUNNING_PROCESSES (
    ID,                    -- Unique execution identifier
    PROCESS_ID,            -- Reference to the process being executed
    CHAIN_EXEC_ID,         -- Reference to parent chain execution
    START_TIME,            -- Execution start timestamp
    END_TIME,              -- Execution end timestamp (null for running processes)
    COMMENTS,              -- Execution comments and notes
    STATE,                 -- Current state (always 'RUNNING' for this view)
    TIEMPO_TRANSCURRIDO,   -- Calculated elapsed time (formatted string)
    PROCESO_ID,            -- Process identifier
    PROCESO_CODIGO,        -- Process code for identification
    PROCESO_NOMBRE,        -- Process name and description
    CADENA_ID,             -- Chain identifier
    CADENA_CODIGO,         -- Chain code for identification
    CADENA_DESCRIPCION,    -- Chain description and name
    COMPANIA_ID,           -- Company identifier
    COMPANIA_CODIGO,       -- Company code for identification
    COMPANIA_DESCRIPCION   -- Company name
) AS 
select procexec.id,
       procexec.process_id,
       procexec.chain_exec_id,
       procexec.start_time,
       procexec.end_time,
       procexec.comments,
       procexec.state,
       pck_batch_tools.enlapsedTimeString(procexec.start_time, procexec.end_time) tiempo_transcurrido,
       proc.id proceso_id,
       proc.code proceso_codigo,
       proc.name proceso_nombre,
       chain.id cadena_id,
       chain.code cadena_codigo,
       chain.name cadena_descripcion,
       comp.id compania_id,
       comp.code compania_codigo,
       comp.name compania_descripcion
from BATCH_PROCESS_EXECUTIONS procexec,
     BATCH_PROCESSES proc,
     BATCH_CHAIN_EXECUTIONS chainexec,
     BATCH_CHAINS chain,
     BATCH_COMPANIES comp
where ( 1 = 1 )
    and proc.id = procexec.process_id
    and chainexec.id = procexec.chain_exec_id
    and chain.id = chainexec.chain_id
    and comp.id = chain.company_id
    and procexec.state = 'RUNNING'
;
GRANT SELECT ON V_BATCH_RUNNING_PROCESSES TO ROLE_HF_BATCH;
