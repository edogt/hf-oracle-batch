/**
 * Type: TYP_SCHED_RUNNING_CHAINS_SET
 * Description: Collection type for Oracle Scheduler running chain status entries.
 *              Provides a table structure to manage multiple running chain instances
 *              for real-time batch process monitoring and operational visibility.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store collections of Oracle Scheduler running chain status entries
 *   - Enable bulk operations on multiple running chain instances
 *   - Support real-time chain execution monitoring and tracking
 *   - Facilitate operational visibility into active batch processes
 *
 * Usage Examples:
 * 
 * -- Create and populate a running chains collection
 * DECLARE
 *   v_running TYP_SCHED_RUNNING_CHAINS_SET;
 * BEGIN
 *   v_running := TYP_SCHED_RUNNING_CHAINS_SET();
 *   
 *   -- Add daily batch chain execution
 *   v_running.EXTEND;
 *   v_running(v_running.LAST) := TYP_SCHED_RUNNING_CHAINS(
 *     owner => 'BATCH_MAN',
 *     chain_name => 'DAILY_BATCH_CHAIN',
 *     job_name => 'DAILY_BATCH_CHAIN_JOB',
 *     job_subname => 'EXECUTION_PHASE',
 *     state => 'RUNNING',
 *     start_date => SYSTIMESTAMP - INTERVAL '0 0:15:0' DAY TO SECOND,
 *     end_date => null,
 *     run_duration => INTERVAL '0 0:15:0' DAY TO SECOND,
 *     session_id => 12345,
 *     slave_process_id => 67890,
 *     cpu_used => 25.5,
 *     additional_info => 'Step 2 of 5 completed, 3 steps remaining'
 *   );
 *   
 *   -- Add weekly report chain execution
 *   v_running.EXTEND;
 *   v_running(v_running.LAST) := TYP_SCHED_RUNNING_CHAINS(
 *     owner => 'BATCH_MAN',
 *     chain_name => 'WEEKLY_REPORT_CHAIN',
 *     job_name => 'WEEKLY_REPORT_CHAIN_JOB',
 *     job_subname => 'VALIDATION_PHASE',
 *     state => 'RUNNING',
 *     start_date => SYSTIMESTAMP - INTERVAL '0 0:30:0' DAY TO SECOND,
 *     end_date => null,
 *     run_duration => INTERVAL '0 0:30:0' DAY TO SECOND,
 *     session_id => 12346,
 *     slave_process_id => 67891,
 *     cpu_used => 18.2,
 *     additional_info => 'Step 1 of 3 completed, 2 steps remaining'
 *   );
 *   
 *   -- Add monthly cleanup chain execution
 *   v_running.EXTEND;
 *   v_running(v_running.LAST) := TYP_SCHED_RUNNING_CHAINS(
 *     owner => 'BATCH_MAN',
 *     chain_name => 'MONTHLY_CLEANUP_CHAIN',
 *     job_name => 'MONTHLY_CLEANUP_CHAIN_JOB',
 *     job_subname => 'CLEANUP_PHASE',
 *     state => 'RUNNING',
 *     start_date => SYSTIMESTAMP - INTERVAL '0 1:0:0' DAY TO SECOND,
 *     end_date => null,
 *     run_duration => INTERVAL '0 1:0:0' DAY TO SECOND,
 *     session_id => 12347,
 *     slave_process_id => 67892,
 *     cpu_used => 35.8,
 *     additional_info => 'Step 3 of 4 completed, 1 step remaining'
 *   );
 * END;
 *
 * -- Use in procedures for bulk monitoring
 * PROCEDURE monitor_running_chains(p_running IN TYP_SCHED_RUNNING_CHAINS_SET) IS
 * BEGIN
 *   FOR i IN 1..p_running.COUNT LOOP
 *     -- Monitor each running chain
 *     monitor_single_chain(p_running(i));
 *   END LOOP;
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_RUNNING_CHAINS
 * - Chains: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Steps: TYP_SCHED_CHAIN_STEPS, TYP_SCHED_CHAIN_STEPS_SET
 * - Views: V_BATCH_SCHED_RUNNING_CHAINS, V_BATCH_SCHED_CHAINS
 */

CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_RUNNING_CHAINS_SET as table of TYP_SCHED_RUNNING_CHAINS

/
