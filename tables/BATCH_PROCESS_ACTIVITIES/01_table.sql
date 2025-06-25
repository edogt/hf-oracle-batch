/**
 * Table: BATCH_PROCESS_ACTIVITIES
 * Description: Associates activities with batch processes, defining execution order and context.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Link activities to processes for batch execution flows
 *   - Define execution order and context for each activity within a process
 *   - Support audit, reporting, and orchestration of batch process activities
 *
 * Usage:
 *   - Referenced by execution and parameter tables
 *   - Used for process design, execution, and monitoring
 */

--------------------------------------------------------
--  DDL for Table BATCH_PROCESS_ACTIVITIES
--------------------------------------------------------

CREATE TABLE BATCH_PROCESS_ACTIVITIES (
    ID NUMBER(19,0) NOT NULL,
    PROCESS_ID NUMBER(19,0) NOT NULL,
    ACTIVITY_ID NUMBER(19,0) NOT NULL,
    EXECUTION_ORDER NUMBER(10,0),
    COMMENTS VARCHAR2(4000 CHAR),
    CREATED_BY VARCHAR2(255 CHAR),
    CREATED_DATE TIMESTAMP(6),
    STATE VARCHAR2(50 CHAR),
    UPDATED_BY VARCHAR2(255 CHAR),
    UPDATED_DATE TIMESTAMP(6)
);

-- Table comment
COMMENT ON TABLE BATCH_PROCESS_ACTIVITIES IS 'Defines the association between processes and activities, including execution order and relationship context for batch orchestration';

-- Column comments
COMMENT ON COLUMN BATCH_PROCESS_ACTIVITIES.ID IS 'Primary key identifier for the process-activity association';
COMMENT ON COLUMN BATCH_PROCESS_ACTIVITIES.PROCESS_ID IS 'Reference to the process that contains this activity';
COMMENT ON COLUMN BATCH_PROCESS_ACTIVITIES.ACTIVITY_ID IS 'Reference to the activity that is part of this process';
COMMENT ON COLUMN BATCH_PROCESS_ACTIVITIES.EXECUTION_ORDER IS 'Sequential order in which this activity should be executed within the process';
COMMENT ON COLUMN BATCH_PROCESS_ACTIVITIES.COMMENTS IS 'Additional configuration, dependencies, or context information for this process-activity relationship';
COMMENT ON COLUMN BATCH_PROCESS_ACTIVITIES.CREATED_BY IS 'User who created the process-activity association';
COMMENT ON COLUMN BATCH_PROCESS_ACTIVITIES.CREATED_DATE IS 'Date and time when the process-activity association was created';
COMMENT ON COLUMN BATCH_PROCESS_ACTIVITIES.STATE IS 'Current state of the process-activity relationship (ACTIVE, INACTIVE, DELETED)';
COMMENT ON COLUMN BATCH_PROCESS_ACTIVITIES.UPDATED_BY IS 'User who performed the last update to the process-activity association';
COMMENT ON COLUMN BATCH_PROCESS_ACTIVITIES.UPDATED_DATE IS 'Date and time of the last update to the process-activity association'; 
