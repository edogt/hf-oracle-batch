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
 *   -- Add first job run detail
 *   v_details.EXTEND;
 *   v_details(v_details.LAST) := TYP_SCHED_JOB_RUN_DETAILS(
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
 *   
 *   -- Add second job run detail
 *   v_details.EXTEND;
 *   v_details(v_details.LAST) := TYP_SCHED_JOB_RUN_DETAILS(
 *     owner => 'HF_BATCH',
 *     job_name => 'WEEKLY_REPORT_GENERATION',
 *     job_subname => 'VALIDATION_PHASE',
 *     state => 'RUNNING',
 *     error_code => null,
 *     start_date => SYSTIMESTAMP - INTERVAL '0 0:20:0' DAY TO SECOND,
 *     end_date => null,
 *     run_duration => INTERVAL '0 0:20:0' DAY TO SECOND,
 *     session_id => 12346,
 *     slave_process_id => 67891,
 *     cpu_used => 15.2,
 *     additional_info => 'Validating data set 2 of 4 (50% complete)',
 *     priority => 'HIGH'
 *   );
 *   
 *   -- Add third job run detail (failed)
 *   v_details.EXTEND;
 *   v_details(v_details.LAST) := TYP_SCHED_JOB_RUN_DETAILS(
 *     owner => 'HF_BATCH',
 *     job_name => 'MONTHLY_CLEANUP',
 *     job_subname => 'CLEANUP_PHASE',
 *     state => 'FAILED',
 *     error_code => 20001,
 *     start_date => SYSTIMESTAMP - INTERVAL '0 1:30:0' DAY TO SECOND,
 *     end_date => SYSTIMESTAMP - INTERVAL '0 0:45:0' DAY TO SECOND,
 *     run_duration => INTERVAL '0 0:45:0' DAY TO SECOND,
 *     session_id => 12347,
 *     slave_process_id => 67892,
 *     cpu_used => 12.8,
 *     additional_info => 'Error: ORA-20001 - Insufficient disk space',
 *     priority => 'LOW'
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
