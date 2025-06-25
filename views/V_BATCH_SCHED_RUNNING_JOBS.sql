/**
 * View: V_BATCH_SCHED_RUNNING_JOBS
 * Description: Oracle Scheduler running jobs monitoring view.
 *              Provides real-time information about currently executing
 *              Oracle Scheduler jobs for operational monitoring and alerting.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor currently running Oracle Scheduler jobs in real-time
 *   - Provide operational visibility into active job executions
 *   - Support job execution monitoring and performance analysis
 *   - Enable real-time job status tracking and alerting
 *
 * Query Description:
 *   - Uses PCK_BATCH_MONITOR.GET_SCHED_RUNNING_JOBS function to retrieve active jobs
 *   - Provides job execution details including session information and elapsed time
 *   - Enables real-time monitoring of Oracle Scheduler job performance
 *   - Supports operational dashboards and alerting systems
 *
 * Usage Examples:
 * 
 * -- Get all currently running jobs
 * SELECT * FROM V_BATCH_SCHED_RUNNING_JOBS 
 * ORDER BY ELAPSED_TIME DESC;
 *
 * -- Get long-running jobs (> 1 hour)
 * SELECT * FROM V_BATCH_SCHED_RUNNING_JOBS 
 * WHERE ELAPSED_TIME > 3600
 * ORDER BY ELAPSED_TIME DESC;
 *
 * -- Get jobs by style
 * SELECT JOB_STYLE, COUNT(*) as running_jobs,
 *        AVG(ELAPSED_TIME) as avg_elapsed_time
 * FROM V_BATCH_SCHED_RUNNING_JOBS 
 * GROUP BY JOB_STYLE
 * ORDER BY running_jobs DESC;
 *
 * -- Get detached jobs
 * SELECT * FROM V_BATCH_SCHED_RUNNING_JOBS 
 * WHERE DETACHED = 'TRUE'
 * ORDER BY ELAPSED_TIME DESC;
 *
 * -- Get job performance summary
 * SELECT 
 *   COUNT(*) as total_running_jobs,
 *   AVG(ELAPSED_TIME) as avg_elapsed_time,
 *   MAX(ELAPSED_TIME) as max_elapsed_time,
 *   SUM(ELAPSED_TIME) as total_elapsed_time
 * FROM V_BATCH_SCHED_RUNNING_JOBS;
 *
 * -- Get potentially stuck jobs (> 2 hours)
 * SELECT * FROM V_BATCH_SCHED_RUNNING_JOBS 
 * WHERE ELAPSED_TIME > 7200
 * ORDER BY ELAPSED_TIME DESC;
 *
 * -- Get jobs by session
 * SELECT SESSION_ID, COUNT(*) as jobs_in_session,
 *        AVG(ELAPSED_TIME) as avg_session_time
 * FROM V_BATCH_SCHED_RUNNING_JOBS 
 * GROUP BY SESSION_ID
 * ORDER BY jobs_in_session DESC;
 *
 * Related Objects:
 * - Packages: PCK_BATCH_MONITOR (GET_SCHED_RUNNING_JOBS function)
 * - Types: TYP_SCHED_RUNNING_JOBS, TYP_SCHED_RUNNING_JOBS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_JOB_LOG
 * - Tables: BATCH_SCHEDULER_JOBS, BATCH_SCHED_JOB_LOG
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SCHED_RUNNING_JOBS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SCHED_RUNNING_JOBS (
    JOB_NAME,              -- Oracle Scheduler job name
    JOB_SUBNAME,           -- Job subname for complex job definitions
    JOB_STYLE,             -- Job execution style (REGULAR, LIGHTWEIGHT, etc.)
    DETACHED,              -- Whether job is running in detached mode
    SESSION_ID,            -- Database session identifier
    ELAPSED_TIME           -- Job execution elapsed time in seconds
) AS
select JOB_NAME,JOB_SUBNAME,JOB_STYLE,DETACHED,SESSION_ID,ELAPSED_TIME from table(PCK_BATCH_MONITOR.get_sched_running_jobs)
;
GRANT SELECT ON V_BATCH_SCHED_RUNNING_JOBS TO PUBLIC;
