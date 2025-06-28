/**
 * Type: TYP_SCHED_PROGRAMS
 * Description: Oracle Scheduler program definition type for batch process executable units.
 *              Represents program configurations that define the actual executable code,
 *              parameters, and execution environment for batch process steps.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define Oracle Scheduler program configurations
 *   - Support program-based batch process execution
 *   - Enable program parameter management and validation
 *   - Provide program execution environment configuration
 *
 * Usage Examples:
 * 
 * -- Create a program definition
 * DECLARE
 *   v_program TYP_SCHED_PROGRAMS;
 * BEGIN
 *   v_program := TYP_SCHED_PROGRAMS(
 *     owner => 'HF_BATCH',
 *     program_name => 'EXTRACT_DATA_PRG',
 *     program_type => 'STORED_PROCEDURE',
 *     program_action => 'PCK_BATCH_MANAGER.EXTRACT_DATA',
 *     number_of_arguments => 3,
 *     enabled => 'TRUE',
 *     comments => 'Extract data from source systems for daily processing'
 *   );
 * END;
 *
 * -- Use with collection type for multiple programs
 * DECLARE
 *   v_programs TYP_SCHED_PROGRAMS_SET;
 * BEGIN
 *   v_programs := TYP_SCHED_PROGRAMS_SET();
 *   v_programs.EXTEND;
 *   v_programs(v_programs.LAST) := TYP_SCHED_PROGRAMS(
 *     'HF_BATCH', 'VALIDATE_DATA_PRG', 'STORED_PROCEDURE',
 *     'PCK_BATCH_MANAGER.VALIDATE_DATA', 2, 'TRUE',
 *     'Validate extracted data for consistency and quality'
 *   );
 * END;
 *
 * Related Objects:
 * - Collection: TYP_SCHED_PROGRAMS_SET
 * - Steps: TYP_SCHED_CHAIN_STEPS, TYP_SCHED_CHAIN_STEPS_SET
 * - Jobs: TYP_SCHED_JOBS, TYP_SCHED_JOBS_SET
 * - Chains: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 * - Views: V_BATCH_SCHED_PROGRAMS, V_BATCH_SCHED_JOBS
 */

  CREATE OR REPLACE EDITIONABLE TYPE TYP_SCHED_PROGRAMS as object (
    owner               varchar2(128),                 -- Owner of the program
    program_name        varchar2(128),                 -- Name of the program
    program_type        varchar2(16),                  -- Type of program (STORED_PROCEDURE, PLSQL_BLOCK, etc.)
    program_action      varchar2(4000),                -- Action to be executed (procedure name, PL/SQL block, etc.)
    number_of_arguments number,                        -- Number of arguments the program accepts
    enabled             varchar2(5),                   -- Program enabled status (TRUE/FALSE)
    comments            varchar2(4000)                 -- Description and comments about the program
)

/
