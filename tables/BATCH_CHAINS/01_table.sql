/**
 * Table: BATCH_CHAINS
 * Description: Core entity defining batch execution chains.
 *              Represents the highest level of batch orchestration,
 *              containing processes, configuration, and execution rules.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define batch execution chains and workflows
 *   - Store chain configuration and execution rules
 *   - Enable chain-based process orchestration
 *   - Support chain scheduling and execution
 *   - Provide chain context for monitoring and reporting
 *
 * Usage in PCK_BATCH_MANAGER:
 *   - Referenced by getChainByCode() function for chain retrieval
 *   - Used by chain_execution_register() for execution initiation
 *   - Supports getChainProcesses() for process orchestration
 *   - Enables chain-based execution context and monitoring
 *   - Provides chain configuration for execution rules
 *
 * Usage:
 *   - Referenced by BATCH_CHAIN_PROCESSES (chain_id FK)
 *   - Referenced by BATCH_CHAIN_EXECUTIONS (chain_id FK)
 *   - Referenced by BATCH_SCHED_CHAIN_RULES (chain_id FK)
 *   - Referenced by BATCH_SCHED_CHAIN_STEPS (chain_id FK)
 *   - Used in monitoring views (V_BATCH_CHAIN_EXECUTIONS, V_BATCH_RUNNING_CHAINS)
 *   - Supports chain-based process orchestration and execution
 */

CREATE TABLE BATCH_CHAINS (
    ID                          NUMBER,
    NAME                        VARCHAR2(100),
    CODE                        VARCHAR2(50),
    DESCRIPTION                 VARCHAR2(4000),
    CONFIG                      VARCHAR2(4000),
    COMPANY_ID                  NUMBER,
    CREATED_BY                  VARCHAR2(30),
    CREATED_DATE                DATE,
    UPDATED_BY                  VARCHAR2(30),
    UPDATED_DATE                DATE,
    RULES_SET                   CLOB
)
LOGGING;

-- Table comment
COMMENT ON TABLE BATCH_CHAINS IS 'Core entity defining batch execution chains and workflows';

-- Column comments
COMMENT ON COLUMN BATCH_CHAINS.ID IS 'Primary key identifier for the chain definition';
COMMENT ON COLUMN BATCH_CHAINS.NAME IS 'Human-readable name of the chain used for display, identification, and business communication';
COMMENT ON COLUMN BATCH_CHAINS.CODE IS 'Unique business code identifier for the chain, used for programmatic access, integration, and automation';
COMMENT ON COLUMN BATCH_CHAINS.DESCRIPTION IS 'Detailed description of the chain purpose, business workflow, and expected execution behavior';
COMMENT ON COLUMN BATCH_CHAINS.CONFIG IS 'JSON configuration string that stores chain-specific settings, scheduling parameters, and execution behavior overrides';
COMMENT ON COLUMN BATCH_CHAINS.COMPANY_ID IS 'Reference to the company that owns this chain (FK to BATCH_COMPANIES). Determines multi-tenant access and company-specific execution context';
COMMENT ON COLUMN BATCH_CHAINS.CREATED_BY IS 'User who created the chain definition';
COMMENT ON COLUMN BATCH_CHAINS.CREATED_DATE IS 'Date and time when the chain definition was created';
COMMENT ON COLUMN BATCH_CHAINS.UPDATED_BY IS 'User who performed the last update to the chain definition';
COMMENT ON COLUMN BATCH_CHAINS.UPDATED_DATE IS 'Date and time of the last update to the chain definition';
COMMENT ON COLUMN BATCH_CHAINS.RULES_SET IS 'CLOB containing execution rules and business constraints in SimpleJSON format. Defines conditional logic, dependencies, and execution flow control';
