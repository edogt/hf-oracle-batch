/**
 * Type: TYP_SCHED_CHAINS_SET
 * Description: Collection type for Oracle Scheduler chain definitions.
 *              Provides a table structure to manage multiple chain configurations
 *              for batch process orchestration and scheduling.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store collections of Oracle Scheduler chain definitions
 *   - Enable bulk operations on multiple chain configurations
 *   - Support chain management and monitoring operations
 *   - Facilitate chain-based batch process orchestration
 *
 * Usage Examples:
 * 
 * -- Create and populate a chain collection
 * DECLARE
 *   v_chains TYP_SCHED_CHAINS_SET;
 * BEGIN
 *   v_chains := TYP_SCHED_CHAINS_SET();
 *   
 *   -- Add daily processing chain
 *   v_chains.EXTEND;
 *   v_chains(v_chains.LAST) := TYP_SCHED_CHAINS(
 *     rule_set_owner => 'HF_BATCH',
 *     rule_set_name => 'DAILY_RULES',
 *     chain_name => 'DAILY_PROCESSING_CHAIN',
 *     max_steps => 5,
 *     max_runs => 3,
 *     enabled => 'TRUE',
 *     comments => 'Daily data processing and validation chain'
 *   );
 *   
 *   -- Add weekly reporting chain
 *   v_chains.EXTEND;
 *   v_chains(v_chains.LAST) := TYP_SCHED_CHAINS(
 *     rule_set_owner => 'HF_BATCH',
 *     rule_set_name => 'WEEKLY_RULES',
 *     chain_name => 'WEEKLY_REPORTING_CHAIN',
 *     max_steps => 8,
 *     max_runs => 2,
 *     enabled => 'TRUE',
 *     comments => 'Weekly report generation and distribution chain'
 *   );
 * END;
 *
 * -- Use in procedures for bulk operations
 * PROCEDURE process_chains(p_chains IN TYP_SCHED_CHAINS_SET) IS
 * BEGIN
 *   FOR i IN 1..p_chains.COUNT LOOP
 *     -- Process each chain
 *     process_single_chain(p_chains(i));
 *   END LOOP;
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_CHAINS
 * - Rules: TYP_SCHED_CHAIN_RULES, TYP_SCHED_CHAIN_RULES_SET
 * - Steps: TYP_SCHED_CHAIN_STEPS, TYP_SCHED_CHAIN_STEPS_SET
 * - Views: V_BATCH_SCHED_CHAINS, V_BATCH_SCHED_RUNNING_CHAINS
 */

CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_CHAINS_SET as table of TYP_SCHED_CHAINS

/
