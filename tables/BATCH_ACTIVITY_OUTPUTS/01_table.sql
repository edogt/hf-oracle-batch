/**
 * Table: BATCH_ACTIVITY_OUTPUTS
 * Description: Stores output data and results from batch activity executions.
 *              Captures the actual output values, files, and results generated
 *              by activities during their execution.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store output data and results from activity executions
 *   - Enable output processing and file management
 *   - Support result tracking and analysis
 *   - Provide output context for reporting and monitoring
 *   - Allow output-based workflow decisions
 *
 * Usage in PCK_BATCH_MANAGER:
 *   - Processed by processActivityOutputs() procedure
 *   - Supports output file management (move_to, send_to)
 *   - Enables dynamic output processing with evaluateText()
 *   - Used for output directory configuration and file naming
 *   - Supports output-based notifications and routing
 *
 * Usage:
 *   - Referenced by BATCH_ACTIVITY_EXECUTIONS (activity_execution_id FK)
 *   - Referenced by BATCH_ACTIVITIES (activity_id FK)
 *   - Used for output processing and file management
 *   - Supports output-based workflow orchestration
 */

CREATE TABLE BATCH_ACTIVITY_OUTPUTS (
    ID NUMBER(19,0) NOT NULL,
    ACTIVITY_EXECUTION_ID NUMBER(19,0) NOT NULL,
    OUTPUT_KEY VARCHAR2(255 CHAR),
    OUTPUT_VALUE CLOB,
    OUTPUT_TYPE VARCHAR2(50 CHAR),
    COMMENTS VARCHAR2(4000 CHAR),
    CREATED_BY VARCHAR2(255 CHAR),
    CREATED_DATE TIMESTAMP(6),
    STATE VARCHAR2(50 CHAR),
    UPDATED_BY VARCHAR2(255 CHAR),
    UPDATED_DATE TIMESTAMP(6)
);

-- Table comment
COMMENT ON TABLE BATCH_ACTIVITY_OUTPUTS IS 'Stores output data and results from batch activity executions';

-- Column comments
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.ID IS 'Primary key identifier for the activity output record';
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.ACTIVITY_EXECUTION_ID IS 'Reference to the activity execution that generated this output (FK to BATCH_ACTIVITY_EXECUTIONS)';
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.OUTPUT_KEY IS 'Output identifier or key name used for output retrieval, processing, and workflow orchestration';
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.OUTPUT_VALUE IS 'Actual output data or result value generated by the activity execution, stored in CLOB format for large content';
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.OUTPUT_TYPE IS 'Output data type that determines processing behavior (TEXT=plain text, JSON=structured data, XML=markup, BINARY=binary data, FILE=file reference)';
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.COMMENTS IS 'Output description, processing instructions, or context information for downstream consumption';
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.CREATED_BY IS 'User or system process that created the output record';
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.CREATED_DATE IS 'Date and time when the output record was created';
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.STATE IS 'Output lifecycle state that controls processing and retention (ACTIVE=available, ARCHIVED=stored, DELETED=removed)';
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.UPDATED_BY IS 'User or system process that performed the last update to the output record';
COMMENT ON COLUMN BATCH_ACTIVITY_OUTPUTS.UPDATED_DATE IS 'Date and time of the last update to the output record';

