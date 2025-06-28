/**
 * Type: TYP_SCHED_CHAIN_RULES_SET
 * Description: Collection type for Oracle Scheduler chain rules for batch process execution control.
 *              Provides a structured way to handle multiple chain rule instances
 *              for conditional execution control and workflow orchestration.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Manage collections of chain rule instances
 *   - Support conditional execution control for batch processes
 *   - Enable rule-based workflow orchestration
 *   - Provide structured data handling for chain execution control
 *
 * Usage Examples:
 * 
 * -- Create and populate a chain rules collection
 * DECLARE
 *   v_rules TYP_SCHED_CHAIN_RULES_SET;
 * BEGIN
 *   v_rules := TYP_SCHED_CHAIN_RULES_SET();
 *   
 *   -- Add error handling rule
 *   v_rules.EXTEND;
 *   v_rules(v_rules.LAST) := TYP_SCHED_CHAIN_RULES(
 *     rule_owner => 'HF_BATCH',
 *     rule_name => 'ERROR_HANDLING',
 *     chain_name => 'DAILY_PROCESSING_CHAIN',
 *     condition => 'VALIDATE_STEP.FAILED',
 *     action => 'STOP_CHAIN',
 *     comments => 'Stop chain execution on validation failure'
 *   );
 *   
 *   -- Add success continuation rule
 *   v_rules.EXTEND;
 *   v_rules(v_rules.LAST) := TYP_SCHED_CHAIN_RULES(
 *     rule_owner => 'HF_BATCH',
 *     rule_name => 'SUCCESS_CONTINUATION',
 *     chain_name => 'DAILY_PROCESSING_CHAIN',
 *     condition => 'EXTRACT_STEP.SUCCEEDED',
 *     action => 'CONTINUE_CHAIN',
 *     comments => 'Continue to next step on successful extraction'
 *   );
 *   
 *   -- Add timeout handling rule
 *   v_rules.EXTEND;
 *   v_rules(v_rules.LAST) := TYP_SCHED_CHAIN_RULES(
 *     rule_owner => 'HF_BATCH',
 *     rule_name => 'TIMEOUT_HANDLING',
 *     chain_name => 'DAILY_PROCESSING_CHAIN',
 *     condition => 'REPORT_STEP.TIMEOUT',
 *     action => 'RETRY_STEP',
 *     comments => 'Retry report generation on timeout'
 *   );
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_CHAIN_RULES
 * - Chains: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 * - Steps: TYP_SCHED_CHAIN_STEPS, TYP_SCHED_CHAIN_STEPS_SET
 * - Views: V_BATCH_SCHED_CHAIN_RULES
 */


CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_CHAIN_RULES_SET as table of TYP_SCHED_CHAIN_RULES

/
