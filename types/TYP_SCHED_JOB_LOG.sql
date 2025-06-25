/**
 * Type: TYP_SCHED_JOB_LOG
 * Description: Oracle Scheduler job log entry type for batch process execution history.
 *              Represents individual log entries that track job execution events,
 *              status changes, and error information for audit and troubleshooting.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler job log entry structures
 *   - Support job execution history tracking and audit
 *   - Enable job status monitoring and error analysis
 *   - Provide execution event logging and troubleshooting
 *
 * Usage Examples:
 * 
 * -- Create a job log entry
 * DECLARE
 *   v_log TYP_SCHED_JOB_LOG;
 * BEGIN
 *   v_log := TYP_SCHED_JOB_LOG(
 *     log_id => 12345,
 *     log_date => SYSTIMESTAMP,
 *     owner => 'BATCH_MAN',
 *     job_name => 'DAILY_DATA_PROCESSING',
 *     job_subname => 'EXTRACT_PHASE',
 *     operation => 'RUN',
 *     status => 'SUCCEEDED',
 *     user_name => 'BATCH_USER',
 *     additional_info => 'Processed 15000 records successfully'
 *   );
 * END;
 *
 * -- Use with collection type for multiple log entries
 * DECLARE
 *   v_logs TYP_SCHED_JOB_LOG_SET;
 * BEGIN
 *   v_logs := TYP_SCHED_JOB_LOG_SET();
 *   v_logs.EXTEND;
 *   v_logs(v_logs.LAST) := TYP_SCHED_JOB_LOG(
 *     12346, SYSTIMESTAMP, 'BATCH_MAN', 'WEEKLY_REPORT_JOB', 'VALIDATION_PHASE',
 *     'RUN', 'FAILED', 'BATCH_USER', 'Validation failed: Invalid data format'
 *   );
 * END;
 *
 * Related Objects:
 * - Collection: TYP_SCHED_JOB_LOG_SET
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Destinations: TYP_SCHED_JOB_DESTS, TYP_SCHED_JOB_DESTS_SET
 * - Details: TYP_SCHED_JOB_RUN_DETAILS, TYP_SCHED_JOB_RUN_DETAILS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_RUNNING_JOBS
 */

  CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_JOB_LOG as object (
    log_id             number,                        -- Unique log entry identifier
    log_date           timestamp(6) with time zone,   -- Timestamp when the log entry was created
    owner              varchar2(128),                 -- Owner of the job that generated this log
    job_name           varchar2(128),                 -- Name of the job that generated this log
    job_subname        varchar2(128),                 -- Subname of the job for identification
    operation          varchar2(19),                  -- Operation performed (RUN, STOP, DROP, etc.)
    status             varchar2(19),                  -- Status of the operation (SUCCEEDED, FAILED, etc.)
    user_name          varchar2(128),                 -- User who performed the operation
    additional_info    varchar2(4000)                 -- Additional information about the operation
)

/
