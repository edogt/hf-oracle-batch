/**
 * Table: BATCH_ACTIVITY_EXECUTIONS
 * Description: Execution tracking and lifecycle management for individual batch activities.
 *              Records the complete execution history of activity instances,
 *              including timing, status transitions, and execution context.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Track individual activity execution lifecycle from start to completion
 *   - Provide execution context for activity parameter values and outputs
 *   - Enable activity-level execution monitoring and audit trails
 *   - Support execution status management and error handling
 *   - Maintain execution history for performance analysis and troubleshooting
 *
 * Usage in PCK_BATCH_MANAGER:
 *   - Created by activity_execution_register() function
 *   - Updated by activity_exec_end_register() procedure
 *   - Managed by saveActivityExecution() procedure
 *   - Referenced by BATCH_ACTIV_EXEC_PARAM_VALUES for parameter tracking
 *   - Referenced by BATCH_ACTIVITY_OUTPUTS for result storage
 *   - Supports simulation mode execution tracking
 *   - Enables execution rollback and cleanup operations
 *
 * Usage:
 *   - Referenced by BATCH_ACTIV_EXEC_PARAM_VALUES (activity_execution_id FK)
 *   - Referenced by BATCH_ACTIVITY_OUTPUTS (activity_execution_id FK)
 *   - Referenced by BATCH_SIMPLE_LOG (activity_execution_id FK)
 *   - Used in all activity execution views for monitoring
 *   - Links to BATCH_ACTIVITIES (activity_id FK) and BATCH_PROCESS_EXECUTIONS (process_exec_id FK)
 */

CREATE TABLE BATCH_ACTIVITY_EXECUTIONS (
    ID                          NUMBER,
    ACTIVITY_ID                 NUMBER,
    EXECUTION_TYPE              VARCHAR2(20),
    EXECUTION_STATE             VARCHAR2(10),
    START_TIME                  TIMESTAMP(6),
    END_TIME                    TIMESTAMP(6),
    COMMENTS                    VARCHAR2(4000),
    PROCESS_EXEC_ID             NUMBER,
    AUDIT_INFO                  VARCHAR2(4000),
    PROCESS_ACTIVITY_ID         NUMBER,
    CREATED_BY                  VARCHAR2(30),
    CREATED_DATE                DATE,
    UPDATED_BY                  VARCHAR2(30),
    UPDATED_DATE                DATE
)
LOGGING;

-- Table comment
COMMENT ON TABLE BATCH_ACTIVITY_EXECUTIONS IS 'Tracks the execution lifecycle and history of individual batch activities';

-- Column comments
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.ID IS 'Primary key identifier for the activity execution instance';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.ACTIVITY_ID IS 'Reference to the activity definition that is being executed (FK to BATCH_ACTIVITIES)';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.EXECUTION_TYPE IS 'Execution mode that determines behavior and logging level (NORMAL=production, SIMULATION=testing, TEST=validation)';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.EXECUTION_STATE IS 'Current execution lifecycle state (RUNNING=active, FINISHED=completed, ERROR=failed, CANCELLED=stopped)';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.START_TIME IS 'Precise timestamp when the activity execution began, used for performance measurement and timing analysis';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.END_TIME IS 'Precise timestamp when the activity execution completed, used with START_TIME for duration calculation';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.COMMENTS IS 'Execution context information, error details, or user-provided notes about the execution outcome';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.PROCESS_EXEC_ID IS 'Reference to the parent process execution that orchestrated this activity (FK to BATCH_PROCESS_EXECUTIONS)';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.AUDIT_INFO IS 'JSON-structured audit trail containing execution details, parameter values, and system state information';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.PROCESS_ACTIVITY_ID IS 'Reference to the process-activity relationship that defined this execution context (FK to BATCH_PROCESS_ACTIVITIES)';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.CREATED_BY IS 'User or system process that initiated the activity execution';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.CREATED_DATE IS 'Date and time when the activity execution record was created';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.UPDATED_BY IS 'User or system process that performed the last update to the execution record';
COMMENT ON COLUMN BATCH_ACTIVITY_EXECUTIONS.UPDATED_DATE IS 'Date and time of the last update to the activity execution record'; 
