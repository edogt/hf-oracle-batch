/**
 * Table: BATCH_SIMPLE_LOG
 * Description: Application logging table for batch processes.
 *              Records comprehensive log entries with references to executions.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Store application logs for batch processes, activities, and chains
 *   - Provide audit trail and debugging information
 *   - Support execution monitoring and troubleshooting
 *   - Enable log analysis and reporting
 *
 * Usage:
 *   - Referenced by execution monitoring and reporting views
 *   - Used for debugging and audit purposes
 *   - Supports log level filtering and analysis
 */

--------------------------------------------------------
--  DDL for Table BATCH_SIMPLE_LOG
--------------------------------------------------------

CREATE TABLE BATCH_SIMPLE_LOG (
    ID NUMBER NOT NULL,
    TEXT VARCHAR2(4000),
    DATA CLOB,
    TIMESTAMP TIMESTAMP(6),
    TYPE VARCHAR2(30),
    ACTIVITY_EXECUTION_ID NUMBER,
    PROCESS_EXECUTION_ID NUMBER,
    CHAIN_EXECUTION_ID NUMBER,
    COMPANY_ID NUMBER,
    CREATED_BY VARCHAR2(30),
    CREATED_DATE DATE,
    UPDATED_BY VARCHAR2(30),
    UPDATED_DATE DATE
);

-- Table comment
COMMENT ON TABLE BATCH_SIMPLE_LOG IS 'Application logging table for batch processes';

-- Column comments
COMMENT ON COLUMN BATCH_SIMPLE_LOG.ID IS 'Primary key identifier for the log record';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.TEXT IS 'Log message text';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.DATA IS 'Additional log data in CLOB format';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.TIMESTAMP IS 'Timestamp when the log entry was created';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.TYPE IS 'Log type (info, log, error, alert, etc.)';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.ACTIVITY_EXECUTION_ID IS 'Reference to activity execution (FK to BATCH_ACTIVITY_EXECUTIONS)';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.PROCESS_EXECUTION_ID IS 'Reference to process execution (FK to BATCH_PROCESS_EXECUTIONS)';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.CHAIN_EXECUTION_ID IS 'Reference to chain execution (FK to BATCH_CHAIN_EXECUTIONS)';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.COMPANY_ID IS 'Reference to company (FK to BATCH_COMPANIES)';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.CREATED_BY IS 'User who created the record';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.CREATED_DATE IS 'Date and time when the record was created';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.UPDATED_BY IS 'User who performed the last update';
COMMENT ON COLUMN BATCH_SIMPLE_LOG.UPDATED_DATE IS 'Date and time of the last update'; 
