/**
 * Constraints: BATCH_SIMPLE_LOG
 * Description: Defines database constraints for application logging records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for log records
 *   - Maintain referential integrity with execution and company tables
 *   - Prevent null values in critical columns
 *   - Maintain logging consistency
 */

-- Primary Key
ALTER TABLE BATCH_SIMPLE_LOG ADD CONSTRAINT BATCH_SIMPLE_LOG_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_SIMPLE_LOG MODIFY ID NOT NULL;
ALTER TABLE BATCH_SIMPLE_LOG MODIFY TEXT NOT NULL;
ALTER TABLE BATCH_SIMPLE_LOG MODIFY TIMESTAMP NOT NULL;
ALTER TABLE BATCH_SIMPLE_LOG MODIFY TYPE NOT NULL;

-- Foreign Keys
ALTER TABLE BATCH_SIMPLE_LOG ADD CONSTRAINT BATCH_LOG_TO_ACTIV_EXEC_FK 
    FOREIGN KEY (ACTIVITY_EXECUTION_ID) REFERENCES BATCH_ACTIVITY_EXECUTIONS (ID);
ALTER TABLE BATCH_SIMPLE_LOG ADD CONSTRAINT BATCH_LOG_TO_CHAIN_EXEC_FK 
    FOREIGN KEY (CHAIN_EXECUTION_ID) REFERENCES BATCH_CHAIN_EXECUTIONS (ID);
ALTER TABLE BATCH_SIMPLE_LOG ADD CONSTRAINT BATCH_LOG_TO_COMPANY_FK 
    FOREIGN KEY (COMPANY_ID) REFERENCES BATCH_COMPANIES (ID);
ALTER TABLE BATCH_SIMPLE_LOG ADD CONSTRAINT BATCH_LOG_TO_PROC_EXEC_FK 
    FOREIGN KEY (PROCESS_EXECUTION_ID) REFERENCES BATCH_PROCESS_EXECUTIONS (ID); 
