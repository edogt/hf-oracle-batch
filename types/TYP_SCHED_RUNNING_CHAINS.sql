/**
 * Type: TYP_SCHED_RUNNING_CHAINS
 * Description: Oracle Scheduler running chain status type for batch process execution monitoring.
 *              Represents active chain execution instances with real-time status information,
 *              progress tracking, and execution metrics for operational monitoring.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler running chain status structures
 *   - Support real-time chain execution monitoring and tracking
 *   - Enable chain progress analysis and performance monitoring
 *   - Provide operational visibility into active batch processes
 *
 * Usage Examples:
 * 
 * -- Create a running chain status entry
 * DECLARE
 *   v_running TYP_SCHED_RUNNING_CHAINS;
 * BEGIN
 *   v_running := TYP_SCHED_RUNNING_CHAINS(
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
 * END;
 *
 * -- Use with collection type for multiple running chains
 * DECLARE
 *   v_running_list TYP_SCHED_RUNNING_CHAINS_SET;
 * BEGIN
 *   v_running_list := TYP_SCHED_RUNNING_CHAINS_SET();
 *   v_running_list.EXTEND;
 *   v_running_list(v_running_list.LAST) := TYP_SCHED_RUNNING_CHAINS(
 *     'BATCH_MAN', 'WEEKLY_REPORT_CHAIN', 'WEEKLY_REPORT_CHAIN_JOB', 'VALIDATION_PHASE',
 *     'RUNNING', SYSTIMESTAMP - INTERVAL '0 0:30:0' DAY TO SECOND, null,
 *     INTERVAL '0 0:30:0' DAY TO SECOND, 12346, 67891, 18.2,
 *     'Step 1 of 3 completed, 2 steps remaining'
 *   );
 * END;
 *
 * Related Objects:
 * - Collection: TYP_SCHED_RUNNING_CHAINS_SET
 * - Chains: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Steps: TYP_SCHED_CHAIN_STEPS, TYP_SCHED_CHAIN_STEPS_SET
 * - Views: V_BATCH_SCHED_RUNNING_CHAINS, V_BATCH_SCHED_CHAINS
 */

  CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_RUNNING_CHAINS as object (
    owner               varchar2(128),                 -- Owner of the running chain
    chain_name          varchar2(128),                 -- Name of the chain being executed
    job_name            varchar2(128),                 -- Name of the job executing the chain
    job_subname         varchar2(128),                 -- Subname for job identification
    state               varchar2(19),                  -- Current state of the chain execution
    start_date          timestamp(6) with time zone,   -- Start date/time of the chain execution
    end_date            timestamp(6) with time zone,   -- End date/time of the chain execution (null if running)
    run_duration        interval day(9) to second(6),  -- Current duration of the chain execution
    session_id          number,                        -- Oracle session ID executing the chain
    slave_process_id    number,                        -- Slave process ID if using parallel execution
    cpu_used            number,                        -- CPU usage percentage for the chain execution
    additional_info     varchar2(4000)                 -- Additional execution information and progress
)

/
