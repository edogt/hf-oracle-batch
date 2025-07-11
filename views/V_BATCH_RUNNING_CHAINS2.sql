/**
 * View: V_BATCH_RUNNING_CHAINS2
 * Description: Alternative view for currently running batch chains with company context.
 *              Provides an alternative implementation for monitoring active chain executions
 *              with timing and company information for operational monitoring.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Provide alternative monitoring of currently running chain executions
 *   - Support operational visibility into active workflow processes
 *   - Enable real-time performance analysis of running chains
 *   - Provide backup monitoring view for chain execution tracking
 *
 * Query Description:
 *   - Filters chain executions to show only RUNNING state
 *   - Joins with chains and companies to provide complete context
 *   - Uses PCK_BATCH_TOOLS.ENLAPSEDTIMESTRING for elapsed time calculation
 *   - Alternative implementation to V_BATCH_RUNNING_CHAINS for redundancy
 *
 * Usage Examples:
 * 
 * -- Get all currently running chains (alternative view)
 * SELECT * FROM V_BATCH_RUNNING_CHAINS2 
 * ORDER BY START_TIME;
 *
 * -- Get running chains for a specific company
 * SELECT * FROM V_BATCH_RUNNING_CHAINS2 
 * WHERE COMPANIA_DESCRIPCION = 'ACME Corp'
 * ORDER BY START_TIME;
 *
 * -- Get long-running chains (> 2 hours)
 * SELECT * FROM V_BATCH_RUNNING_CHAINS2 
 * WHERE START_TIME < SYSTIMESTAMP - INTERVAL '0 2:0:0' DAY TO SECOND
 * ORDER BY START_TIME;
 *
 * -- Get chain execution summary by company
 * SELECT COMPANIA_DESCRIPCION, COUNT(*) as running_chains,
 *        AVG(EXTRACT(SECOND FROM (SYSTIMESTAMP - START_TIME))) as avg_running_seconds
 * FROM V_BATCH_RUNNING_CHAINS2 
 * GROUP BY COMPANIA_DESCRIPCION
 * ORDER BY running_chains DESC;
 *
 * -- Get chains by execution type
 * SELECT EXECUTION_TYPE, COUNT(*) as running_chains,
 *        MIN(START_TIME) as earliest_start,
 *        MAX(START_TIME) as latest_start
 * FROM V_BATCH_RUNNING_CHAINS2 
 * GROUP BY EXECUTION_TYPE
 * ORDER BY running_chains DESC;
 *
 * Related Objects:
 * - Tables: BATCH_CHAIN_EXECUTIONS, BATCH_CHAINS, BATCH_COMPANIES
 * - Views: V_BATCH_RUNNING_CHAINS (primary view), V_BATCH_CHAIN_EXECUTIONS
 * - Packages: PCK_BATCH_MGR_CHAINS, PCK_BATCH_TOOLS, PCK_BATCH_MONITOR
 */

--------------------------------------------------------
--  DDL for View V_BATCH_RUNNING_CHAINS2
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_RUNNING_CHAINS2 (
    ID,                    -- Unique execution identifier
    START_TIME,            -- Execution start timestamp
    END_TIME,              -- Execution end timestamp (null for running chains)
    COMMENTS,              -- Execution comments and notes
    STATE,                 -- Current state (always 'RUNNING' for this view)
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
    and chainexec.state = 'RUNNING'
;
GRANT SELECT ON V_BATCH_RUNNING_CHAINS2 TO ROLE_HF_BATCH;
