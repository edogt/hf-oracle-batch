/**
 * View: V_BATCH_ACTIVITY_EXECUTIONS
 * Description: Comprehensive view of batch activity executions with hierarchical information.
 *              Provides a complete picture of activity execution status, timing, and context
 *              including related process, chain, and company information for monitoring and reporting.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor activity execution status and performance
 *   - Provide hierarchical view of activity-process-chain relationships
 *   - Support execution time analysis and reporting
 *   - Enable activity execution tracking across companies
 *
 * Query Description:
 *   - Joins activity executions with activities, processes, chains, and companies
 *   - Calculates elapsed time for running and completed executions
 *   - Orders results by execution state (running first) and start time (descending)
 *   - Provides complete context for each activity execution
 *
 * Usage Examples:
 * 
 * -- Get all running activity executions
 * SELECT * FROM V_BATCH_ACTIVITY_EXECUTIONS 
 * WHERE EXECUTION_STATE = 'RUNNING';
 *
 * -- Get activity executions for a specific company
 * SELECT * FROM V_BATCH_ACTIVITY_EXECUTIONS 
 * WHERE COMPANIA_NOMBRE = 'ACME Corp'
 * ORDER BY START_TIME DESC;
 *
 * -- Get long-running activities (> 30 minutes)
 * SELECT * FROM V_BATCH_ACTIVITY_EXECUTIONS 
 * WHERE EXECUTION_STATE = 'RUNNING' 
 * AND START_TIME < SYSTIMESTAMP - INTERVAL '0 0:30:0' DAY TO SECOND;
 *
 * -- Get activity execution summary by company
 * SELECT COMPANIA_NOMBRE, COUNT(*) as total_executions,
 *        SUM(CASE WHEN EXECUTION_STATE = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
 *        SUM(CASE WHEN EXECUTION_STATE = 'FAILED' THEN 1 ELSE 0 END) as failed
 * FROM V_BATCH_ACTIVITY_EXECUTIONS 
 * GROUP BY COMPANIA_NOMBRE;
 *
 * Related Objects:
 * - Tables: BATCH_ACTIVITY_EXECUTIONS, BATCH_ACTIVITIES, BATCH_PROCESS_EXECUTIONS
 * - Tables: BATCH_PROCESSES, BATCH_COMPANIES, BATCH_CHAIN_EXECUTIONS, BATCH_CHAINS
 * - Views: V_BATCH_ACTIVS_LAST_EXECS, V_BATCH_RUNNING_ACTIVITIES
 * - Packages: PCK_BATCH_MGR_ACTIVITIES, PCK_BATCH_MONITOR
 */

--------------------------------------------------------
--  DDL for View V_BATCH_ACTIVITY_EXECUTIONS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_ACTIVITY_EXECUTIONS (
    ID,                    -- Unique execution identifier
    ACTIVITY_ID,           -- Reference to the activity being executed
    EXECUTION_TYPE,        -- Type of execution (MANUAL, SCHEDULED, etc.)
    EXECUTION_STATE,       -- Current state (RUNNING, COMPLETED, FAILED, etc.)
    START_TIME,            -- Execution start timestamp
    END_TIME,              -- Execution end timestamp (null if running)
    COMMENTS,              -- Execution comments and notes
    PROCESS_EXEC_ID,       -- Reference to parent process execution
    AUDIT_INFO,            -- Audit information and metadata
    PROCESS_ACTIVITY_ID,   -- Reference to process-activity relationship
    TIEMPO_TRANSCURRIDO,   -- Calculated elapsed time (formatted string)
    ACTIVIDAD_ID,          -- Activity identifier
    ACTIVIDAD_CODIGO,      -- Activity code for identification
    ACTIVIDAD_DESCRIPCION, -- Activity description and name
    PROCESO_ID,            -- Process identifier
    PROCESO_CODIGO,        -- Process code for identification
    PROCESO_NOMBRE,        -- Process name and description
    CHAIN_EXEC_ID,         -- Chain execution identifier
    CADENA_ID,             -- Chain identifier
    CADENA_CODIGO,         -- Chain code for identification
    CADENA_DESCRIPCION,    -- Chain description and name
    COMPANIA_ID,           -- Company identifier
    COMPANIA_NOMBRE        -- Company name
) AS
select ax.ID, ax.ACTIVITY_ID, ax.EXECUTION_TYPE, ax.EXECUTION_STATE, ax.START_TIME, ax.END_TIME, ax.COMMENTS, ax.PROCESS_EXEC_ID, ax.AUDIT_INFO, ax.PROCESS_ACTIVITY_ID,
to_char(extract(DAY FROM NVL(ax.end_time, systimestamp) - ax.start_time), 'fmS99999') || ' ' ||
to_char(extract(HOUR FROM NVL(ax.end_time, systimestamp) - ax.start_time), 'fm00') || ':' ||
to_char(extract(MINUTE FROM NVL(ax.end_time, systimestamp) - ax.start_time), 'fm00') || ':' ||
to_char(extract(SECOND FROM NVL(ax.end_time, systimestamp) - ax.start_time), 'fm00.000')
AS
tiempo_transcurrido,
a.id AS actividad_id, a.code AS actividad_codigo, a.name AS actividad_descripcion, p.id AS proceso_id, p.code AS proceso_codigo, p.name AS proceso_nombre, cx.id AS chain_exec_id, ch.id AS cadena_id, ch.code AS cadena_codigo, ch.description AS cadena_descripcion, cp.id AS compania_id, cp.name AS compania_nombre
FROM batch_activity_executions ax
JOIN batch_activities a
ON   ax.activity_id = a.id
LEFT JOIN batch_process_executions px
ON ax.process_exec_id = px.id
LEFT JOIN batch_processes p
ON px.process_id = p.id
JOIN batch_companies cp
ON a.company_id = cp.id
LEFT JOIN batch_chain_executions cx
ON px.chain_exec_id = cx.id
LEFT JOIN batch_chains ch
ON cx.chain_id = ch.id
order by decode(ax.execution_state,'running',1,2) asc, ax.start_time desc
;
GRANT SELECT ON V_BATCH_ACTIVITY_EXECUTIONS TO ROLE_BATCH_MAN;
