/**
 * View: V_BATCH_ACTIVS_LAST_EXECS
 * Description: Last activity executions view with hierarchical context and timing information.
 *              Provides recent activity execution history including chain relationships,
 *              process activities, and formatted timing for monitoring and analysis.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor recent activity execution history and status
 *   - Provide activity execution timing analysis and reporting
 *   - Support activity performance monitoring and trend analysis
 *   - Enable activity execution tracking with chain and process context
 *
 * Query Description:
 *   - Joins activity executions with activities, chains, process executions, and process activities
 *   - Uses outer joins to include activities not associated with chains or processes
 *   - Formats timestamps and calculates elapsed time using PCK_BATCH_TOOLS
 *   - Orders results by execution ID descending (most recent first)
 *
 * Usage Examples:
 * 
 * -- Get all recent activity executions
 * SELECT * FROM V_BATCH_ACTIVS_LAST_EXECS 
 * ORDER BY EXEC_ID DESC;
 *
 * -- Get completed activities
 * SELECT * FROM V_BATCH_ACTIVS_LAST_EXECS 
 * WHERE EXECUTION_STATE = 'COMPLETED'
 * ORDER BY EXEC_ID DESC;
 *
 * -- Get activities for a specific chain
 * SELECT * FROM V_BATCH_ACTIVS_LAST_EXECS 
 * WHERE CHAIN = 'DAILY_BATCH_CHAIN'
 * ORDER BY START_TIME DESC;
 *
 * -- Get long-running activities (> 30 minutes)
 * SELECT * FROM V_BATCH_ACTIVS_LAST_EXECS 
 * WHERE EXECUTION_STATE = 'RUNNING'
 * AND START_TIME < SYSTIMESTAMP - INTERVAL '0 0:30:0' DAY TO SECOND
 * ORDER BY START_TIME;
 *
 * -- Get activity execution summary by chain
 * SELECT CHAIN, COUNT(*) as total_executions,
 *        SUM(CASE WHEN EXECUTION_STATE = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
 *        SUM(CASE WHEN EXECUTION_STATE = 'FAILED' THEN 1 ELSE 0 END) as failed
 * FROM V_BATCH_ACTIVS_LAST_EXECS 
 * WHERE CHAIN IS NOT NULL
 * GROUP BY CHAIN
 * ORDER BY total_executions DESC;
 *
 * -- Get recent executions for a specific activity
 * SELECT * FROM V_BATCH_ACTIVS_LAST_EXECS 
 * WHERE CODE = 'DATA_EXTRACTION'
 * ORDER BY EXEC_ID DESC;
 *
 * -- Get failed activities with details
 * SELECT * FROM V_BATCH_ACTIVS_LAST_EXECS 
 * WHERE EXECUTION_STATE = 'FAILED'
 * ORDER BY START_TIME DESC;
 *
 * Related Objects:
 * - Tables: BATCH_ACTIVITY_EXECUTIONS, BATCH_ACTIVITIES, BATCH_CHAINS
 * - Tables: BATCH_PROCESS_EXECUTIONS, BATCH_CHAIN_EXECUTIONS, BATCH_PROCESS_ACTIVITIES
 * - Views: V_BATCH_ACTIVITY_EXECUTIONS, V_BATCH_RUNNING_ACTIVITIES
 * - Packages: PCK_BATCH_MGR_ACTIVITIES, PCK_BATCH_TOOLS, PCK_BATCH_MONITOR
 */

--------------------------------------------------------
--  DDL for View V_BATCH_ACTIVS_LAST_EXECS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_ACTIVS_LAST_EXECS (
    EXEC_ID,              -- Unique execution identifier
    CHAIN,                -- Chain code for identification
    CODE,                 -- Activity code for identification
    ACTIVITY_NAME,        -- Activity name with optional process activity context
    EXECUTION_TYPE,       -- Type of execution (MANUAL, SCHEDULED, etc.)
    EXECUTION_STATE,      -- Current execution state (RUNNING, COMPLETED, FAILED, etc.)
    ACTION,               -- Action being performed by the activity
    START_TIME,           -- Formatted execution start timestamp
    END_TIME,             -- Formatted execution end timestamp
    ENLAPSED_TIME         -- Calculated elapsed time (formatted string)
  ) AS
  select actexec.id exec_id,
         chain.code chain,
         activ.code CODE,
         activ.name || decode(procactiv.name, null, null, ' (' || procactiv.name || ')') activity_name,
         actexec.execution_type execution_type,
         actexec.execution_state execution_state,
         activ.action action,
         to_char(actexec.start_time,'dd/mm/yyyy hh:mi:ss') start_time,
         to_char(actexec.end_time,'dd/mm/yyyy hh:mi:ss') end_time,
         pck_batch_tools.enlapsedTimeString(actexec.start_time, actexec.end_time) enlapsed_time
    from BATCH_ACTIVITY_EXECUTIONS actexec,
            BATCH_ACTIVITIES activ,
            batch_chains chain,
            batch_process_executions procexec,
            batch_chain_executions chainexec,
            batch_process_activities procactiv
    where ( 1 = 1 )
        and chain.id (+) = chainexec.chain_id
        and chainexec.id (+) = procexec.chain_exec_id
        and procexec.id (+) = actexec.process_exec_id
        and activ.id = actexec.activity_id
        and procactiv.id (+) = actexec.process_activity_id
    order by 1 desc

;
  GRANT SELECT ON V_BATCH_ACTIVS_LAST_EXECS TO ROLE_BATCH_MAN;
