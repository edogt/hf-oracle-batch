/**
 * Type: TYP_SCHED_JOB_RUN_DETAILS
 * Description: Oracle Scheduler job run details type for batch process execution metrics.
 *              Represents detailed execution information including timing, resource usage,
 *              and performance metrics for job execution analysis and optimization.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler job run detail structures
 *   - Support job execution performance analysis and monitoring
 *   - Enable resource usage tracking and optimization
 *   - Provide detailed execution metrics for capacity planning
 *
 * Usage Examples:
 * 
 * -- Create a job run details entry
 * DECLARE
 *   v_details TYP_SCHED_JOB_RUN_DETAILS;
 * BEGIN
 *   v_details := TYP_SCHED_JOB_RUN_DETAILS(
 *     log_id => 12345,
 *     log_date => SYSTIMESTAMP,
 *     owner => 'BATCH_MAN',
 *     job_name => 'DAILY_DATA_PROCESSING',
 *     job_subname => 'EXTRACT_PHASE',
 *     status => 'SUCCEEDED',
 *     error# => null,
 *     req_start_date => SYSTIMESTAMP - INTERVAL '0 0:30:0' DAY TO SECOND,
 *     actual_start_date => SYSTIMESTAMP - INTERVAL '0 0:30:0' DAY TO SECOND,
 *     run_duration => INTERVAL '0 0:25:30.5' DAY TO SECOND,
 *     additional_info => 'CPU: 15%, Memory: 256MB, Records: 15000'
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
 *     12346, SYSTIMESTAMP, 'BATCH_MAN', 'WEEKLY_REPORT_JOB', 'VALIDATION_PHASE',
 *     'FAILED', 20001, SYSTIMESTAMP - INTERVAL '0 0:15:0' DAY TO SECOND,
 *     SYSTIMESTAMP - INTERVAL '0 0:15:0' DAY TO SECOND,
 *     INTERVAL '0 0:12:45.2' DAY TO SECOND,
 *     'Error: ORA-20001 - Invalid data format detected'
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
