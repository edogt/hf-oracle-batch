/**
 * Type: TYP_SCHED_JOB_RUN_DETAILS_SET
 * Description: Collection type for Oracle Scheduler job run details.
 *              Provides a table structure to manage multiple job run detail entries
 *              for batch process performance analysis and capacity planning.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store collections of Oracle Scheduler job run detail entries
 *   - Enable bulk operations on multiple run detail records
 *   - Support job performance analysis and trend monitoring
 *   - Facilitate capacity planning and resource optimization
 *
 * Usage Examples:
 * 
 * -- Create and populate a job run details collection
 * DECLARE
 *   v_details TYP_SCHED_JOB_RUN_DETAILS_SET;
 * BEGIN
 *   v_details := TYP_SCHED_JOB_RUN_DETAILS_SET();
 *   
 *   -- Add successful execution details
 *   v_details.EXTEND;
 *   v_details(v_details.LAST) := TYP_SCHED_JOB_RUN_DETAILS(
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
 *   
 *   -- Add failed execution details
 *   v_details.EXTEND;
 *   v_details(v_details.LAST) := TYP_SCHED_JOB_RUN_DETAILS(
 *     log_id => 12346,
 *     log_date => SYSTIMESTAMP,
 *     owner => 'BATCH_MAN',
 *     job_name => 'WEEKLY_REPORT_JOB',
 *     job_subname => 'VALIDATION_PHASE',
 *     status => 'FAILED',
 *     error# => 20001,
 *     req_start_date => SYSTIMESTAMP - INTERVAL '0 0:15:0' DAY TO SECOND,
 *     actual_start_date => SYSTIMESTAMP - INTERVAL '0 0:15:0' DAY TO SECOND,
 *     run_duration => INTERVAL '0 0:12:45.2' DAY TO SECOND,
 *     additional_info => 'Error: ORA-20001 - Invalid data format detected'
 *   );
 *   
 *   -- Add long-running job details
 *   v_details.EXTEND;
 *   v_details(v_details.LAST) := TYP_SCHED_JOB_RUN_DETAILS(
 *     log_id => 12347,
 *     log_date => SYSTIMESTAMP,
 *     owner => 'BATCH_MAN',
 *     job_name => 'MONTHLY_CLEANUP_JOB',
 *     job_subname => 'CLEANUP_PHASE',
 *     status => 'SUCCEEDED',
 *     error# => null,
 *     req_start_date => SYSTIMESTAMP - INTERVAL '0 2:0:0' DAY TO SECOND,
 *     actual_start_date => SYSTIMESTAMP - INTERVAL '0 2:0:0' DAY TO SECOND,
 *     run_duration => INTERVAL '0 1:45:20.1' DAY TO SECOND,
 *     additional_info => 'CPU: 45%, Memory: 512MB, Records: 50000, Cleaned: 1000'
 *   );
 * END;
 *
 * -- Use in procedures for bulk analysis
 * PROCEDURE analyze_performance(p_details IN TYP_SCHED_JOB_RUN_DETAILS_SET) IS
 * BEGIN
 *   FOR i IN 1..p_details.COUNT LOOP
 *     -- Analyze each run detail
 *     analyze_single_run(p_details(i));
 *   END LOOP;
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_JOB_RUN_DETAILS
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Logs: TYP_SCHED_JOB_LOG, TYP_SCHED_JOB_LOG_SET
 * - Destinations: TYP_SCHED_JOB_DESTS, TYP_SCHED_JOB_DESTS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_RUNNING_JOBS
 */

CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_JOB_RUN_DETAILS_SET as table of TYP_SCHED_JOB_RUN_DETAILS

/
