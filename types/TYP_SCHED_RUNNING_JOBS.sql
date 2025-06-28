/**
 * Type: TYP_SCHED_RUNNING_JOBS
 * Description: Oracle Scheduler running job status type for batch process execution monitoring.
 *              Represents active job execution instances with real-time status information,
 *              progress tracking, and execution metrics for operational monitoring.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler running job status structures
 *   - Support real-time job execution monitoring and tracking
 *   - Enable job progress analysis and performance monitoring
 *   - Provide operational visibility into active batch jobs
 *
 * Usage Examples:
 * 
 * -- Create a running job status entry
 * DECLARE
 *   v_running TYP_SCHED_RUNNING_JOBS;
 * BEGIN
 *   v_running := TYP_SCHED_RUNNING_JOBS(
 *     owner => 'HF_BATCH',
 *     job_name => 'DAILY_DATA_PROCESSING',
 *     job_subname => 'EXTRACT_PHASE',
 *     state => 'RUNNING',
 *     start_date => SYSTIMESTAMP - INTERVAL '0 0:20:0' DAY TO SECOND,
 *     end_date => null,
 *     run_duration => INTERVAL '0 0:20:0' DAY TO SECOND,
 *     session_id => 12345,
 *     slave_process_id => 67890,
 *     cpu_used => 30.2,
 *     additional_info => 'Processing record 12500 of 15000 (83% complete)'
 *   );
 * END;
 *
 * -- Use with collection type for multiple running jobs
 * DECLARE
 *   v_running_list TYP_SCHED_RUNNING_JOBS_SET;
 * BEGIN
 *   v_running_list := TYP_SCHED_RUNNING_JOBS_SET();
 *   v_running_list.EXTEND;
 *   v_running_list(v_running_list.LAST) := TYP_SCHED_RUNNING_JOBS(
 *     'HF_BATCH', 'WEEKLY_REPORT_JOB', 'VALIDATION_PHASE', 'RUNNING',
 *     SYSTIMESTAMP - INTERVAL '0 0:45:0' DAY TO SECOND, null,
 *     INTERVAL '0 0:45:0' DAY TO SECOND, 12346, 67891, 22.8,
 *     'Validating data set 3 of 5 (60% complete)'
 *   );
 * END;
 *
 * Related Objects:
 * - Collection: TYP_SCHED_RUNNING_JOBS_SET
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Programs: TYP_SCHED_PROGRAMS, TYP_SCHED_PROGRAMS_SET
 * - Destinations: TYP_SCHED_JOB_DESTS, TYP_SCHED_JOB_DESTS_SET
 * - Views: V_BATCH_SCHED_RUNNING_JOBS, V_BATCH_SCHED_JOBS
 */

  CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_RUNNING_JOBS as object (
    owner               varchar2(128),                 -- Owner of the running job
    job_name            varchar2(128),                 -- Name of the job being executed
    job_subname         varchar2(128),                 -- Subname for job identification
    state               varchar2(19),                  -- Current state of the job execution
    start_date          timestamp(6) with time zone,   -- Start date/time of the job execution
    end_date            timestamp(6) with time zone,   -- End date/time of the job execution (null if running)
    run_duration        interval day(9) to second(6),  -- Current duration of the job execution
    session_id          number,                        -- Oracle session ID executing the job
    slave_process_id    number,                        -- Slave process ID if using parallel execution
    cpu_used            number,                        -- CPU usage percentage for the job execution
    additional_info     varchar2(4000)                 -- Additional execution information and progress
)

/
