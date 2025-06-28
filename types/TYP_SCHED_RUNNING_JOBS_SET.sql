/**
 * Type: TYP_SCHED_RUNNING_JOBS_SET
 * Description: Collection type for Oracle Scheduler running job status entries.
 *              Provides a table structure to manage multiple running job instances
 *              for real-time batch process monitoring and operational visibility.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store collections of Oracle Scheduler running job status entries
 *   - Enable bulk operations on multiple running job instances
 *   - Support real-time job execution monitoring and tracking
 *   - Facilitate operational visibility into active batch jobs
 *
 * Usage Examples:
 * 
 * -- Create and populate a running jobs collection
 * DECLARE
 *   v_running TYP_SCHED_RUNNING_JOBS_SET;
 * BEGIN
 *   v_running := TYP_SCHED_RUNNING_JOBS_SET();
 *   
 *   -- Add data processing job execution
 *   v_running.EXTEND;
 *   v_running(v_running.LAST) := TYP_SCHED_RUNNING_JOBS(
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
 *   
 *   -- Add report generation job execution
 *   v_running.EXTEND;
 *   v_running(v_running.LAST) := TYP_SCHED_RUNNING_JOBS(
 *     owner => 'HF_BATCH',
 *     job_name => 'WEEKLY_REPORT_JOB',
 *     job_subname => 'VALIDATION_PHASE',
 *     state => 'RUNNING',
 *     start_date => SYSTIMESTAMP - INTERVAL '0 0:45:0' DAY TO SECOND,
 *     end_date => null,
 *     run_duration => INTERVAL '0 0:45:0' DAY TO SECOND,
 *     session_id => 12346,
 *     slave_process_id => 67891,
 *     cpu_used => 22.8,
 *     additional_info => 'Validating data set 3 of 5 (60% complete)'
 *   );
 *   
 *   -- Add cleanup job execution
 *   v_running.EXTEND;
 *   v_running(v_running.LAST) := TYP_SCHED_RUNNING_JOBS(
 *     owner => 'HF_BATCH',
 *     job_name => 'MONTHLY_CLEANUP_JOB',
 *     job_subname => 'CLEANUP_PHASE',
 *     state => 'RUNNING',
 *     start_date => SYSTIMESTAMP - INTERVAL '0 1:30:0' DAY TO SECOND,
 *     end_date => null,
 *     run_duration => INTERVAL '0 1:30:0' DAY TO SECOND,
 *     session_id => 12347,
 *     slave_process_id => 67892,
 *     cpu_used => 45.6,
 *     additional_info => 'Cleaning up old records: 5000 processed, 2000 remaining'
 *   );
 * END;
 *
 * -- Use in procedures for bulk monitoring
 * PROCEDURE monitor_running_jobs(p_running IN TYP_SCHED_RUNNING_JOBS_SET) IS
 * BEGIN
 *   FOR i IN 1..p_running.COUNT LOOP
 *     -- Monitor each running job
 *     monitor_single_job(p_running(i));
 *   END LOOP;
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_RUNNING_JOBS
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Programs: TYP_SCHED_PROGRAMS, TYP_SCHED_PROGRAMS_SET
 * - Destinations: TYP_SCHED_JOB_DESTS, TYP_SCHED_JOB_DESTS_SET
 * - Views: V_BATCH_SCHED_RUNNING_JOBS, V_BATCH_SCHED_JOBS
 */

CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_RUNNING_JOBS_SET as table of TYP_SCHED_RUNNING_JOBS

/
