/**
 * View: V_BATCH_SCHED_CHAIN_STEPS
 * Description: Oracle Scheduler chain steps monitoring view.
 *              Provides detailed information about chain steps including
 *              programs, execution order, and configuration for chain analysis.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor Oracle Scheduler chain step configurations
 *   - Provide step-by-step chain execution information
 *   - Support chain step analysis and troubleshooting
 *   - Enable chain execution flow visualization
 *
 * Query Description:
 *   - Uses PCK_BATCH_MONITOR.GET_SCHED_CHAIN_STEPS function to retrieve chain steps
 *   - Provides step execution order, programs, and configuration details
 *   - Enables chain execution flow analysis and optimization
 *   - Supports chain step troubleshooting and performance analysis
 *
 * Usage Examples:
 * 
 * -- Get all chain steps
 * SELECT * FROM V_BATCH_SCHED_CHAIN_STEPS 
 * ORDER BY CHAIN_NAME, STEP_NUMBER;
 *
 * -- Get steps for a specific chain
 * SELECT * FROM V_BATCH_SCHED_CHAIN_STEPS 
 * WHERE CHAIN_NAME = 'DAILY_PROCESSING_CHAIN'
 * ORDER BY STEP_NUMBER;
 *
 * -- Get steps by type
 * SELECT STEP_TYPE, COUNT(*) as step_count,
 *        COUNT(DISTINCT CHAIN_NAME) as unique_chains
 * FROM V_BATCH_SCHED_CHAIN_STEPS 
 * GROUP BY STEP_TYPE
 * ORDER BY step_count DESC;
 *
 * -- Get chains with many steps (> 5 steps)
 * SELECT CHAIN_NAME, COUNT(*) as step_count,
 *        MAX(STEP_NUMBER) as max_step_number
 * FROM V_BATCH_SCHED_CHAIN_STEPS 
 * GROUP BY CHAIN_NAME
 * HAVING COUNT(*) > 5
 * ORDER BY step_count DESC;
 *
 * -- Get steps with pause configurations
 * SELECT * FROM V_BATCH_SCHED_CHAIN_STEPS 
 * WHERE PAUSE_BEFORE = 'TRUE' OR PAUSE_AFTER = 'TRUE'
 * ORDER BY CHAIN_NAME, STEP_NUMBER;
 *
 * -- Get program usage analysis
 * SELECT PROGRAM_NAME, COUNT(*) as usage_count,
 *        COUNT(DISTINCT CHAIN_NAME) as unique_chains
 * FROM V_BATCH_SCHED_CHAIN_STEPS 
 * GROUP BY PROGRAM_NAME
 * ORDER BY usage_count DESC;
 *
 * Related Objects:
 * - Packages: PCK_BATCH_MONITOR (GET_SCHED_CHAIN_STEPS function)
 * - Types: TYP_SCHED_CHAIN_STEPS, TYP_SCHED_CHAIN_STEPS_SET
 * - Views: V_BATCH_SCHED_CHAINS, V_BATCH_SCHED_PROGRAMS
 * - Tables: BATCH_SCHED_CHAIN_STEPS, BATCH_SCHEDULER_JOBS
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SCHED_CHAIN_STEPS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SCHED_CHAIN_STEPS (
    CHAIN_NAME,            -- Oracle Scheduler chain name
    STEP_NAME,             -- Step name within the chain
    PROGRAM_OWNER,         -- Owner of the program being executed
    PROGRAM_NAME,          -- Name of the program being executed
    STEP_TYPE,             -- Type of step (PROGRAM, EVENT, etc.)
    STEP_NUMBER,           -- Execution order within the chain
    PAUSE_BEFORE,          -- Whether to pause before step execution
    PAUSE_AFTER,           -- Whether to pause after step execution
    COMMENTS               -- Additional comments and notes
) AS
select CHAIN_NAME, STEP_NAME, PROGRAM_OWNER, PROGRAM_NAME, STEP_TYPE, STEP_NUMBER, PAUSE_BEFORE, PAUSE_AFTER, COMMENTS 
from table(PCK_BATCH_MONITOR.get_sched_chain_steps)
;
GRANT SELECT ON V_BATCH_SCHED_CHAIN_STEPS TO ROLE_HF_BATCH;
