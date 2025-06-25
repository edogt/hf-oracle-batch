/**
 * Constraints: BATCH_ACTIVITY_OUTPUTS
 * Description: Database constraints for activity output storage.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for activity output records
 *   - Maintain referential integrity with activity executions
 *   - Prevent orphaned output records
 */

-- Primary Key
ALTER TABLE BATCH_ACTIVITY_OUTPUTS ADD CONSTRAINT BATCH_ACTIVITY_OUTPUTS_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_ACTIVITY_OUTPUTS MODIFY ID NOT NULL;
ALTER TABLE BATCH_ACTIVITY_OUTPUTS MODIFY ACTIVITY_EXECUTION_ID NOT NULL;

-- Foreign Key
ALTER TABLE BATCH_ACTIVITY_OUTPUTS ADD CONSTRAINT BATCH_ACTIVITY_OUTPUTS_EXEC_FK 
    FOREIGN KEY (ACTIVITY_EXECUTION_ID) REFERENCES BATCH_ACTIVITY_EXECUTIONS (ID);

ALTER TABLE BATCH_ACTIVITY_OUTPUTS ADD CONSTRAINT BATCH_ACTOUT_TO_ACTIVITY_FK 
    FOREIGN KEY (ACTIVITY_ID) REFERENCES BATCH_ACTIVITIES (ID); 
