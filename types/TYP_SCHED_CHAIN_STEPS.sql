/**
 * Type: TYP_SCHED_CHAIN_STEPS
 * Description: Oracle Scheduler chain step type for batch process chain execution.
 *              Defines individual steps within a chain with program references,
 *              execution order, and configuration for structured batch workflows.
 *
 * Author: Eduardo Guti�rrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler chain step structures
 *   - Support chain workflow definition and configuration
 *   - Enable step execution control and monitoring
 *   - Provide structured chain execution for batch processes
 *
 * Usage Examples:
 * 
 * -- Create a chain step definition
 * DECLARE
 *   v_step TYP_SCHED_CHAIN_STEPS;
 * BEGIN
 *   v_step := TYP_SCHED_CHAIN_STEPS(
 *     program_owner => 'HF_BATCH',
 *     program_name => 'EXTRACT_DATA_PRG',
 *     step_name => 'EXTRACT_STEP',
 *     chain_name => 'DAILY_PROCESSING_CHAIN',
 *     step_type => 'PROGRAM',
 *     step_order => 1,
 *     enabled => 'TRUE',
 *     comments => 'Extract data from source systems'
 *   );
 * END;
 *
 * -- Use with collection type for multiple steps
 * DECLARE
 *   v_steps TYP_SCHED_CHAIN_STEPS_SET;
 * BEGIN
 *   v_steps := TYP_SCHED_CHAIN_STEPS_SET();
 *   v_steps.EXTEND;
 *   v_steps(v_steps.LAST) := TYP_SCHED_CHAIN_STEPS(
 *     'WEEKLY_CHAIN', 'VALIDATION_STEP', 'HF_BATCH', 'VALIDATE_DATA_PRG',
 *     'VALIDATE_DATA_PRG', 2, 'TRUE', 'Validate extracted data for consistency'
 *   );
 * END;
 *
 * Related Objects:
 * - Collection: TYP_SCHED_CHAIN_STEPS_SET
 * - Programs: TYP_SCHED_PROGRAMS, TYP_SCHED_PROGRAMS_SET
 * - Chains: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 * - Rules: TYP_SCHED_CHAIN_RULES, TYP_SCHED_CHAIN_RULES_SET
 * - Views: V_BATCH_SCHED_CHAINS, V_BATCH_SCHED_RUNNING_CHAINS
 */

  CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_CHAIN_STEPS as object (
    chain_name             varchar2(128),                -- Name of the chain containing this step
    step_name              varchar2(128),                -- Unique name of the step within the chain
    program_owner          varchar2(128),                -- Owner of the program referenced by this step
    program_name           varchar2(128),                -- Name of the program to execute in this step
    skip                   varchar2(5),                  -- Whether to skip this step (TRUE/FALSE)
    pause                  varchar2(5),                  -- Whether to pause after this step (TRUE/FALSE)
    pause_before           varchar2(5),                  -- Whether to pause before this step (TRUE/FALSE)
    restart_on_recovery    varchar2(5),                  -- Restart step on recovery (TRUE/FALSE)
    restart_on_failure     varchar2(5),                  -- Restart step on failure (TRUE/FALSE)
    step_type              varchar2(16),                 -- Type of step (PROGRAM, CHAIN, etc.)
    timeout                interval day(9) to second(6)  -- Step execution timeout
)

/
