/**
 * View: V_BATCH_SCHED_JOBS
 * Description: Oracle Scheduler jobs information view for batch process monitoring.
 *              Provides comprehensive job scheduling information including execution status,
 *              timing, and performance metrics for Oracle Scheduler job management.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor Oracle Scheduler job status and scheduling information
 *   - Provide job execution history and performance metrics
 *   - Support job scheduling analysis and management
 *   - Enable Oracle Scheduler job monitoring and reporting
 *
 * Query Description:
 *   - Uses PCK_BATCH_MONITOR.GET_SCHED_JOBS function to retrieve Oracle Scheduler job information
 *   - Provides comprehensive job details including execution counts, failure counts, and timing
 *   - Enables monitoring of job performance and scheduling status
 *   - Supports job management and troubleshooting operations
 *
 * Usage Examples:
 * 
 * -- Get all Oracle Scheduler jobs
 * SELECT * FROM V_BATCH_SCHED_JOBS 
 * ORDER BY JOB_NAME;
 *
 * -- Get enabled jobs
 * SELECT * FROM V_BATCH_SCHED_JOBS 
 * WHERE ENABLED = 'TRUE'
 * ORDER BY JOB_NAME;
 *
 * -- Get jobs with failures
 * SELECT * FROM V_BATCH_SCHED_JOBS 
 * WHERE FAILURE_COUNT > 0
 * ORDER BY FAILURE_COUNT DESC;
 *
 * -- Get jobs that need to run soon (next 24 hours)
 * SELECT * FROM V_BATCH_SCHED_JOBS 
 * WHERE NEXT_RUN_DATE BETWEEN SYSTIMESTAMP 
 *   AND SYSTIMESTAMP + INTERVAL '1' DAY
 * ORDER BY NEXT_RUN_DATE;
 *
 * -- Get job execution summary
 * SELECT JOB_TYPE, COUNT(*) as total_jobs,
 *        SUM(RUN_COUNT) as total_runs,
 *        SUM(FAILURE_COUNT) as total_failures,
 *        AVG(RUN_COUNT) as avg_runs_per_job
 * FROM V_BATCH_SCHED_JOBS 
 * GROUP BY JOB_TYPE
 * ORDER BY total_jobs DESC;
 *
 * -- Get jobs that haven't run recently (> 7 days)
 * SELECT * FROM V_BATCH_SCHED_JOBS 
 * WHERE LAST_START_DATE < SYSTIMESTAMP - INTERVAL '7' DAY
 * OR LAST_START_DATE IS NULL
 * ORDER BY LAST_START_DATE;
 *
 * -- Get high-frequency jobs (run count > 100)
 * SELECT * FROM V_BATCH_SCHED_JOBS 
 * WHERE RUN_COUNT > 100
 * ORDER BY RUN_COUNT DESC;
 *
 * -- Get job performance analysis
 * SELECT JOB_NAME, RUN_COUNT, FAILURE_COUNT,
 *        CASE WHEN RUN_COUNT > 0 THEN 
 *          ROUND((FAILURE_COUNT / RUN_COUNT) * 100, 2) 
 *        ELSE 0 END as failure_rate_percent
 * FROM V_BATCH_SCHED_JOBS 
 * WHERE RUN_COUNT > 0
 * ORDER BY failure_rate_percent DESC;
 *
 * Related Objects:
 * - Packages: PCK_BATCH_MONITOR (GET_SCHED_JOBS function)
 * - Views: V_BATCH_SCHED_RUNNING_JOBS, V_BATCH_SCHED_JOB_LOG
 * - Types: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SCHED_JOBS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SCHED_JOBS (
    JOB_NAME,             -- Name of the Oracle Scheduler job
    JOB_TYPE,             -- Type of job (STORED_PROCEDURE, PLSQL_BLOCK, etc.)
    JOB_ACTION,           -- Action to be executed by the job
    START_DATE,           -- Job creation/start date
    REPEAT_INTERVAL,      -- Recurrence pattern for the job
    END_DATE,             -- Job end date (null if ongoing)
    ENABLED,              -- Job enabled status (TRUE/FALSE)
    STATE,                -- Current job state (SCHEDULED, RUNNING, COMPLETED, etc.)
    RUN_COUNT,            -- Total number of successful executions
    FAILURE_COUNT,        -- Total number of failed executions
    LAST_START_DATE,      -- Last execution start timestamp
    NEXT_RUN_DATE,        -- Next scheduled execution timestamp
    COMMENTS              -- Job description and comments
) AS
select JOB_NAME, JOB_TYPE, JOB_ACTION, START_DATE, REPEAT_INTERVAL, END_DATE, ENABLED, STATE, RUN_COUNT, FAILURE_COUNT, LAST_START_DATE, NEXT_RUN_DATE, COMMENTS 
from table(PCK_BATCH_MONITOR.get_sched_jobs)
;
GRANT SELECT ON V_BATCH_SCHED_JOBS TO ROLE_HF_BATCH;
