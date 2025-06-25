/**
 * Constraints: BATCH_PROCESS_EXECUTIONS
 * Description: Defines the database constraints for the BATCH_PROCESS_EXECUTIONS table.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for process execution records
 *   - Enforce referential integrity with related tables
 *   - Prevent null values in critical columns
 *   - Maintain execution tracking consistency
 */

--------------------------------------------------------
--  Constraints for Table BATCH_PROCESS_EXECUTIONS
--------------------------------------------------------

-- Primary Key
ALTER TABLE BATCH_PROCESS_EXECUTIONS ADD CONSTRAINT BATCH_PROCESS_EXECUTIONS_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_PROCESS_EXECUTIONS MODIFY ID NOT NULL;

-- Foreign Keys
ALTER TABLE BATCH_PROCESS_EXECUTIONS ADD CONSTRAINT BATCH_PROC_EXEC_TO_CHN_EXEC_FK 
    FOREIGN KEY (CHAIN_EXEC_ID) REFERENCES BATCH_CHAIN_EXECUTIONS (ID);
ALTER TABLE BATCH_PROCESS_EXECUTIONS ADD CONSTRAINT BATCH_PROC_EXEC_TO_PROCESS_FK 
    FOREIGN KEY (PROCESS_ID) REFERENCES BATCH_PROCESSES (ID);

