/**
 * View: V_BATCH_SCHED_JOB_LOG
 * Description: Oracle Scheduler job log monitoring view.
 *              Provides access to execution logs for Oracle Scheduler jobs
 *              including status, timestamps, and additional information for auditing and troubleshooting.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor Oracle Scheduler job execution logs
 *   - Provide job status and log information for auditing
 *   - Support troubleshooting and historical analysis
 *   - Enable job execution tracking and reporting
 *
 * Query Description:
 *   - Uses PCK_BATCH_MONITOR.GET_SCHED_JOB_LOG function to retrieve job logs
 *   - Provides job log details including status and timestamps
 *   - Enables auditing and troubleshooting of job executions
 *   - Supports historical job execution analysis
 *
 * Usage Examples:
 * 
 * -- Get all job logs
 * SELECT * FROM V_BATCH_SCHED_JOB_LOG 
 * ORDER BY LOG_DATE DESC;
 *
 * -- Get logs for failed jobs
 * SELECT * FROM V_BATCH_SCHED_JOB_LOG 
 * WHERE STATUS = 'FAILED'
 * ORDER BY LOG_DATE DESC;
 *
 * -- Get logs for a specific job
 * SELECT * FROM V_BATCH_SCHED_JOB_LOG 
 * WHERE JOB_NAME = 'DAILY_BATCH_JOB'
 * ORDER BY LOG_DATE DESC;
 *
 * -- Get job log summary by status
 * SELECT STATUS, COUNT(*) as log_count,
 *        MAX(LOG_DATE) as last_log
 * FROM V_BATCH_SCHED_JOB_LOG 
 * GROUP BY STATUS
 * ORDER BY log_count DESC;
 *
 * -- Get recent job logs (last 7 days)
 * SELECT * FROM V_BATCH_SCHED_JOB_LOG 
 * WHERE LOG_DATE > SYSTIMESTAMP - INTERVAL '7' DAY
 * ORDER BY LOG_DATE DESC;
 *
 * -- Get logs with additional info
 * SELECT * FROM V_BATCH_SCHED_JOB_LOG 
 * WHERE ADDITIONAL_INFO IS NOT NULL
 * ORDER BY LOG_DATE DESC;
 *
 * Related Objects:
 * - Packages: PCK_BATCH_MONITOR (GET_SCHED_JOB_LOG function)
 * - Types: TYP_SCHED_JOB_LOG, TYP_SCHED_JOB_LOG_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_JOB_RUN_DETAILS
 * - Tables: BATCH_SCHED_JOB_LOG, BATCH_SCHEDULER_JOB_LOG
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SCHED_JOB_LOG
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SCHED_JOB_LOG (
    JOB_NAME,              -- Oracle Scheduler job name
    LOG_ID,                -- Unique log entry identifier
    LOG_DATE,              -- Log entry timestamp
    STATUS,                -- Job execution status (SUCCEEDED, FAILED, etc.)
    ADDITIONAL_INFO        -- Additional log information
) AS
select JOB_NAME, LOG_ID, LOG_DATE, STATUS, ADDITIONAL_INFO 
from table(PCK_BATCH_MONITOR.get_sched_job_log)
;
GRANT SELECT ON V_BATCH_SCHED_JOB_LOG TO ROLE_BATCH_MAN;
