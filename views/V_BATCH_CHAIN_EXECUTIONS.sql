/**
 * View: V_BATCH_CHAIN_EXECUTIONS
 * Description: Comprehensive view of batch chain executions with company context.
 *              Provides complete chain execution information including timing, status,
 *              and company ownership for monitoring and analysis of workflow execution.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor chain execution status and performance
 *   - Provide chain execution history and timing analysis
 *   - Support chain execution tracking across companies
 *   - Enable workflow execution monitoring and reporting
 *
 * Query Description:
 *   - Joins chain executions with chains and companies to provide complete context
 *   - Uses PCK_BATCH_TOOLS.ENLAPSEDTIMESTRING for formatted elapsed time calculation
 *   - Provides execution type and state information for analysis
 *   - Enables chain execution performance monitoring and reporting
 *
 * Usage Examples:
 * 
 * -- Get all running chain executions
 * SELECT * FROM V_BATCH_CHAIN_EXECUTIONS 
 * WHERE STATE = 'RUNNING';
 *
 * -- Get chain executions for a specific company
 * SELECT * FROM V_BATCH_CHAIN_EXECUTIONS 
 * WHERE COMPANIA_DESCRIPCION = 'ACME Corp'
 * ORDER BY START_TIME DESC;
 *
 * -- Get long-running chains (> 2 hours)
 * SELECT * FROM V_BATCH_CHAIN_EXECUTIONS 
 * WHERE STATE = 'RUNNING' 
 * AND START_TIME < SYSTIMESTAMP - INTERVAL '0 2:0:0' DAY TO SECOND;
 *
 * -- Get chain execution summary by company
 * SELECT COMPANIA_DESCRIPCION, COUNT(*) as total_executions,
 *        SUM(CASE WHEN STATE = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
 *        SUM(CASE WHEN STATE = 'FAILED' THEN 1 ELSE 0 END) as failed,
 *        AVG(EXTRACT(SECOND FROM (END_TIME - START_TIME))) as avg_duration_seconds
 * FROM V_BATCH_CHAIN_EXECUTIONS 
 * WHERE END_TIME IS NOT NULL
 * GROUP BY COMPANIA_DESCRIPCION;
 *
 * -- Get chain performance analysis
 * SELECT CADENA_DESCRIPCION, COUNT(*) as execution_count,
 *        AVG(EXTRACT(SECOND FROM (END_TIME - START_TIME))) as avg_duration_seconds,
 *        MIN(EXTRACT(SECOND FROM (END_TIME - START_TIME))) as min_duration_seconds,
 *        MAX(EXTRACT(SECOND FROM (END_TIME - START_TIME))) as max_duration_seconds
 * FROM V_BATCH_CHAIN_EXECUTIONS 
 * WHERE END_TIME IS NOT NULL
 * GROUP BY CADENA_DESCRIPCION
 * ORDER BY avg_duration_seconds DESC;
 *
 * -- Get recent chain executions (last 24 hours)
 * SELECT * FROM V_BATCH_CHAIN_EXECUTIONS 
 * WHERE START_TIME > SYSTIMESTAMP - INTERVAL '1' DAY
 * ORDER BY START_TIME DESC;
 *
 * Related Objects:
 * - Tables: BATCH_CHAIN_EXECUTIONS, BATCH_CHAINS, BATCH_COMPANIES
 * - Views: V_BATCH_CHAIN_LAST_EXECS_VIEW, V_BATCH_SCHED_RUNNING_CHAINS
 * - Packages: PCK_BATCH_MGR_CHAINS, PCK_BATCH_TOOLS, PCK_BATCH_MONITOR
 */

--------------------------------------------------------
--  DDL for View V_BATCH_CHAIN_EXECUTIONS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_CHAIN_EXECUTIONS (
    ID,                    -- Unique execution identifier
    START_TIME,            -- Execution start timestamp
    END_TIME,              -- Execution end timestamp (null if running)
    COMMENTS,              -- Execution comments and notes
    STATE,                 -- Current execution state (RUNNING, COMPLETED, FAILED, etc.)
    CHAIN_ID,              -- Reference to the chain being executed
    EXECUTION_TYPE,        -- Type of execution (MANUAL, SCHEDULED, etc.)
    TIEMPO_TRANSCURRIDO,   -- Calculated elapsed time (formatted string)
    CADENA_CODIGO,         -- Chain code for identification
    CADENA_DESCRIPCION,    -- Chain description and name
    COMPANIA_ID,           -- Company identifier
    COMPANIA_DESCRIPCION   -- Company name
) AS
select chainexec.id,
       chainexec.start_time,
       chainexec.end_time,
       chainexec.comments,
       chainexec.state,
       chainexec.chain_id,
       chainexec.execution_type,
       pck_batch_tools.enlapsedTimeString(chainexec.start_time, chainexec.end_time) tiempo_transcurrido,
       chain.code cadena_codigo,
       chain.name cadena_descripcion,
       comp.id compania_id,
       comp.description compania_descripcion
from BATCH_CHAIN_EXECUTIONS chainexec,
     BATCH_CHAINS chain,
     BATCH_COMPANIES comp
where ( 1 = 1 )
    and chain.id = chainexec.chain_id
    and comp.id = chain.company_id
;
GRANT SELECT ON V_BATCH_CHAIN_EXECUTIONS TO ROLE_HF_BATCH;
