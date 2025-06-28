/**
 * View: V_BATCH_SCHED_RUNNING_CHAINS
 * Description: Oracle Scheduler running chains monitoring view.
 *              Provides real-time information about currently executing
 *              Oracle Scheduler chains for operational monitoring and alerting.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor currently running Oracle Scheduler chains in real-time
 *   - Provide operational visibility into active chain executions
 *   - Support chain execution monitoring and performance analysis
 *   - Enable real-time chain status tracking and alerting
 *
 * Query Description:
 *   - Uses PCK_BATCH_MONITOR.GET_SCHED_RUNNING_CHAINS function to retrieve active chains
 *   - Provides chain execution details including timing and state information
 *   - Enables real-time monitoring of Oracle Scheduler chain performance
 *   - Supports operational dashboards and alerting systems
 *
 * Usage Examples:
 * 
 * -- Get all currently running chains
 * SELECT * FROM V_BATCH_SCHED_RUNNING_CHAINS 
 * ORDER BY START_DATE;
 *
 * -- Get long-running chains (> 1 hour)
 * SELECT * FROM V_BATCH_SCHED_RUNNING_CHAINS 
 * WHERE RUN_DURATION > 3600
 * ORDER BY RUN_DURATION DESC;
 *
 * -- Get chains by state
 * SELECT STATE, COUNT(*) as running_chains,
 *        AVG(RUN_DURATION) as avg_duration
 * FROM V_BATCH_SCHED_RUNNING_CHAINS 
 * GROUP BY STATE
 * ORDER BY running_chains DESC;
 *
 * -- Get potentially stuck chains (> 4 hours)
 * SELECT * FROM V_BATCH_SCHED_RUNNING_CHAINS 
 * WHERE RUN_DURATION > 14400
 * ORDER BY RUN_DURATION DESC;
 *
 * -- Get chain performance summary
 * SELECT 
 *   COUNT(*) as total_running_chains,
 *   AVG(RUN_DURATION) as avg_duration,
 *   MAX(RUN_DURATION) as max_duration,
 *   SUM(RUN_DURATION) as total_duration
 * FROM V_BATCH_SCHED_RUNNING_CHAINS;
 *
 * -- Get chains started in the last hour
 * SELECT * FROM V_BATCH_SCHED_RUNNING_CHAINS 
 * WHERE START_DATE > SYSTIMESTAMP - INTERVAL '1' HOUR
 * ORDER BY START_DATE DESC;
 *
 * -- Get chains with specific comments
 * SELECT * FROM V_BATCH_SCHED_RUNNING_CHAINS 
 * WHERE COMMENTS IS NOT NULL
 * ORDER BY START_DATE;
 *
 * Related Objects:
 * - Packages: PCK_BATCH_MONITOR (GET_SCHED_RUNNING_CHAINS function)
 * - Types: TYP_SCHED_RUNNING_CHAINS, TYP_SCHED_RUNNING_CHAINS_SET
 * - Views: V_BATCH_SCHED_CHAINS, V_BATCH_RUNNING_CHAINS
 * - Tables: BATCH_SCHEDULER_JOBS, BATCH_SCHED_RUNNING_CHAINS
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SCHED_RUNNING_CHAINS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SCHED_RUNNING_CHAINS (
    CHAIN_NAME,            -- Oracle Scheduler chain name
    STATE,                 -- Current chain execution state
    START_DATE,            -- Chain execution start timestamp
    END_DATE,              -- Chain execution end timestamp (null if running)
    RUN_DURATION,          -- Chain execution duration in seconds
    COMMENTS               -- Chain execution comments and notes
) AS
select CHAIN_NAME, STATE, START_DATE, END_DATE, RUN_DURATION, COMMENTS 
from table(PCK_BATCH_MONITOR.get_sched_running_chains)
;
GRANT SELECT ON V_BATCH_SCHED_RUNNING_CHAINS TO ROLE_HF_BATCH;
