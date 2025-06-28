/**
 * Type: TYP_SCHED_JOB_LOG
 * Description: Oracle Scheduler job log type for batch process execution tracking.
 *              Represents job execution log entries with status, timing, and
 *              error information for operational monitoring and troubleshooting.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler job log structures
 *   - Support job execution history and audit trails
 *   - Enable error tracking and troubleshooting
 *   - Provide operational visibility into job execution patterns
 *
 * Usage Examples:
 * 
 * -- Create a job log entry
 * DECLARE
 *   v_log TYP_SCHED_JOB_LOG;
 * BEGIN
 *   v_log := TYP_SCHED_JOB_LOG(
 *     owner => 'HF_BATCH',
 *     job_name => 'DAILY_DATA_PROCESSING',
 *     job_subname => 'EXTRACT_PHASE',
 *     status => 'SUCCEEDED',
 *     error_code => null,
 *     req_start_date => SYSTIMESTAMP - INTERVAL '0 0:30:0' DAY TO SECOND,
 *     actual_start_date => SYSTIMESTAMP - INTERVAL '0 0:30:0' DAY TO SECOND,
 *     run_duration => INTERVAL '0 0:25:30.5' DAY TO SECOND,
 *     additional_info => 'CPU: 15%, Memory: 256MB, Records: 15000'
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
 *     12346, SYSTIMESTAMP, 'HF_BATCH', 'WEEKLY_REPORT_JOB', 'VALIDATION_PHASE',
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
