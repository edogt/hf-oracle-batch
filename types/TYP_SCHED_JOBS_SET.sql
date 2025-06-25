/**
 * Type: TYP_SCHED_JOBS_SET
 * Description: Collection type for Oracle Scheduler job definitions.
 *              Provides a table structure to manage multiple job configurations
 *              for batch process scheduling and execution monitoring.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store collections of Oracle Scheduler job definitions
 *   - Enable bulk operations on multiple job configurations
 *   - Support job management and monitoring operations
 *   - Facilitate job-based batch process scheduling
 *
 * Usage Examples:
 * 
 * -- Create and populate a job collection
 * DECLARE
 *   v_jobs TYP_SCHED_JOBS_SET;
 * BEGIN
 *   v_jobs := TYP_SCHED_JOBS_SET();
 *   
 *   -- Add daily job
 *   v_jobs.EXTEND;
 *   v_jobs(v_jobs.LAST) := TYP_SCHED_JOBS(
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
 *   
 *   -- Add weekly job
 *   v_jobs.EXTEND;
 *   v_jobs(v_jobs.LAST) := TYP_SCHED_JOBS(
 *     job_name => 'WEEKLY_REPORT_JOB',
 *     state => 'RUNNING',
 *     start_date => SYSTIMESTAMP,
 *     last_start_date => SYSTIMESTAMP - INTERVAL '7' DAY,
 *     last_run_duration => INTERVAL '0 0:45:0.0' DAY TO SECOND,
 *     next_run_date => SYSTIMESTAMP + INTERVAL '7' DAY,
 *     program_name => 'WEEKLY_REPORT_PRG',
 *     job_type => 'STORED_PROCEDURE',
 *     repeat_interval => 'FREQ=WEEKLY; BYDAY=SUN',
 *     enabled => 'TRUE',
 *     auto_drop => 'FALSE',
 *     restart_on_recovery => 'TRUE',
 *     run_count => 52
 *   );
 * END;
 *
 * -- Use in procedures for bulk operations
 * PROCEDURE process_jobs(p_jobs IN TYP_SCHED_JOBS_SET) IS
 * BEGIN
 *   FOR i IN 1..p_jobs.COUNT LOOP
 *     -- Process each job
 *     process_single_job(p_jobs(i));
 *   END LOOP;
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_JOBS
 * - Programs: TYP_SCHED_PROGRAMS, TYP_SCHED_PROGRAMS_SET
 * - Logs: TYP_SCHED_JOB_LOG, TYP_SCHED_JOB_LOG_SET
 * - Details: TYP_SCHED_JOB_RUN_DETAILS, TYP_SCHED_JOB_RUN_DETAILS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_RUNNING_JOBS
 */

CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_JOBS_SET as table of TYP_SCHED_JOBS

/
