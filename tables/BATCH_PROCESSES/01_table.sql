/**
 * Table: BATCH_PROCESSES
 * Description: Core entity defining batch processes within chains.
 *              Represents the intermediate level of batch orchestration,
 *              containing activities, configuration, and execution rules.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define batch processes within execution chains
 *   - Store process configuration and execution rules
 *   - Enable process-based activity orchestration
 *   - Support process scheduling and execution
 *   - Provide process context for monitoring and reporting
 *
 * Usage in PCK_BATCH_MANAGER:
 *   - Referenced by getProcessByCode() function for process retrieval
 *   - Used by process_execution_register() for execution initiation
 *   - Supports getProcessActivities() for activity orchestration
 *   - Enables process-based execution context and monitoring
 *   - Provides process configuration for execution rules
 *
 * Usage:
 *   - Referenced by BATCH_PROCESS_ACTIVITIES (process_id FK)
 *   - Referenced by BATCH_PROCESS_EXECUTIONS (process_id FK)
 *   - Referenced by BATCH_CHAIN_PROCESSES (process_id FK)
 *   - Used in monitoring views (V_BATCH_PROCESS_EXECUTIONS, V_BATCH_RUNNING_PROCESSES)
 *   - Supports process-based activity orchestration and execution
 */

CREATE TABLE BATCH_PROCESSES (
    ID                          NUMBER,
    NAME                        VARCHAR2(100),
    CODE                        VARCHAR2(50),
    DESCRIPTION                 VARCHAR2(4000),
    CONFIG                      VARCHAR2(4000),
    COMPANY_ID                  NUMBER,
    PROPAGATE_FAILED_STATE      VARCHAR2(3),
    CREATED_BY                  VARCHAR2(30),
    CREATED_DATE                DATE,
    UPDATED_BY                  VARCHAR2(30),
    UPDATED_DATE                DATE,
    RULES_SET                   CLOB
)
LOGGING;

-- Table comment
COMMENT ON TABLE BATCH_PROCESSES IS 'Core entity defining batch processes within execution chains';

-- Column comments
COMMENT ON COLUMN BATCH_PROCESSES.ID IS 'Primary key identifier for the process definition';
COMMENT ON COLUMN BATCH_PROCESSES.NAME IS 'Human-readable name of the process used for display, identification, and business communication';
COMMENT ON COLUMN BATCH_PROCESSES.CODE IS 'Unique business code identifier for the process, used for programmatic access, integration, and automation';
COMMENT ON COLUMN BATCH_PROCESSES.DESCRIPTION IS 'Detailed description of the process purpose, business logic, and expected execution behavior';
COMMENT ON COLUMN BATCH_PROCESSES.CONFIG IS 'JSON configuration string that stores process-specific settings, scheduling parameters, and execution behavior overrides';
COMMENT ON COLUMN BATCH_PROCESSES.COMPANY_ID IS 'Reference to the company that owns this process (FK to BATCH_COMPANIES). Determines multi-tenant access and company-specific execution context';
COMMENT ON COLUMN BATCH_PROCESSES.PROPAGATE_FAILED_STATE IS 'Failure propagation control: Y=process failure stops parent chain, N=chain execution continues despite process failure. Critical for error handling strategy';
COMMENT ON COLUMN BATCH_PROCESSES.CREATED_BY IS 'User who created the process definition';
COMMENT ON COLUMN BATCH_PROCESSES.CREATED_DATE IS 'Date and time when the process definition was created';
COMMENT ON COLUMN BATCH_PROCESSES.UPDATED_BY IS 'User who performed the last update to the process definition';
COMMENT ON COLUMN BATCH_PROCESSES.UPDATED_DATE IS 'Date and time of the last update to the process definition';
COMMENT ON COLUMN BATCH_PROCESSES.RULES_SET IS 'CLOB containing execution rules and business constraints in SimpleJSON format. Defines conditional logic, dependencies, and execution flow control';

