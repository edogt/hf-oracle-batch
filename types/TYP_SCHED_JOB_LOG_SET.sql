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
 *   -- Add successful execution log
 *   v_logs.EXTEND;
 *   v_logs(v_logs.LAST) := TYP_SCHED_JOB_LOG(
 *     log_id => 12345,
 *     log_date => SYSTIMESTAMP,
 *     owner => 'BATCH_MAN',
 *     job_name => 'DAILY_DATA_PROCESSING',
 *     job_subname => 'EXTRACT_PHASE',
 *     operation => 'RUN',
 *     status => 'SUCCEEDED',
 *     user_name => 'BATCH_USER',
 *     additional_info => 'Processed 15000 records successfully'
 *   );
 *   
 *   -- Add failed execution log
 *   v_logs.EXTEND;
 *   v_logs(v_logs.LAST) := TYP_SCHED_JOB_LOG(
 *     log_id => 12346,
 *     log_date => SYSTIMESTAMP,
 *     owner => 'BATCH_MAN',
 *     job_name => 'WEEKLY_REPORT_JOB',
 *     job_subname => 'VALIDATION_PHASE',
 *     operation => 'RUN',
 *     status => 'FAILED',
 *     user_name => 'BATCH_USER',
 *     additional_info => 'Validation failed: Invalid data format'
 *   );
 *   
 *   -- Add job stop log
 *   v_logs.EXTEND;
 *   v_logs(v_logs.LAST) := TYP_SCHED_JOB_LOG(
 *     log_id => 12347,
 *     log_date => SYSTIMESTAMP,
 *     owner => 'BATCH_MAN',
 *     job_name => 'MONTHLY_CLEANUP_JOB',
 *     job_subname => 'CLEANUP_PHASE',
 *     operation => 'STOP',
 *     status => 'SUCCEEDED',
 *     user_name => 'ADMIN_USER',
 *     additional_info => 'Job stopped by administrator'
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
