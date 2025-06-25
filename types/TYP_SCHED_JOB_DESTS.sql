/**
 * Type: TYP_SCHED_JOB_DESTS
 * Description: Oracle Scheduler job destination definition type for batch process execution routing.
 *              Represents job destination configurations that define where and how
 *              jobs are executed, including state management and execution tracking.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler job destination configurations
 *   - Support job execution routing and destination management
 *   - Enable job state monitoring and execution tracking
 *   - Provide job execution history and performance metrics
 *
 * Usage Examples:
 * 
 * -- Create a job destination definition
 * DECLARE
 *   v_dest TYP_SCHED_JOB_DESTS;
 * BEGIN
 *   v_dest := TYP_SCHED_JOB_DESTS(
 *     job_name => 'DAILY_DATA_PROCESSING',
 *     job_subname => 'EXTRACT_PHASE',
 *     enabled => 'TRUE',
 *     refs_enabled => 'TRUE',
 *     state => 'RUNNING',
 *     next_start_date => SYSTIMESTAMP + INTERVAL '1' DAY,
 *     run_count => 15,
 *     retry_count => 0,
 *     failure_count => 1,
 *     last_start_date => SYSTIMESTAMP - INTERVAL '1' DAY,
 *     last_end_date => SYSTIMESTAMP - INTERVAL '1' DAY + INTERVAL '0 0:30:0' DAY TO SECOND
 *   );
 * END;
 *
 * -- Use with collection type for multiple destinations
 * DECLARE
 *   v_dests TYP_SCHED_JOB_DESTS_SET;
 * BEGIN
 *   v_dests := TYP_SCHED_JOB_DESTS_SET();
 *   v_dests.EXTEND;
 *   v_dests(v_dests.LAST) := TYP_SCHED_JOB_DESTS(
 *     'WEEKLY_REPORT_JOB', 'VALIDATION_PHASE', 'TRUE', 'TRUE', 'SCHEDULED',
 *     SYSTIMESTAMP + INTERVAL '7' DAY, 52, 0, 0,
 *     SYSTIMESTAMP - INTERVAL '7' DAY,
 *     SYSTIMESTAMP - INTERVAL '7' DAY + INTERVAL '0 0:45:0' DAY TO SECOND
 *   );
 * END;
 *
 * Related Objects:
 * - Collection: TYP_SCHED_JOB_DESTS_SET
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Logs: TYP_SCHED_JOB_LOG, TYP_SCHED_JOB_LOG_SET
 * - Details: TYP_SCHED_JOB_RUN_DETAILS, TYP_SCHED_JOB_RUN_DETAILS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_RUNNING_JOBS
 */

  CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_JOB_DESTS as object (
    job_name               varchar2(128),                -- Name of the scheduled job
    job_subname            varchar2(128),                -- Subname for job identification
    enabled                varchar2(5),                  -- Job destination enabled status (TRUE/FALSE)
    refs_enabled           varchar2(5),                  -- References enabled status (TRUE/FALSE)
    state                  varchar2(15),                 -- Current job state (SCHEDULED, RUNNING, COMPLETED, etc.)
    next_start_date        timestamp(6) with time zone,  -- Next scheduled execution timestamp
    run_count              number,                       -- Total number of successful executions
    retry_count            number,                       -- Number of retry attempts
    failure_count          number,                       -- Number of failed executions
    last_start_date        timestamp(6) with time zone,  -- Last execution start timestamp
    last_end_date          timestamp(6) with time zone   -- Last execution end timestamp
)

/
