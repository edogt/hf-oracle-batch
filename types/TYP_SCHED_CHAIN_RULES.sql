/**
 * Type: TYP_SCHED_CHAIN_RULES
 * Description: Oracle Scheduler chain rule type for batch process chain execution control.
 *              Defines conditional rules that control chain execution flow based on
 *              step outcomes and system conditions for intelligent batch processing.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler chain rule structures
 *   - Support conditional chain execution control
 *   - Enable intelligent workflow decision making
 *   - Provide error handling and recovery mechanisms
 *
 * Usage Examples:
 * 
 * -- Create a chain rule definition
 * DECLARE
 *   v_rule TYP_SCHED_CHAIN_RULES;
 * BEGIN
 *   v_rule := TYP_SCHED_CHAIN_RULES(
 *     rule_owner => 'HF_BATCH',
 *     rule_name => 'ERROR_HANDLING',
 *     chain_name => 'DAILY_PROCESSING_CHAIN',
 *     condition => 'VALIDATE_STEP.FAILED',
 *     action => 'STOP_CHAIN',
 *     comments => 'Stop chain execution on validation failure'
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
 *     'WEEKLY_CHAIN', 'HF_BATCH', 'ERROR_HANDLING',
 *     'VALIDATE_STEP', 'FAILED', 'STOP_CHAIN', 'Stop chain on validation failure'
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
