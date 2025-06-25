/**
 * Table: BATCH_ACTIVITY_PARAMETERS
 * Description: Defines parameter specifications for batch activities.
 *              Stores parameter definitions including types, positions,
 *              default values, and validation rules for activity execution.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define parameter specifications for activities
 *   - Store parameter types, positions, and default values
 *   - Enable parameter validation and type checking
 *   - Support parameter injection during activity execution
 *   - Provide parameter context for execution tracking
 *
 * Usage in PCK_BATCH_MANAGER:
 *   - Referenced by getActivityParametersList() function
 *   - Used for parameter validation against definitions
 *   - Supports parameter type checking with isValidValueDefinition()
 *   - Enables parameter injection during activity execution
 *   - Links to BATCH_ACTIV_EXEC_PARAM_VALUES for runtime values
 *
 * Usage:
 *   - Referenced by BATCH_ACTIV_EXEC_PARAM_VALUES (activity_parameter_id FK)
 *   - Referenced by BATCH_PROC_ACTIV_PARAM_VALUES (activity_parameter_id FK)
 *   - Referenced by BATCH_ACTIVITIES (activity_id FK)
 *   - Used for parameter validation and type checking
 *   - Supports parameter-based activity configuration
 */

CREATE TABLE BATCH_ACTIVITY_PARAMETERS (
    ID NUMBER(19,0) NOT NULL,
    ACTIVITY_ID NUMBER(19,0) NOT NULL,
    NAME VARCHAR2(255),
    TYPE VARCHAR2(50),
    POSITION NUMBER(10,0),
    DESCRIPTION VARCHAR2(4000),
    DEFAULT_VALUE VARCHAR2(4000),
    CREATED_BY VARCHAR2(255),
    CREATED_DATE TIMESTAMP(6),
    STATE VARCHAR2(50),
    UPDATED_BY VARCHAR2(255),
    UPDATED_DATE TIMESTAMP(6)
);

-- Table comment
COMMENT ON TABLE BATCH_ACTIVITY_PARAMETERS IS 'Defines parameter specifications for batch activities';

-- Column comments
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.ID IS 'Primary key identifier for the activity parameter definition';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.ACTIVITY_ID IS 'Reference to the activity that defines this parameter (FK to BATCH_ACTIVITIES)';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.NAME IS 'Parameter name or identifier used for parameter injection and execution context';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.TYPE IS 'Parameter data type that determines validation rules and value handling (VARCHAR2, NUMBER, DATE, CLOB)';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.POSITION IS 'Parameter position in the activity procedure signature, used for correct parameter ordering during execution';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.DESCRIPTION IS 'Detailed description of the parameter purpose, business logic, and expected value format';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.DEFAULT_VALUE IS 'Default value or value definition expression used when no explicit value is provided during execution';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.CREATED_BY IS 'User who created the activity parameter definition';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.CREATED_DATE IS 'Date and time when the activity parameter definition was created';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.STATE IS 'Parameter lifecycle state that controls usage (ACTIVE=available, INACTIVE=disabled, DELETED=removed)';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.UPDATED_BY IS 'User who performed the last update to the activity parameter definition';
COMMENT ON COLUMN BATCH_ACTIVITY_PARAMETERS.UPDATED_DATE IS 'Date and time of the last update to the activity parameter definition';
