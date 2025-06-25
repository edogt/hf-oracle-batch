/**
 * Constraints: BATCH_PROCESS_ACTIVITIES
 * Description: Defines database constraints for process-activity associations.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for process-activity relationships
 *   - Maintain referential integrity with BATCH_PROCESSES and BATCH_ACTIVITIES
 *   - Prevent orphaned or duplicate associations
 */

--------------------------------------------------------
--  Constraints for Table BATCH_PROCESS_ACTIVITIES
--------------------------------------------------------

-- Primary Key
ALTER TABLE BATCH_PROCESS_ACTIVITIES ADD CONSTRAINT BATCH_PROCESS_ACTIVITIES_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_PROCESS_ACTIVITIES MODIFY ID NOT NULL;
ALTER TABLE BATCH_PROCESS_ACTIVITIES MODIFY PROCESS_ID NOT NULL;
ALTER TABLE BATCH_PROCESS_ACTIVITIES MODIFY ACTIVITY_ID NOT NULL;

-- Foreign Keys
ALTER TABLE BATCH_PROCESS_ACTIVITIES ADD CONSTRAINT BATCH_PROCESS_ACTIVITIES_PROCESS_FK 
    FOREIGN KEY (PROCESS_ID) REFERENCES BATCH_PROCESSES (ID);
ALTER TABLE BATCH_PROCESS_ACTIVITIES ADD CONSTRAINT BATCH_PROCESS_ACTIVITIES_ACTIVITY_FK 
    FOREIGN KEY (ACTIVITY_ID) REFERENCES BATCH_ACTIVITIES (ID);

