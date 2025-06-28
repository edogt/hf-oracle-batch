/**
 * Type: TYP_SCHED_JOB_RUN_DETAILS
 * Description: Oracle Scheduler job run details type for batch process execution monitoring.
 *              Provides detailed information about job execution instances including
 *              timing, status, errors, and performance metrics for operational analysis.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler job run detail structures
 *   - Support detailed job execution analysis and monitoring
 *   - Enable performance tracking and error analysis
 *   - Provide comprehensive execution history for batch jobs
 *
 * Usage Examples:
 * 
 * -- Create a job run detail entry
 * DECLARE
 *   v_detail TYP_SCHED_JOB_RUN_DETAILS;
 * BEGIN
 *   v_detail := TYP_SCHED_JOB_RUN_DETAILS(
 *     owner => 'HF_BATCH',
 *     job_name => 'DAILY_DATA_PROCESSING',
 *     job_subname => 'EXTRACT_PHASE',
 *     state => 'COMPLETED',
 *     error_code => null,
 *     start_date => SYSTIMESTAMP - INTERVAL '0 0:45:0' DAY TO SECOND,
 *     end_date => SYSTIMESTAMP - INTERVAL '0 0:15:0' DAY TO SECOND,
 *     run_duration => INTERVAL '0 0:30:0' DAY TO SECOND,
 *     session_id => 12345,
 *     slave_process_id => 67890,
 *     cpu_used => 28.5,
 *     additional_info => 'Successfully processed 15000 records',
 *     priority => 'NORMAL'
 *   );
 * END;
 *
 * -- Use with collection type for multiple run details
 * DECLARE
 *   v_details_list TYP_SCHED_JOB_RUN_DETAILS_SET;
 * BEGIN
 *   v_details_list := TYP_SCHED_JOB_RUN_DETAILS_SET();
 *   v_details_list.EXTEND;
 *   v_details_list(v_details_list.LAST) := TYP_SCHED_JOB_RUN_DETAILS(
 *     12346, SYSTIMESTAMP, 'HF_BATCH', 'WEEKLY_REPORT_JOB', 'VALIDATION_PHASE',
 *     'RUNNING', SYSTIMESTAMP - INTERVAL '0 0:30:0' DAY TO SECOND, null,
 *     INTERVAL '0 0:30:0' DAY TO SECOND, 12346, 67891, 22.8,
 *     'Validating data set 3 of 5 (60% complete)', 'NORMAL'
 *   );
 * END;
 *
 * Related Objects:
 * - Collection: TYP_SCHED_JOB_RUN_DETAILS_SET
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Logs: TYP_SCHED_JOB_LOG, TYP_SCHED_JOB_LOG_SET
 * - Destinations: TYP_SCHED_JOB_DESTS, TYP_SCHED_JOB_DESTS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_RUNNING_JOBS
 */

  CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_JOB_RUN_DETAILS as object (
    log_id             number,                        -- Unique log entry identifier
    log_date           timestamp(6) with time zone,   -- Timestamp when the run details were recorded
    owner              varchar2(128),                 -- Owner of the job that generated these details
    job_name           varchar2(128),                 -- Name of the job that generated these details
    job_subname        varchar2(128),                 -- Subname of the job for identification
    status             varchar2(19),                  -- Status of the job execution (SUCCEEDED, FAILED, etc.)
    error#             number,                        -- Oracle error number if execution failed
    req_start_date     timestamp(6) with time zone,   -- Requested start date/time for the job
    actual_start_date  timestamp(6) with time zone,   -- Actual start date/time when job began execution
    run_duration       interval day(9) to second(6),  -- Total duration of the job execution
    additional_info    varchar2(4000)                 -- Additional execution information and metrics
)

/
