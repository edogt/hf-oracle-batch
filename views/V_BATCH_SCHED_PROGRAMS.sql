/**
 * View: V_BATCH_SCHED_PROGRAMS
 * Description: Oracle Scheduler programs information view for batch process monitoring.
 *              Provides comprehensive program configuration information including
 *              executable actions, parameters, and status for Oracle Scheduler program management.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor Oracle Scheduler program configurations and status
 *   - Provide program parameter and action information
 *   - Support program management and configuration analysis
 *   - Enable Oracle Scheduler program monitoring and reporting
 *
 * Query Description:
 *   - Uses PCK_BATCH_MONITOR.GET_SCHED_PROGRAMS function to retrieve Oracle Scheduler program information
 *   - Provides comprehensive program details including type, action, and parameter count
 *   - Enables monitoring of program configurations and status
 *   - Supports program management and troubleshooting operations
 *
 * Usage Examples:
 * 
 * -- Get all Oracle Scheduler programs
 * SELECT * FROM V_BATCH_SCHED_PROGRAMS 
 * ORDER BY PROGRAM_NAME;
 *
 * -- Get enabled programs
 * SELECT * FROM V_BATCH_SCHED_PROGRAMS 
 * WHERE ENABLED = 'TRUE'
 * ORDER BY PROGRAM_NAME;
 *
 * -- Get programs by type
 * SELECT PROGRAM_TYPE, COUNT(*) as program_count
 * FROM V_BATCH_SCHED_PROGRAMS 
 * GROUP BY PROGRAM_TYPE
 * ORDER BY program_count DESC;
 *
 * -- Get programs with parameters
 * SELECT * FROM V_BATCH_SCHED_PROGRAMS 
 * WHERE NUMBER_OF_ARGUMENTS > 0
 * ORDER BY NUMBER_OF_ARGUMENTS DESC;
 *
 * -- Get stored procedure programs
 * SELECT * FROM V_BATCH_SCHED_PROGRAMS 
 * WHERE PROGRAM_TYPE = 'STORED_PROCEDURE'
 * ORDER BY PROGRAM_NAME;
 *
 * -- Get program summary by type
 * SELECT PROGRAM_TYPE, COUNT(*) as total_programs,
 *        SUM(CASE WHEN ENABLED = 'TRUE' THEN 1 ELSE 0 END) as enabled_programs,
 *        AVG(NUMBER_OF_ARGUMENTS) as avg_arguments
 * FROM V_BATCH_SCHED_PROGRAMS 
 * GROUP BY PROGRAM_TYPE
 * ORDER BY total_programs DESC;
 *
 * -- Get programs with specific actions
 * SELECT * FROM V_BATCH_SCHED_PROGRAMS 
 * WHERE PROGRAM_ACTION LIKE '%BATCH%'
 * ORDER BY PROGRAM_NAME;
 *
 * -- Get complex programs (many arguments)
 * SELECT * FROM V_BATCH_SCHED_PROGRAMS 
 * WHERE NUMBER_OF_ARGUMENTS > 5
 * ORDER BY NUMBER_OF_ARGUMENTS DESC;
 *
 * Related Objects:
 * - Packages: PCK_BATCH_MONITOR (GET_SCHED_PROGRAMS function)
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_CHAIN_STEPS
 * - Types: TYP_SCHED_PROGRAMS, TYP_SCHED_PROGRAMS_SET
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SCHED_PROGRAMS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SCHED_PROGRAMS (
    PROGRAM_NAME,           -- Name of the Oracle Scheduler program
    PROGRAM_TYPE,           -- Type of program (STORED_PROCEDURE, PLSQL_BLOCK, etc.)
    PROGRAM_ACTION,         -- Action to be executed by the program
    NUMBER_OF_ARGUMENTS,    -- Number of arguments the program accepts
    ENABLED,                -- Program enabled status (TRUE/FALSE)
    COMMENTS                -- Program description and comments
) AS
select PROGRAM_NAME, PROGRAM_TYPE, PROGRAM_ACTION, NUMBER_OF_ARGUMENTS, ENABLED, COMMENTS 
from table(PCK_BATCH_MONITOR.get_sched_programs)
;
GRANT SELECT ON V_BATCH_SCHED_PROGRAMS TO ROLE_HF_BATCH;
