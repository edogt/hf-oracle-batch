/**
 * Table: BATCH_ACTIVITIES
 * Description: Core entity defining executable batch activities and their configurations.
 *              Represents the lowest-level executable units in the batch processing
 *              hierarchy that perform actual work operations.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define executable activities within batch chains and processes
 *   - Store activity configurations, parameters, and execution settings
 *   - Enable activity-based execution orchestration
 *   - Support activity parameter management and validation
 *   - Provide activity context for execution tracking
 *
 * Usage in PCK_BATCH_MANAGER:
 *   - Referenced by getActivityByCode(), getActivityById(), getActivityByAction()
 *   - Used for activity execution context and parameter resolution
 *   - Supports activity-based output directory configuration
 *   - Enables activity-specific parameter injection and validation
 *   - Links to BATCH_ACTIVITY_EXECUTIONS for execution tracking
 *
 * Usage:
 *   - Referenced by BATCH_ACTIVITY_EXECUTIONS (activity_id FK)
 *   - Referenced by BATCH_ACTIVITY_PARAMETERS (activity_id FK)
 *   - Referenced by BATCH_ACTIVITY_OUTPUTS (activity_id FK)
 *   - Referenced by BATCH_PROCESS_ACTIVITIES (activity_id FK)
 *   - Used in all activity execution views and monitoring
 */

CREATE TABLE BATCH_ACTIVITIES (
    ID                          NUMBER,
    NAME                        VARCHAR2(100),
    CODE                        VARCHAR2(50),
    DESCRIPTION                 VARCHAR2(4000),
    ACTION                      VARCHAR2(500),
    COMPANY_ID                  NUMBER,
    CONFIG                      VARCHAR2(4000),
    STATE                       VARCHAR2(10),
    PROPAGATE_FAILED_STATE      VARCHAR2(3),
    CREATED_BY                  VARCHAR2(30),
    CREATED_DATE                DATE,
    UPDATED_BY                  VARCHAR2(30),
    UPDATED_DATE                DATE
)
LOGGING;

-- Table comment
COMMENT ON TABLE BATCH_ACTIVITIES IS 'Stores the definition of a reusable activity that can be part of one or more processes. An activity is the minimum unit of execution in the system.';

-- Column comments
COMMENT ON COLUMN BATCH_ACTIVITIES.ID IS 'Primary key identifier for the activity definition';
COMMENT ON COLUMN BATCH_ACTIVITIES.NAME IS 'Human-readable name of the activity used for display and identification';
COMMENT ON COLUMN BATCH_ACTIVITIES.CODE IS 'Unique business code identifier for the activity, used for programmatic access and integration';
COMMENT ON COLUMN BATCH_ACTIVITIES.DESCRIPTION IS 'Detailed description of the activity purpose, business logic, and expected behavior';
COMMENT ON COLUMN BATCH_ACTIVITIES.ACTION IS 'PL/SQL procedure call specification that defines the actual work performed by this activity (e.g., ''MY_PACKAGE.MY_PROCEDURE''). Executed dynamically by the Batch Manager during activity execution';
COMMENT ON COLUMN BATCH_ACTIVITIES.COMPANY_ID IS 'Reference to the company that owns this activity (FK to BATCH_COMPANIES). Determines multi-tenant access and company-specific behavior';
COMMENT ON COLUMN BATCH_ACTIVITIES.CONFIG IS 'JSON configuration string that stores activity-specific settings, parameters, and behavior overrides. Enables flexible configuration without schema changes';
COMMENT ON COLUMN BATCH_ACTIVITIES.STATE IS 'Activity lifecycle state that controls execution eligibility (VALID=executable, DEPRECATED=legacy, IN_DEVELOPMENT=testing). Only VALID activities are executed by the Batch Manager';
COMMENT ON COLUMN BATCH_ACTIVITIES.PROPAGATE_FAILED_STATE IS 'Failure propagation control: Y=activity failure stops parent process/chain, N=execution continues despite activity failure. Critical for error handling strategy';
COMMENT ON COLUMN BATCH_ACTIVITIES.CREATED_BY IS 'User who created the activity definition';
COMMENT ON COLUMN BATCH_ACTIVITIES.CREATED_DATE IS 'Date and time when the activity definition was created';
COMMENT ON COLUMN BATCH_ACTIVITIES.UPDATED_BY IS 'User who performed the last update to the activity definition';
COMMENT ON COLUMN BATCH_ACTIVITIES.UPDATED_DATE IS 'Date and time of the last update to the activity definition';
