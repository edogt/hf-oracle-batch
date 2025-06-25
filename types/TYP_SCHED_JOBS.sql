/**
 * Type: TYP_SCHED_JOBS
 * Description: Oracle Scheduler job definition type for batch process scheduling.
 *              Represents a scheduled job configuration with execution parameters,
 *              timing controls, and state management capabilities.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler job configurations for batch processes
 *   - Support job-based batch process scheduling and execution
 *   - Enable job state monitoring and management
 *   - Provide job execution history and performance tracking
 *
 * Usage Examples:
 * 
 * -- Create a scheduled job definition
 * DECLARE
 *   v_job TYP_SCHED_JOBS;
 * BEGIN
 *   v_job := TYP_SCHED_JOBS(
 *     job_name => 'DAILY_DATA_PROCESSING',
 *     state => 'SCHEDULED',
 *     start_date => SYSTIMESTAMP,
 *     last_start_date => SYSTIMESTAMP - INTERVAL '1' DAY,
 *     last_run_duration => INTERVAL '0 0:15:30.0' DAY TO SECOND,
 *     next_run_date => SYSTIMESTAMP + INTERVAL '1' DAY,
 *     program_name => 'BATCH_DATA_PROCESSING_PRG',
 *     job_type => 'STORED_PROCEDURE',
 *     repeat_interval => 'FREQ=DAILY; BYHOUR=2',
 *     enabled => 'TRUE',
 *     auto_drop => 'FALSE',
 *     restart_on_recovery => 'TRUE',
 *     run_count => 15
 *   );
 * END;
 *
 * -- Use with collection type for bulk operations
 * DECLARE
 *   v_jobs TYP_SCHED_JOBS_SET;
 * BEGIN
 *   v_jobs := TYP_SCHED_JOBS_SET();
 *   v_jobs.EXTEND;
 *   v_jobs(v_jobs.LAST) := TYP_SCHED_JOBS(
 *     'WEEKLY_REPORT_JOB', 'RUNNING', SYSTIMESTAMP, SYSTIMESTAMP - INTERVAL '7' DAY,
 *     INTERVAL '0 0:45:0.0' DAY TO SECOND, SYSTIMESTAMP + INTERVAL '7' DAY,
 *     'WEEKLY_REPORT_PRG', 'STORED_PROCEDURE', 'FREQ=WEEKLY; BYDAY=SUN',
 *     'TRUE', 'FALSE', 'TRUE', 52
 *   );
 * END;
 *
 * Related Objects:
 * - Collection: TYP_SCHED_JOBS_SET
 * - Programs: TYP_SCHED_PROGRAMS, TYP_SCHED_PROGRAMS_SET
 * - Logs: TYP_SCHED_JOB_LOG, TYP_SCHED_JOB_LOG_SET
 * - Details: TYP_SCHED_JOB_RUN_DETAILS, TYP_SCHED_JOB_RUN_DETAILS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_RUNNING_JOBS
 */

  CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_JOBS as object (
    job_name                   varchar2(128),                -- Name of the scheduled job
    state                      varchar2(15),                 -- Current job state (SCHEDULED, RUNNING, COMPLETED, FAILED, etc.)
    start_date                 timestamp(6) with time zone,  -- Job creation/start timestamp
    last_start_date            timestamp(6) with time zone,  -- Last execution start timestamp
    last_run_duration          interval day(9) to second(6), -- Duration of the last execution
    next_run_date              timestamp(6) with time zone,  -- Next scheduled execution timestamp
    program_name               varchar2(4000),               -- Associated program name
    job_type                   varchar2(16),                 -- Job type (STORED_PROCEDURE, PLSQL_BLOCK, etc.)
    repeat_interval            varchar2(4000),               -- Recurrence pattern for the job
    enabled                    varchar2(5),                  -- Job enabled status (TRUE/FALSE)
    auto_drop                  varchar2(5),                  -- Auto-drop after completion (TRUE/FALSE)
    restart_on_recovery        varchar2(5),                  -- Restart on recovery (TRUE/FALSE)
    run_count                  number                        -- Total number of executions
)

/
