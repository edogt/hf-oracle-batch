/**
 * View: V_BATCH_PROCESS_EXECUTIONS
 * Description: Comprehensive view of batch process executions with hierarchical context.
 *              Provides complete process execution information including timing, status,
 *              and relationships to chains and companies for monitoring and analysis.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor process execution status and performance
 *   - Provide hierarchical view of process-chain-company relationships
 *   - Support execution time analysis and reporting
 *   - Enable process execution tracking across companies
 *
 * Query Description:
 *   - Joins process executions with processes, chain executions, chains, and companies
 *   - Uses PCK_BATCH_TOOLS.ENLAPSEDTIMESTRING for formatted elapsed time calculation
 *   - Provides complete context for each process execution
 *   - Enables analysis of process performance and execution patterns
 *
 * Usage Examples:
 * 
 * -- Get all running process executions
 * SELECT * FROM V_BATCH_PROCESS_EXECUTIONS 
 * WHERE STATE = 'RUNNING';
 *
 * -- Get process executions for a specific company
 * SELECT * FROM V_BATCH_PROCESS_EXECUTIONS 
 * WHERE COMPANIA_DESCRIPCION = 'ACME Corp'
 * ORDER BY START_TIME DESC;
 *
 * -- Get long-running processes (> 1 hour)
 * SELECT * FROM V_BATCH_PROCESS_EXECUTIONS 
 * WHERE STATE = 'RUNNING' 
 * AND START_TIME < SYSTIMESTAMP - INTERVAL '0 1:0:0' DAY TO SECOND;
 *
 * -- Get process execution summary by company
 * SELECT COMPANIA_DESCRIPCION, COUNT(*) as total_executions,
 *        SUM(CASE WHEN STATE = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
 *        SUM(CASE WHEN STATE = 'FAILED' THEN 1 ELSE 0 END) as failed,
 *        AVG(EXTRACT(SECOND FROM (END_TIME - START_TIME))) as avg_duration_seconds
 * FROM V_BATCH_PROCESS_EXECUTIONS 
 * WHERE END_TIME IS NOT NULL
 * GROUP BY COMPANIA_DESCRIPCION;
 *
 * -- Get processes by chain
 * SELECT CADENA_DESCRIPCION, PROCESO_NOMBRE, COUNT(*) as execution_count,
 *        AVG(EXTRACT(SECOND FROM (END_TIME - START_TIME))) as avg_duration_seconds
 * FROM V_BATCH_PROCESS_EXECUTIONS 
 * WHERE END_TIME IS NOT NULL
 * GROUP BY CADENA_DESCRIPCION, PROCESO_NOMBRE
 * ORDER BY CADENA_DESCRIPCION, avg_duration_seconds DESC;
 *
 * Related Objects:
 * - Tables: BATCH_PROCESS_EXECUTIONS, BATCH_PROCESSES, BATCH_CHAIN_EXECUTIONS
 * - Tables: BATCH_CHAINS, BATCH_COMPANIES
 * - Views: V_BATCH_PROCS_LAST_EXECS, V_BATCH_RUNNING_PROCESSES
 * - Packages: PCK_BATCH_MGR_PROCESSES, PCK_BATCH_TOOLS, PCK_BATCH_MONITOR
 */

--------------------------------------------------------
--  DDL for View V_BATCH_PROCESS_EXECUTIONS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_PROCESS_EXECUTIONS (
    ID,                    -- Unique execution identifier
    PROCESS_ID,            -- Reference to the process being executed
    CHAIN_EXEC_ID,         -- Reference to parent chain execution
    START_TIME,            -- Execution start timestamp
    END_TIME,              -- Execution end timestamp (null if running)
    COMMENTS,              -- Execution comments and notes
    STATE,                 -- Current execution state (RUNNING, COMPLETED, FAILED, etc.)
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
;
GRANT SELECT ON V_BATCH_PROCESS_EXECUTIONS TO ROLE_BATCH_MAN;
