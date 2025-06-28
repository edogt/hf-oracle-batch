/**
 * Type: TYP_SCHED_JOB_LOG_SET
 * Description: Collection type for Oracle Scheduler job log entries.
 *              Provides a table structure to manage multiple job log entries
 *              for batch process execution history and audit analysis.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store collections of Oracle Scheduler job log entries
 *   - Enable bulk operations on multiple log entries
 *   - Support job execution history analysis and audit
 *   - Facilitate job monitoring and troubleshooting
 *
 * Usage Examples:
 * 
 * -- Create and populate a job log collection
 * DECLARE
 *   v_logs TYP_SCHED_JOB_LOG_SET;
 * BEGIN
 *   v_logs := TYP_SCHED_JOB_LOG_SET();
 *   
 *   -- Add successful job log entry
 *   v_logs.EXTEND;
 *   v_logs(v_logs.LAST) := TYP_SCHED_JOB_LOG(
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
 *   
 *   -- Add failed job log entry
 *   v_logs.EXTEND;
 *   v_logs(v_logs.LAST) := TYP_SCHED_JOB_LOG(
 *     owner => 'HF_BATCH',
 *     job_name => 'WEEKLY_REPORT_GENERATION',
 *     job_subname => 'VALIDATION_PHASE',
 *     status => 'FAILED',
 *     error_code => 20001,
 *     req_start_date => SYSTIMESTAMP - INTERVAL '0 0:15:0' DAY TO SECOND,
 *     actual_start_date => SYSTIMESTAMP - INTERVAL '0 0:15:0' DAY TO SECOND,
 *     run_duration => INTERVAL '0 0:12:45.2' DAY TO SECOND,
 *     additional_info => 'Error: ORA-20001 - Invalid data format detected'
 *   );
 *   
 *   -- Add long-running job log entry
 *   v_logs.EXTEND;
 *   v_logs(v_logs.LAST) := TYP_SCHED_JOB_LOG(
 *     owner => 'HF_BATCH',
 *     job_name => 'MONTHLY_CLEANUP_JOB',
 *     job_subname => 'CLEANUP_PHASE',
 *     status => 'SUCCEEDED',
 *     error_code => null,
 *     req_start_date => SYSTIMESTAMP - INTERVAL '0 2:0:0' DAY TO SECOND,
 *     actual_start_date => SYSTIMESTAMP - INTERVAL '0 2:0:0' DAY TO SECOND,
 *     run_duration => INTERVAL '0 1:45:20.1' DAY TO SECOND,
 *     additional_info => 'CPU: 45%, Memory: 512MB, Records: 50000, Cleaned: 1000'
 *   );
 * END;
 *
 * -- Use in procedures for bulk operations
 * PROCEDURE analyze_logs(p_logs IN TYP_SCHED_JOB_LOG_SET) IS
 * BEGIN
 *   FOR i IN 1..p_logs.COUNT LOOP
 *     -- Analyze each log entry
 *     analyze_single_log(p_logs(i));
 *   END LOOP;
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_JOB_LOG
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Destinations: TYP_SCHED_JOB_DESTS, TYP_SCHED_JOB_DESTS_SET
 * - Details: TYP_SCHED_JOB_RUN_DETAILS, TYP_SCHED_JOB_RUN_DETAILS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_RUNNING_JOBS
 */

CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_JOB_LOG_SET as table of TYP_SCHED_JOB_LOG

/
