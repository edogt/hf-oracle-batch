/**
 * View: V_BATCH_RUNNING_ACTIVITIES
 * Description: Real-time view of currently running batch activities with context.
 *              Provides immediate visibility into active activity executions
 *              including timing, chain context, and company information for operational monitoring.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor currently running activity executions in real-time
 *   - Provide operational visibility into active batch processes
 *   - Support activity execution monitoring and alerting
 *   - Enable real-time performance analysis of running activities
 *
 * Query Description:
 *   - Filters activity executions to show only RUNNING state
 *   - Joins with activities, chains, and companies for complete context
 *   - Uses PCK_BATCH_TOOLS.ENLAPSEDTIMESTRING for elapsed time calculation
 *   - Provides immediate operational visibility for monitoring dashboards
 *
 * Usage Examples:
 * 
 * -- Get all currently running activities
 * SELECT * FROM V_BATCH_RUNNING_ACTIVITIES 
 * ORDER BY START_TIME;
 *
 * -- Get running activities for a specific company
 * SELECT * FROM V_BATCH_RUNNING_ACTIVITIES 
 * WHERE COMPANIA_DESCRIPCION = 'ACME Corp'
 * ORDER BY START_TIME;
 *
 * -- Get long-running activities (> 30 minutes)
 * SELECT * FROM V_BATCH_RUNNING_ACTIVITIES 
 * WHERE START_TIME < SYSTIMESTAMP - INTERVAL '0 0:30:0' DAY TO SECOND
 * ORDER BY START_TIME;
 *
 * -- Get running activities by chain
 * SELECT CHAIN_NAME, COUNT(*) as running_activities,
 *        MIN(START_TIME) as earliest_start,
 *        MAX(START_TIME) as latest_start
 * FROM V_BATCH_RUNNING_ACTIVITIES 
 * GROUP BY CHAIN_NAME
 * ORDER BY running_activities DESC;
 *
 * -- Get activity execution summary by company
 * SELECT COMPANIA_DESCRIPCION, COUNT(*) as running_activities,
 *        AVG(EXTRACT(SECOND FROM (SYSTIMESTAMP - START_TIME))) as avg_running_seconds
 * FROM V_BATCH_RUNNING_ACTIVITIES 
 * GROUP BY COMPANIA_DESCRIPCION
 * ORDER BY running_activities DESC;
 *
 * -- Get potentially stuck activities (> 2 hours)
 * SELECT * FROM V_BATCH_RUNNING_ACTIVITIES 
 * WHERE START_TIME < SYSTIMESTAMP - INTERVAL '0 2:0:0' DAY TO SECOND
 * ORDER BY START_TIME;
 *
 * Related Objects:
 * - Tables: BATCH_ACTIVITY_EXECUTIONS, BATCH_ACTIVITIES, BATCH_CHAINS, BATCH_COMPANIES
 * - Views: V_BATCH_ACTIVITY_EXECUTIONS, V_BATCH_ACTIVS_LAST_EXECS
 * - Packages: PCK_BATCH_MGR_ACTIVITIES, PCK_BATCH_TOOLS, PCK_BATCH_MONITOR
 */

--------------------------------------------------------
--  DDL for View V_BATCH_RUNNING_ACTIVITIES
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_RUNNING_ACTIVITIES (
    ID,                    -- Unique execution identifier
    ACTIVITY_ID,           -- Reference to the activity being executed
    PROCESS_EXEC_ID,       -- Reference to parent process execution
    PROCESS_ACTIVITY_ID,   -- Reference to process-activity relationship
    EXECUTION_TYPE,        -- Type of execution (MANUAL, SCHEDULED, etc.)
    EXECUTION_STATE,       -- Current state (always 'RUNNING' for this view)
    ACTION,                -- Action being performed by the activity
    START_TIME,            -- Execution start timestamp
    END_TIME,              -- Execution end timestamp (null for running activities)
    COMMENTS,              -- Execution comments and notes
    TIEMPO_TRANSCURRIDO,   -- Calculated elapsed time (formatted string)
    ACTIVITY_CODE,         -- Activity code for identification
    ACTIVITY_NAME,         -- Activity name and description
    CHAIN_ID,              -- Chain identifier
    CHAIN_CODE,            -- Chain code for identification
    CHAIN_NAME,            -- Chain name and description
    COMPANIA_ID,           -- Company identifier
    COMPANIA_DESCRIPCION   -- Company name
) AS 
select actexec.id,
       actexec.activity_id,
       actexec.process_exec_id,
       actexec.process_activity_id,
       actexec.execution_type,
       actexec.execution_state,
       actexec.action,
       actexec.start_time,
       actexec.end_time,
       actexec.comments,
       pck_batch_tools.enlapsedTimeString(actexec.start_time, actexec.end_time) tiempo_transcurrido,
       act.code activity_code,
       act.name activity_name,
       chain.id chain_id,
       chain.code chain_code,
       chain.name chain_name,
       comp.id compania_id,
       comp.description compania_descripcion
from BATCH_ACTIVITY_EXECUTIONS actexec,
     BATCH_ACTIVITIES act,
     BATCH_CHAINS chain,
     BATCH_COMPANIES comp
where ( 1 = 1 )
    and act.id = actexec.activity_id
    and chain.id = act.chain_id
    and comp.id = chain.company_id
    and actexec.execution_state = 'RUNNING'
;
GRANT SELECT ON V_BATCH_RUNNING_ACTIVITIES TO ROLE_BATCH_MAN;
