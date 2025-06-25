/**
 * View: V_BATCH_CHAIN_LAST_EXECS_VIEW
 * Description: Formatted view of chain executions with readable timestamps.
 *              Provides chain execution information with formatted dates and
 *              elapsed time calculations for reporting and monitoring purposes.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Display chain executions with formatted timestamps for readability
 *   - Provide chain execution history with elapsed time calculations
 *   - Support chain execution reporting and analysis
 *   - Enable user-friendly chain execution monitoring
 *
 * Query Description:
 *   - Joins BATCH_CHAIN_EXECUTIONS with BATCH_CHAINS for complete context
 *   - Formats timestamps using TO_CHAR for human-readable display
 *   - Uses PCK_BATCH_TOOLS.ENLAPSEDTIMESTRING for elapsed time calculation
 *   - Provides all chain executions regardless of state for historical analysis
 *
 * Usage Examples:
 * 
 * -- Get all chain executions with formatted timestamps
 * SELECT * FROM V_BATCH_CHAIN_LAST_EXECS_VIEW 
 * ORDER BY START_TIME DESC;
 *
 * -- Get recent chain executions (last 7 days)
 * SELECT * FROM V_BATCH_CHAIN_LAST_EXECS_VIEW 
 * WHERE START_TIME > TO_CHAR(SYSTIMESTAMP - INTERVAL '7' DAY, 'dd/mm/yyyy hh:mi:ss')
 * ORDER BY START_TIME DESC;
 *
 * -- Get completed chain executions
 * SELECT * FROM V_BATCH_CHAIN_LAST_EXECS_VIEW 
 * WHERE EXECUTION_STATE = 'COMPLETED'
 * ORDER BY START_TIME DESC;
 *
 * -- Get chain execution summary by chain
 * SELECT CHAIN_CODE, CHAIN_NAME, COUNT(*) as execution_count,
 *        MAX(START_TIME) as last_execution
 * FROM V_BATCH_CHAIN_LAST_EXECS_VIEW 
 * GROUP BY CHAIN_CODE, CHAIN_NAME
 * ORDER BY execution_count DESC;
 *
 * -- Get long-running chain executions (> 1 hour)
 * SELECT * FROM V_BATCH_CHAIN_LAST_EXECS_VIEW 
 * WHERE ENLAPSED_TIME LIKE '%hora%'
 * ORDER BY START_TIME DESC;
 *
 * -- Get chain executions by type
 * SELECT EXECUTION_TYPE, COUNT(*) as execution_count,
 *        COUNT(DISTINCT CHAIN_CODE) as unique_chains
 * FROM V_BATCH_CHAIN_LAST_EXECS_VIEW 
 * GROUP BY EXECUTION_TYPE
 * ORDER BY execution_count DESC;
 *
 * Related Objects:
 * - Tables: BATCH_CHAIN_EXECUTIONS, BATCH_CHAINS
 * - Views: V_BATCH_CHAIN_EXECUTIONS, V_BATCH_RUNNING_CHAINS
 * - Packages: PCK_BATCH_MGR_CHAINS, PCK_BATCH_TOOLS
 * - Types: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 */

--------------------------------------------------------
--  DDL for View V_BATCH_CHAIN_LAST_EXECS_VIEW
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_CHAIN_LAST_EXECS_VIEW (
    EXEC_ID,               -- Unique execution identifier
    CHAIN_CODE,            -- Chain code for identification
    CHAIN_NAME,            -- Chain name and description
    EXECUTION_TYPE,        -- Type of execution (MANUAL, SCHEDULED, etc.)
    EXECUTION_STATE,       -- Current execution state
    START_TIME,            -- Formatted execution start time (dd/mm/yyyy hh:mi:ss)
    END_TIME,              -- Formatted execution end time (dd/mm/yyyy hh:mi:ss)
    ENLAPSED_TIME          -- Calculated elapsed time (formatted string)
) AS
select chainexec.id exec_id,
       chain.code chain_code,
       chain.name chain_name,
       chainexec.execution_type execution_type,
       chainexec.state execution_state,
       to_char(chainexec.start_time,'dd/mm/yyyy hh:mi:ss') start_time,
       to_char(chainexec.end_time,'dd/mm/yyyy hh:mi:ss') end_time,
       pck_batch_tools.enlapsedTimeString(chainexec.start_time, chainexec.end_time) enlapsed_time
from BATCH_CHAIN_EXECUTIONS chainexec,
     BATCH_CHAINS chain
where ( 1 = 1 )
    and chain.id = chainexec.chain_id
;
GRANT SELECT ON V_BATCH_CHAIN_LAST_EXECS_VIEW TO ROLE_BATCH_MAN;
