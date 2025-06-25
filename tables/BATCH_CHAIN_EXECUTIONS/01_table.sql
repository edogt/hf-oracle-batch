/**
 * Table: BATCH_CHAIN_EXECUTIONS
 * Description: Tracks the execution of batch chains.
 *              Records start/end times, execution states, and execution context
 *              for complete traceability of chain execution lifecycle.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Track chain execution lifecycle (start, running, finished, failed)
 *   - Record execution timing and performance metrics
 *   - Provide execution context for process and activity executions
 *   - Enable execution monitoring and reporting
 *   - Support execution history and audit trails
 *
 * Usage in PCK_BATCH_MANAGER:
 *   - Created by chain_execution_register() at chain start
 *   - Updated by chain_exec_end_register() at chain completion
 *   - Referenced by saveChainExecution() for CRUD operations
 *   - Used by setChainExecutionEndState() for state management
 *   - Provides context for process and activity executions
 *
 * Usage:
 *   - Referenced by BATCH_PROCESS_EXECUTIONS (chain_exec_id FK)
 *   - Referenced by BATCH_ACTIVITY_EXECUTIONS (chain_execution_id FK)
 *   - Referenced by BATCH_SIMPLE_LOG (chain_execution_id FK)
 *   - Used in monitoring views (V_BATCH_CHAIN_EXECUTIONS, V_BATCH_RUNNING_CHAINS)
 *   - Supports execution reporting and performance analysis
 */

--------------------------------------------------------
--  DDL for Table BATCH_CHAIN_EXECUTIONS
--------------------------------------------------------

CREATE TABLE BATCH_CHAIN_EXECUTIONS 
(
    ID NUMBER(19,0) NOT NULL,
    START_TIME TIMESTAMP(6),
    END_TIME TIMESTAMP(6),
    COMMENTS VARCHAR2(4000),
    STATE VARCHAR2(20),
    CHAIN_ID NUMBER(19,0) NOT NULL,
    EXECUTION_TYPE VARCHAR2(20),
    CREATED_BY VARCHAR2(255),
    CREATED_DATE TIMESTAMP(6),
    UPDATED_BY VARCHAR2(255),
    UPDATED_DATE TIMESTAMP(6)
);

-- Table comment
COMMENT ON TABLE BATCH_CHAIN_EXECUTIONS IS 'Tracks the execution of batch chains with timing and state information';

-- Column comments
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.ID IS 'Primary key identifier for the chain execution instance';
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.CHAIN_ID IS 'Reference to the chain definition that is being executed (FK to BATCH_CHAINS)';
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.STATE IS 'Current execution lifecycle state (running=active, finished=completed, failed=error, cancelled=stopped)';
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.EXECUTION_TYPE IS 'Execution trigger type that determines behavior and logging (manual=user-initiated, scheduled=automated, automated=system-triggered)';
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.START_TIME IS 'Precise timestamp when the chain execution began, used for performance measurement and timing analysis';
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.END_TIME IS 'Precise timestamp when the chain execution completed, used with START_TIME for duration calculation';
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.COMMENTS IS 'Execution context information, error details, or user-provided notes about the chain execution outcome';
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.CREATED_BY IS 'User or system process that initiated the chain execution';
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.CREATED_DATE IS 'Date and time when the chain execution record was created';
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.UPDATED_BY IS 'User or system process that performed the last update to the chain execution record';
COMMENT ON COLUMN BATCH_CHAIN_EXECUTIONS.UPDATED_DATE IS 'Date and time of the last update to the chain execution record'; 
