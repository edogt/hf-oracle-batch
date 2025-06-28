/**
 * Type: TYP_SCHED_PROGRAMS_SET
 * Description: Collection type for Oracle Scheduler program definitions.
 *              Provides a table structure to manage multiple program configurations
 *              for batch process executable units and workflow orchestration.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store collections of Oracle Scheduler program definitions
 *   - Enable bulk operations on multiple program configurations
 *   - Support program management and workflow orchestration
 *   - Facilitate batch process executable unit management
 *
 * Usage Examples:
 * 
 * -- Create and populate a program collection
 * DECLARE
 *   v_programs TYP_SCHED_PROGRAMS_SET;
 * BEGIN
 *   v_programs := TYP_SCHED_PROGRAMS_SET();
 *   
 *   -- Add data extraction program
 *   v_programs.EXTEND;
 *   v_programs(v_programs.LAST) := TYP_SCHED_PROGRAMS(
 *     owner => 'HF_BATCH',
 *     program_name => 'EXTRACT_DATA_PRG',
 *     program_type => 'STORED_PROCEDURE',
 *     program_action => 'PCK_BATCH_MANAGER.EXTRACT_DATA',
 *     number_of_arguments => 3,
 *     enabled => 'TRUE',
 *     comments => 'Extract data from source systems for processing'
 *   );
 *   
 *   -- Add data validation program
 *   v_programs.EXTEND;
 *   v_programs(v_programs.LAST) := TYP_SCHED_PROGRAMS(
 *     owner => 'HF_BATCH',
 *     program_name => 'VALIDATE_DATA_PRG',
 *     program_type => 'STORED_PROCEDURE',
 *     program_action => 'PCK_BATCH_MANAGER.VALIDATE_DATA',
 *     number_of_arguments => 2,
 *     enabled => 'TRUE',
 *     comments => 'Validate extracted data for consistency and quality'
 *   );
 *   
 *   -- Add report generation program
 *   v_programs.EXTEND;
 *   v_programs(v_programs.LAST) := TYP_SCHED_PROGRAMS(
 *     owner => 'HF_BATCH',
 *     program_name => 'GENERATE_REPORT_PRG',
 *     program_type => 'STORED_PROCEDURE',
 *     program_action => 'PCK_BATCH_MANAGER.GENERATE_REPORT',
 *     number_of_arguments => 4,
 *     enabled => 'TRUE',
 *     comments => 'Generate reports from processed data'
 *   );
 * END;
 *
 * -- Use in procedures for bulk operations
 * PROCEDURE process_programs(p_programs IN TYP_SCHED_PROGRAMS_SET) IS
 * BEGIN
 *   FOR i IN 1..p_programs.COUNT LOOP
 *     -- Process each program
 *     process_single_program(p_programs(i));
 *   END LOOP;
 * END;
 *
 * Related Objects:
 * - Element Type: TYP_SCHED_PROGRAMS
 * - Steps: TYP_SCHED_CHAIN_STEPS, TYP_SCHED_CHAIN_STEPS_SET
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Chains: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 * - Views: V_BATCH_SCHED_PROGRAMS, V_BATCH_SCHED_JOBS
 */

CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_PROGRAMS_SET as table of TYP_SCHED_PROGRAMS

/
