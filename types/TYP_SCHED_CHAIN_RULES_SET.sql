/**
 * Type: TYP_SCHED_CHAIN_RULES_SET
 * Description: Collection type for Oracle Scheduler chain rule definitions.
 *              Provides a table structure to manage multiple rule configurations
 *              for conditional execution control in batch process chains.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store collections of Oracle Scheduler chain rule definitions
 *   - Enable bulk operations on multiple rule configurations
 *   - Support rule management and conditional execution control
 *   - Facilitate rule-based batch process orchestration
 *
 * Usage Examples:
 * 
 * -- Create and populate a rule collection
 * DECLARE
 *   v_rules TYP_SCHED_CHAIN_RULES_SET;
 * BEGIN
 *   v_rules := TYP_SCHED_CHAIN_RULES_SET();
 *   
 *   -- Add data availability rule
 *   v_rules.EXTEND;
 *   v_rules(v_rules.LAST) := TYP_SCHED_CHAIN_RULES(
 *     chain_name => 'DAILY_BATCH_CHAIN',
 *     rule_owner => 'BATCH_MAN',
 *     rule_name => 'CHECK_DATA_AVAILABILITY',
 *     condition => 'step1.state = ''COMPLETED'' AND data_count > 0',
 *     action => 'START step2',
 *     comments => 'Start data processing only if data is available'
 *   );
 *   
 *   -- Add error handling rule
 *   v_rules.EXTEND;
 *   v_rules(v_rules.LAST) := TYP_SCHED_CHAIN_RULES(
 *     chain_name => 'DAILY_BATCH_CHAIN',
 *     rule_owner => 'BATCH_MAN',
 *     rule_name => 'ERROR_HANDLING',
 *     condition => 'step1.state = ''FAILED''',
 *     action => 'STOP_CHAIN',
 *     comments => 'Stop chain execution on step failure'
 *   );
 *   
 *   -- Add completion rule
 *   v_rules.EXTEND;
 *   v_rules(v_rules.LAST) := TYP_SCHED_CHAIN_RULES(
 *     chain_name => 'DAILY_BATCH_CHAIN',
 *     rule_owner => 'BATCH_MAN',
 *     rule_name => 'COMPLETION_CHECK',
 *     condition => 'step2.state = ''COMPLETED''',
 *     action => 'END_CHAIN',
 *     comments => 'End chain when all steps are completed'
 *   );
 * END;
 *
 * -- Use in procedures for bulk operations
 * PROCEDURE process_rules(p_rules IN TYP_SCHED_CHAIN_RULES_SET) IS
 * BEGIN
 *   FOR i IN 1..p_rules.COUNT LOOP
 *     -- Process each rule
 *     process_single_rule(p_rules(i));
 *   END LOOP;
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_CHAIN_RULES
 * - Chains: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 * - Steps: TYP_SCHED_CHAIN_STEPS, TYP_SCHED_CHAIN_STEPS_SET
 * - Views: V_BATCH_SCHED_CHAINS, V_BATCH_SCHED_RUNNING_CHAINS
 */


CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_CHAIN_RULES_SET as table of TYP_SCHED_CHAIN_RULES

/
