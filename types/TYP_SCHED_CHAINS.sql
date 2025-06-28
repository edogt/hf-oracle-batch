/**
 * Type: TYP_SCHED_CHAINS
 * Description: Oracle Scheduler chain type for batch process workflow orchestration.
 *              Defines chain structures that coordinate multiple steps and rules
 *              for complex batch process execution and monitoring.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler chain structures
 *   - Support complex batch process workflow orchestration
 *   - Enable step coordination and rule-based execution
 *   - Provide comprehensive chain execution monitoring
 *
 * Usage Examples:
 * 
 * -- Create a chain definition
 * DECLARE
 *   v_chain TYP_SCHED_CHAINS;
 * BEGIN
 *   v_chain := TYP_SCHED_CHAINS(
 *     rule_set_owner => 'HF_BATCH',
 *     rule_set_name => 'DAILY_RULES',
 *     chain_name => 'DAILY_PROCESSING_CHAIN',
 *     max_steps => 5,
 *     max_runs => 3,
 *     enabled => 'TRUE',
 *     comments => 'Daily data processing and validation chain'
 *   );
 * END;
 *
 * -- Use with collection type
 * DECLARE
 *   v_chains TYP_SCHED_CHAINS_SET;
 * BEGIN
 *   v_chains := TYP_SCHED_CHAINS_SET();
 *   v_chains.EXTEND;
 *   v_chains(v_chains.LAST) := TYP_SCHED_CHAINS(
 *     'WEEKLY_CHAIN', 'HF_BATCH', 'WEEKLY_RULES', 2, 3, 'TRUE',
 *     INTERVAL '5' MINUTE, 'TRUE', 'Weekly processing chain'
 *   );
 * END;
 *
 * Related Objects:
 * - Collection: TYP_SCHED_CHAINS_SET
 * - Rules: TYP_SCHED_CHAIN_RULES, TYP_SCHED_CHAIN_RULES_SET
 * - Steps: TYP_SCHED_CHAIN_STEPS, TYP_SCHED_CHAIN_STEPS_SET
 * - Views: V_BATCH_SCHED_CHAINS, V_BATCH_SCHED_RUNNING_CHAINS
 */


  CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_CHAINS as object (
    chain_name              varchar2(128),                -- Name of the chain
    rule_set_owner          varchar2(128),                -- Owner of the rule set used by this chain
    rule_set_name           varchar2(128),                -- Name of the rule set for chain evaluation
    number_of_rules         number,                       -- Number of rules in the rule set
    number_of_steps         number,                       -- Number of steps in the chain
    enabled                 varchar2(5),                  -- Chain enabled status (TRUE/FALSE)
    evaluation_interval     interval day(3) to second(0), -- Interval for rule evaluation
    user_rule_set           varchar2(5),                  -- Whether using user-defined rule set (TRUE/FALSE)
    comments                varchar2(240)                 -- Description and comments about the chain
)

/
