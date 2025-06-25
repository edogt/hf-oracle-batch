/**
 * Table: BATCH_CHAIN_PROCESSES
 * Description: Defines the relationship between chains and processes.
 *              Maps processes to chains with execution order and dependency
 *              information for orchestrated batch execution.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Associate processes with chains for orchestrated execution
 *   - Define execution order and dependencies between processes
 *   - Enable chain-based process scheduling and coordination
 *   - Support process dependency management within chains
 *   - Provide chain composition and structure definition
 *
 * Usage in PCK_BATCH_MANAGER:
 *   - Referenced by getChainProcesses() function for chain execution
 *   - Used by add_process_to_chain() for chain composition
 *   - Supports ordered process execution within chains
 *   - Enables dependency-based process scheduling
 *   - Provides chain structure for execution orchestration
 *
 * Usage:
 *   - Referenced by BATCH_CHAINS (chain_id FK)
 *   - Referenced by BATCH_PROCESSES (process_id FK)
 *   - Used for chain execution orchestration
 *   - Supports process dependency management
 *   - Enables chain composition and structure definition
 */



CREATE TABLE BATCH_CHAIN_PROCESSES (
    ID NUMBER(19,0) NOT NULL,
    CHAIN_ID NUMBER(19,0) NOT NULL,
    PROCESS_ID NUMBER(19,0) NOT NULL,
    EXECUTION_ORDER NUMBER(10,0),
    COMMENTS VARCHAR2(4000),
    CREATED_BY VARCHAR2(255),
    CREATED_DATE TIMESTAMP(6),
    STATE VARCHAR2(50),
    UPDATED_BY VARCHAR2(255),
    UPDATED_DATE TIMESTAMP(6)
);

-- Table comment
COMMENT ON TABLE BATCH_CHAIN_PROCESSES IS 'Defines the relationship between chains and processes with execution order';

-- Column comments
COMMENT ON COLUMN BATCH_CHAIN_PROCESSES.ID IS 'Primary key identifier for the chain-process association';
COMMENT ON COLUMN BATCH_CHAIN_PROCESSES.CHAIN_ID IS 'Reference to the chain that contains this process (FK to BATCH_CHAINS)';
COMMENT ON COLUMN BATCH_CHAIN_PROCESSES.PROCESS_ID IS 'Reference to the process that is part of this chain (FK to BATCH_PROCESSES)';
COMMENT ON COLUMN BATCH_CHAIN_PROCESSES.EXECUTION_ORDER IS 'Sequential order in which this process should be executed within the chain, used for orchestration';
COMMENT ON COLUMN BATCH_CHAIN_PROCESSES.STATE IS 'Current state of the chain-process relationship (ACTIVE=included, INACTIVE=disabled, DELETED=removed)';
COMMENT ON COLUMN BATCH_CHAIN_PROCESSES.COMMENTS IS 'Additional configuration, dependencies, or context information for this chain-process relationship';
COMMENT ON COLUMN BATCH_CHAIN_PROCESSES.CREATED_BY IS 'User who created the chain-process association';
COMMENT ON COLUMN BATCH_CHAIN_PROCESSES.CREATED_DATE IS 'Date and time when the chain-process association was created';
COMMENT ON COLUMN BATCH_CHAIN_PROCESSES.UPDATED_BY IS 'User who performed the last update to the chain-process association';
COMMENT ON COLUMN BATCH_CHAIN_PROCESSES.UPDATED_DATE IS 'Date and time of the last update to the chain-process association';

