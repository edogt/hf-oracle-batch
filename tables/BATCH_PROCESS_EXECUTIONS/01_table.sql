/**
 * Table: BATCH_PROCESS_EXECUTIONS
 * Description: Execution tracking and lifecycle management for batch processes.
 *              Records the complete execution history of process instances,
 *              including timing, status transitions, and execution context.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Track individual process execution lifecycle from start to completion
 *   - Provide execution context for process activities and outputs
 *   - Enable process-level execution monitoring and audit trails
 *   - Support execution status management and error handling
 *   - Maintain execution history for performance analysis and troubleshooting
 *
 * Usage in PCK_BATCH_MANAGER:
 *   - Created by process_execution_register() function
 *   - Updated by process_exec_end_register() procedure
 *   - Managed by saveProcessExecution() procedure
 *   - Referenced by BATCH_ACTIVITY_EXECUTIONS for activity tracking
 *   - Supports simulation mode execution tracking
 *   - Enables execution rollback and cleanup operations
 *
 * Usage:
 *   - Referenced by BATCH_ACTIVITY_EXECUTIONS (process_exec_id FK)
 *   - Referenced by BATCH_SIMPLE_LOG (process_execution_id FK)
 *   - Used in all process execution views for monitoring
 *   - Links to BATCH_PROCESSES (process_id FK) and BATCH_CHAIN_EXECUTIONS (chain_exec_id FK)
 */

--------------------------------------------------------
--  DDL for Table BATCH_PROCESS_EXECUTIONS
--------------------------------------------------------

CREATE TABLE BATCH_PROCESS_EXECUTIONS (
    ID NUMBER NOT NULL,
    PROCESS_ID NUMBER,
    EXECUTION_TYPE VARCHAR2(20),
    EXECUTION_STATE VARCHAR2(10),
    START_TIME TIMESTAMP(6),
    END_TIME TIMESTAMP(6),
    COMMENTS VARCHAR2(4000),
    CHAIN_EXEC_ID NUMBER,
    CREATED_BY VARCHAR2(30),
    CREATED_DATE DATE,
    UPDATED_BY VARCHAR2(30),
    UPDATED_DATE DATE
)
LOGGING;

COMMENT ON TABLE BATCH_PROCESS_EXECUTIONS IS 'Tracks the execution lifecycle and history of individual batch processes';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.ID IS 'Primary key identifier for the process execution';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.PROCESS_ID IS 'The process definition being executed (FK to BATCH_PROCESSES)';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.EXECUTION_TYPE IS 'Type of execution (e.g., NORMAL, SIMULATION, TEST)';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.EXECUTION_STATE IS 'Current state of the execution (e.g., RUNNING, FINISHED, ERROR)';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.START_TIME IS 'Timestamp when the process execution started';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.END_TIME IS 'Timestamp when the process execution ended';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.COMMENTS IS 'Optional comments about the execution, often used for error messages';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.CHAIN_EXEC_ID IS 'Parent chain execution that triggered this process (FK to BATCH_CHAIN_EXECUTIONS)';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.CREATED_BY IS 'User who created the record';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.CREATED_DATE IS 'Date and time when the record was created';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.UPDATED_BY IS 'User who performed the last update';
COMMENT ON COLUMN BATCH_PROCESS_EXECUTIONS.UPDATED_DATE IS 'Date and time of the last update';
