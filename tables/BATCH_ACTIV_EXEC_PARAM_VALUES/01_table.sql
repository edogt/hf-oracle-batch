/**
 * Table: BATCH_ACTIV_EXEC_PARAM_VALUES
 * Description: Stores actual parameter values used during activity execution.
 *              Captures the runtime parameter values that were applied to
 *              specific activity executions, enabling execution replay and audit.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store runtime parameter values for activity executions
 *   - Enable execution replay with exact parameter values
 *   - Provide audit trail of parameter usage
 *   - Support execution debugging and troubleshooting
 *   - Allow parameter value analysis across executions
 *
 * Usage in PCK_BATCH_MGR_CHAINS:
 *   - Referenced by add_activ_exec_param_value() procedure
 *   - Used to store parameter values during chain execution
 *   - Enables parameter tracking across chain activities
 *
 * Usage:
 *   - Populated during activity execution via add_activ_exec_param_value()
 *   - Referenced by BATCH_ACTIVITY_PARAMETERS (FK activity_parameter_id)
 *   - Links to BATCH_ACTIVITY_EXECUTIONS (FK activity_execution_id)
 *   - Enables parameter value tracking across multiple executions
 */

CREATE TABLE BATCH_ACTIV_EXEC_PARAM_VALUES (
    ID NUMBER NOT NULL,
    ACTIVITY_EXECUTION_ID NUMBER,
    ACTIVITY_PARAMETER_ID NUMBER,
    VALUE VARCHAR2(500),
    CREATED_BY VARCHAR2(30),
    CREATED_DATE DATE,
    UPDATED_BY VARCHAR2(30),
    UPDATED_DATE DATE
);

-- Table comment
COMMENT ON TABLE BATCH_ACTIV_EXEC_PARAM_VALUES IS 'Stores actual parameter values used during activity execution';

-- Column comments
COMMENT ON COLUMN BATCH_ACTIV_EXEC_PARAM_VALUES.ID IS 'Primary key identifier for the activity execution parameter value record';
COMMENT ON COLUMN BATCH_ACTIV_EXEC_PARAM_VALUES.ACTIVITY_EXECUTION_ID IS 'Reference to the activity execution that used this parameter value (FK to BATCH_ACTIVITY_EXECUTIONS)';
COMMENT ON COLUMN BATCH_ACTIV_EXEC_PARAM_VALUES.ACTIVITY_PARAMETER_ID IS 'Reference to the parameter definition that this value implements (FK to BATCH_ACTIVITY_PARAMETERS)';
COMMENT ON COLUMN BATCH_ACTIV_EXEC_PARAM_VALUES.VALUE IS 'Actual parameter value that was used during this specific activity execution (max 500 chars)';
COMMENT ON COLUMN BATCH_ACTIV_EXEC_PARAM_VALUES.CREATED_BY IS 'User or system process that created the parameter value record';
COMMENT ON COLUMN BATCH_ACTIV_EXEC_PARAM_VALUES.CREATED_DATE IS 'Date and time when the parameter value record was created';
COMMENT ON COLUMN BATCH_ACTIV_EXEC_PARAM_VALUES.UPDATED_BY IS 'User or system process that performed the last update to the parameter value record';
COMMENT ON COLUMN BATCH_ACTIV_EXEC_PARAM_VALUES.UPDATED_DATE IS 'Date and time of the last update to the parameter value record'; 
