/**
 * Type: TYP_SCHED_JOB_DESTS_SET
 * Description: Collection type for Oracle Scheduler job destination definitions.
 *              Provides a table structure to manage multiple job destination configurations
 *              for batch process execution routing and monitoring.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store collections of Oracle Scheduler job destination definitions
 *   - Enable bulk operations on multiple job destination configurations
 *   - Support job destination management and execution routing
 *   - Facilitate job-based batch process execution monitoring
 *
 * Usage Examples:
 * 
 * -- Create and populate a job destination collection
 * DECLARE
 *   v_dests TYP_SCHED_JOB_DESTS_SET;
 * BEGIN
 *   v_dests := TYP_SCHED_JOB_DESTS_SET();
 *   
 *   -- Add data processing destination
 *   v_dests.EXTEND;
 *   v_dests(v_dests.LAST) := TYP_SCHED_JOB_DESTS(
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
 *   
 *   -- Add validation destination
 *   v_dests.EXTEND;
 *   v_dests(v_dests.LAST) := TYP_SCHED_JOB_DESTS(
 *     job_name => 'DAILY_DATA_PROCESSING',
 *     job_subname => 'VALIDATION_PHASE',
 *     enabled => 'TRUE',
 *     refs_enabled => 'TRUE',
 *     state => 'SCHEDULED',
 *     next_start_date => SYSTIMESTAMP + INTERVAL '1' DAY + INTERVAL '0 0:30:0' DAY TO SECOND,
 *     run_count => 15,
 *     retry_count => 0,
 *     failure_count => 0,
 *     last_start_date => SYSTIMESTAMP - INTERVAL '1' DAY + INTERVAL '0 0:30:0' DAY TO SECOND,
 *     last_end_date => SYSTIMESTAMP - INTERVAL '1' DAY + INTERVAL '0 0:45:0' DAY TO SECOND
 *   );
 *   
 *   -- Add report generation destination
 *   v_dests.EXTEND;
 *   v_dests(v_dests.LAST) := TYP_SCHED_JOB_DESTS(
 *     job_name => 'DAILY_DATA_PROCESSING',
 *     job_subname => 'REPORT_PHASE',
 *     enabled => 'TRUE',
 *     refs_enabled => 'TRUE',
 *     state => 'SCHEDULED',
 *     next_start_date => SYSTIMESTAMP + INTERVAL '1' DAY + INTERVAL '0 0:45:0' DAY TO SECOND,
 *     run_count => 15,
 *     retry_count => 0,
 *     failure_count => 0,
 *     last_start_date => SYSTIMESTAMP - INTERVAL '1' DAY + INTERVAL '0 0:45:0' DAY TO SECOND,
 *     last_end_date => SYSTIMESTAMP - INTERVAL '1' DAY + INTERVAL '0 1:30:0' DAY TO SECOND
 *   );
 * END;
 *
 * -- Use in procedures for bulk operations
 * PROCEDURE process_destinations(p_dests IN TYP_SCHED_JOB_DESTS_SET) IS
 * BEGIN
 *   FOR i IN 1..p_dests.COUNT LOOP
 *     -- Process each destination
 *     process_single_destination(p_dests(i));
 *   END LOOP;
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_JOB_DESTS
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Logs: TYP_SCHED_JOB_LOG, TYP_SCHED_JOB_LOG_SET
 * - Details: TYP_SCHED_JOB_RUN_DETAILS, TYP_SCHED_JOB_RUN_DETAILS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_RUNNING_JOBS
 */

CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_JOB_DESTS_SET as table of TYP_SCHED_JOB_DESTS

/
