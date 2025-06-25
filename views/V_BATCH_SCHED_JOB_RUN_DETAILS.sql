/**
 * View: V_BATCH_SCHED_JOB_RUN_DETAILS
 * Description: Oracle Scheduler job run details monitoring view.
 *              Provides detailed execution information for Oracle Scheduler jobs
 *              including timing, status, and error information for analysis and troubleshooting.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor Oracle Scheduler job execution details and history
 *   - Provide comprehensive job run information for analysis
 *   - Support job troubleshooting and error investigation
 *   - Enable job performance analysis and reporting
 *
 * Query Description:
 *   - Uses PCK_BATCH_MONITOR.GET_SCHED_JOB_RUN_DETAILS function to retrieve job details
 *   - Provides complete job execution information including errors and timing
 *   - Enables detailed analysis of job execution patterns and issues
 *   - Supports job troubleshooting and performance optimization
 *
 * Usage Examples:
 * 
 * -- Get all job run details
 * SELECT * FROM V_BATCH_SCHED_JOB_RUN_DETAILS 
 * ORDER BY START_DATE DESC;
 *
 * -- Get failed job runs
 * SELECT * FROM V_BATCH_SCHED_JOB_RUN_DETAILS 
 * WHERE STATUS = 'FAILED'
 * ORDER BY START_DATE DESC;
 *
 * -- Get job runs for specific job
 * SELECT * FROM V_BATCH_SCHED_JOB_RUN_DETAILS 
 * WHERE JOB_NAME = 'DAILY_BATCH_JOB'
 * ORDER BY START_DATE DESC;
 *
 * -- Get job performance analysis
 * SELECT JOB_NAME, COUNT(*) as total_runs,
 *        SUM(CASE WHEN STATUS = 'SUCCEEDED' THEN 1 ELSE 0 END) as successful_runs,
 *        SUM(CASE WHEN STATUS = 'FAILED' THEN 1 ELSE 0 END) as failed_runs,
 *        AVG(EXTRACT(SECOND FROM (END_DATE - START_DATE))) as avg_duration_seconds
 * FROM V_BATCH_SCHED_JOB_RUN_DETAILS 
 * GROUP BY JOB_NAME
 * ORDER BY total_runs DESC;
 *
 * -- Get recent job runs (last 24 hours)
 * SELECT * FROM V_BATCH_SCHED_JOB_RUN_DETAILS 
 * WHERE START_DATE > SYSTIMESTAMP - INTERVAL '1' DAY
 * ORDER BY START_DATE DESC;
 *
 * -- Get jobs with errors
 * SELECT * FROM V_BATCH_SCHED_JOB_RUN_DETAILS 
 * WHERE ERROR_CODE IS NOT NULL
 * ORDER BY START_DATE DESC;
 *
 * -- Get long-running jobs (> 30 minutes)
 * SELECT * FROM V_BATCH_SCHED_JOB_RUN_DETAILS 
 * WHERE (END_DATE - START_DATE) > INTERVAL '0 0:30:0' DAY TO SECOND
 * ORDER BY (END_DATE - START_DATE) DESC;
 *
 * Related Objects:
 * - Packages: PCK_BATCH_MONITOR (GET_SCHED_JOB_RUN_DETAILS function)
 * - Types: TYP_SCHED_JOB_RUN_DETAILS, TYP_SCHED_JOB_RUN_DETAILS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_JOB_LOG
 * - Tables: BATCH_SCHED_JOB_RUN_DETAILS, BATCH_SCHEDULER_JOB_LOG
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SCHED_JOB_RUN_DETAILS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SCHED_JOB_RUN_DETAILS (
    JOB_NAME,              -- Oracle Scheduler job name
    RUN_ID,                -- Unique job run identifier
    START_DATE,            -- Job execution start timestamp
    END_DATE,              -- Job execution end timestamp
    STATUS,                -- Job execution status (SUCCEEDED, FAILED, etc.)
    ERROR_CODE,            -- Error code if job failed
    ERROR_MESSAGE,         -- Error message if job failed
    ADDITIONAL_INFO        -- Additional execution information
) AS
select JOB_NAME, RUN_ID, START_DATE, END_DATE, STATUS, ERROR_CODE, ERROR_MESSAGE, ADDITIONAL_INFO 
from table(PCK_BATCH_MONITOR.get_sched_job_run_details)
;
GRANT SELECT ON V_BATCH_SCHED_JOB_RUN_DETAILS TO ROLE_BATCH_MAN;
