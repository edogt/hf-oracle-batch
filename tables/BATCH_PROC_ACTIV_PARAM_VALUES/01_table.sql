/**
 * Table: BATCH_PROC_ACTIV_PARAM_VALUES
 * Description: Stores parameter values for process-activity executions.
 *              Links process-activity instances with their parameter values for execution.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store parameter values for each process-activity execution
 *   - Enable parameter injection and tracking during execution
 *   - Support audit and troubleshooting of parameter usage
 *   - Provide context for process-activity execution analysis
 *
 * Usage:
 *   - Referenced by BATCH_PROCESS_ACTIVITIES (process_activity_id FK)
 *   - Referenced by BATCH_ACTIVITY_PARAMETERS (activity_parameter_id FK)
 *   - Used for parameter value tracking and reporting
 */

--------------------------------------------------------
--  DDL for Table BATCH_PROC_ACTIV_PARAM_VALUES
--------------------------------------------------------

CREATE TABLE BATCH_PROC_ACTIV_PARAM_VALUES (
    ID NUMBER NOT NULL,
    PROCESS_ACTIVITY_ID NUMBER,
    ACTIVITY_PARAMETER_ID NUMBER,
    VALUE VARCHAR2(500),
    CREATED_BY VARCHAR2(30),
    CREATED_DATE DATE,
    UPDATED_BY VARCHAR2(30),
    UPDATED_DATE DATE
);

COMMENT ON TABLE BATCH_PROC_ACTIV_PARAM_VALUES IS 'Stores parameter values for process-activity executions, enabling dynamic parameter injection and execution context tracking';
COMMENT ON COLUMN BATCH_PROC_ACTIV_PARAM_VALUES.ID IS 'Primary key identifier for the parameter value record';
COMMENT ON COLUMN BATCH_PROC_ACTIV_PARAM_VALUES.PROCESS_ACTIVITY_ID IS 'Reference to the process-activity association that uses this parameter value';
COMMENT ON COLUMN BATCH_PROC_ACTIV_PARAM_VALUES.ACTIVITY_PARAMETER_ID IS 'Reference to the parameter definition that this value implements';
COMMENT ON COLUMN BATCH_PROC_ACTIV_PARAM_VALUES.VALUE IS 'Actual parameter value used during process-activity execution (max 500 chars)';
COMMENT ON COLUMN BATCH_PROC_ACTIV_PARAM_VALUES.CREATED_BY IS 'User who created the parameter value record';
COMMENT ON COLUMN BATCH_PROC_ACTIV_PARAM_VALUES.CREATED_DATE IS 'Date and time when the parameter value was created';
COMMENT ON COLUMN BATCH_PROC_ACTIV_PARAM_VALUES.UPDATED_BY IS 'User who performed the last update to the parameter value';
COMMENT ON COLUMN BATCH_PROC_ACTIV_PARAM_VALUES.UPDATED_DATE IS 'Date and time of the last parameter value update'; 
