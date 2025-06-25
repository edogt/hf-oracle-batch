/**
 * Type: TYP_SCHED_CHAIN_RULES
 * Description: Oracle Scheduler chain rule definition type for conditional execution control.
 *              Represents a rule configuration that defines conditions and actions
 *              for chain-based batch process orchestration.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler chain rules for conditional execution
 *   - Support rule-based batch process orchestration and control
 *   - Enable conditional branching and decision making in chains
 *   - Provide flexible execution control based on conditions
 *
 * Usage Examples:
 * 
 * -- Create a chain rule definition
 * DECLARE
 *   v_rule TYP_SCHED_CHAIN_RULES;
 * BEGIN
 *   v_rule := TYP_SCHED_CHAIN_RULES(
 *     chain_name => 'DAILY_BATCH_CHAIN',
 *     rule_owner => 'BATCH_MAN',
 *     rule_name => 'CHECK_DATA_AVAILABILITY',
 *     condition => 'step1.state = ''COMPLETED'' AND data_count > 0',
 *     action => 'START step2',
 *     comments => 'Start data processing only if data is available'
 *   );
 * END;
 *
 * -- Use with collection type for multiple rules
 * DECLARE
 *   v_rules TYP_SCHED_CHAIN_RULES_SET;
 * BEGIN
 *   v_rules := TYP_SCHED_CHAIN_RULES_SET();
 *   v_rules.EXTEND;
 *   v_rules(v_rules.LAST) := TYP_SCHED_CHAIN_RULES(
 *     'WEEKLY_CHAIN', 'BATCH_MAN', 'ERROR_HANDLING',
 *     'step1.state = ''FAILED''',
 *     'STOP_CHAIN',
 *     'Stop chain execution on step failure'
 *   );
 * END;
 *
 * Related Objects:
 * - Collection: TYP_SCHED_CHAIN_RULES_SET
 * - Chains: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 * - Steps: TYP_SCHED_CHAIN_STEPS, TYP_SCHED_CHAIN_STEPS_SET
 * - Views: V_BATCH_SCHED_CHAINS, V_BATCH_SCHED_RUNNING_CHAINS
 */

  CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_CHAIN_RULES as object (
    chain_name  varchar2(128),  -- Name of the chain that contains this rule
    rule_owner  varchar2(128),  -- Owner of the rule definition
    rule_name   varchar2(128),  -- Name of the rule for identification
    condition   varchar2(4000), -- Boolean condition expression for rule evaluation
    action      varchar2(4000), -- Action to execute when condition is true
    comments    varchar2(4000)  -- Description of the rule purpose and behavior
)

/
