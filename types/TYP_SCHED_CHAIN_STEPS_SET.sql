/**
 * Type: TYP_SCHED_CHAIN_STEPS_SET
 * Description: Collection type for Oracle Scheduler chain step definitions.
 *              Provides a table structure to manage multiple step configurations
 *              within batch process chains for workflow execution.
 *
 * Author: Eduardo Guti�rrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store collections of Oracle Scheduler chain step definitions
 *   - Enable bulk operations on multiple step configurations
 *   - Support step management and workflow execution control
 *   - Facilitate step-based batch process orchestration
 *
 * Usage Examples:
 * 
 * -- Create and populate a step collection
 * DECLARE
 *   v_steps TYP_SCHED_CHAIN_STEPS_SET;
 * BEGIN
 *   v_steps := TYP_SCHED_CHAIN_STEPS_SET();
 *   
 *   -- Add data extraction step
 *   v_steps.EXTEND;
 *   v_steps(v_steps.LAST) := TYP_SCHED_CHAIN_STEPS(
 *     program_owner => 'HF_BATCH',
 *     program_name => 'EXTRACT_DATA_PRG',
 *     step_name => 'EXTRACT_STEP',
 *     chain_name => 'DAILY_PROCESSING_CHAIN',
 *     step_type => 'PROGRAM',
 *     step_order => 1,
 *     enabled => 'TRUE',
 *     comments => 'Extract data from source systems'
 *   );
 *   
 *   -- Add data validation step
 *   v_steps.EXTEND;
 *   v_steps(v_steps.LAST) := TYP_SCHED_CHAIN_STEPS(
 *     program_owner => 'HF_BATCH',
 *     program_name => 'VALIDATE_DATA_PRG',
 *     step_name => 'VALIDATE_STEP',
 *     chain_name => 'DAILY_PROCESSING_CHAIN',
 *     step_type => 'PROGRAM',
 *     step_order => 2,
 *     enabled => 'TRUE',
 *     comments => 'Validate extracted data for consistency'
 *   );
 *   
 *   -- Add report generation step
 *   v_steps.EXTEND;
 *   v_steps(v_steps.LAST) := TYP_SCHED_CHAIN_STEPS(
 *     program_owner => 'HF_BATCH',
 *     program_name => 'GENERATE_REPORT_PRG',
 *     step_name => 'REPORT_STEP',
 *     chain_name => 'DAILY_PROCESSING_CHAIN',
 *     step_type => 'PROGRAM',
 *     step_order => 3,
 *     enabled => 'TRUE',
 *     comments => 'Generate processing reports'
 *   );
 * END;
 *
 * -- Use in procedures for bulk operations
 * PROCEDURE process_steps(p_steps IN TYP_SCHED_CHAIN_STEPS_SET) IS
 * BEGIN
 *   FOR i IN 1..p_steps.COUNT LOOP
 *     -- Process each step
 *     process_single_step(p_steps(i));
 *   END LOOP;
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_CHAIN_STEPS
 * - Chains: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 * - Rules: TYP_SCHED_CHAIN_RULES, TYP_SCHED_CHAIN_RULES_SET
 * - Programs: TYP_SCHED_PROGRAMS, TYP_SCHED_PROGRAMS_SET
 * - Views: V_BATCH_SCHED_CHAINS, V_BATCH_SCHED_RUNNING_CHAINS
 */

CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_CHAIN_STEPS_SET as table of TYP_SCHED_CHAIN_STEPS

/
