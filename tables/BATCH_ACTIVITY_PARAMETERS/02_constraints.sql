/**
 * Constraints: BATCH_ACTIVITY_PARAMETERS
 * Description: Defines database constraints for activity parameter definitions.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for parameter definitions.
 *   - Maintain referential integrity with the parent BATCH_ACTIVITIES table.
 *   - Prevent orphaned parameter definitions.
 */

-- Primary Key
ALTER TABLE BATCH_ACTIVITY_PARAMETERS ADD CONSTRAINT BATCH_ACTIVITY_PARAMETERS_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_ACTIVITY_PARAMETERS MODIFY ID NOT NULL;
ALTER TABLE BATCH_ACTIVITY_PARAMETERS MODIFY ACTIVITY_ID NOT NULL;

-- Foreign Key
ALTER TABLE BATCH_ACTIVITY_PARAMETERS ADD CONSTRAINT BATCH_ACTIVITY_PARAMETERS_ACTIVITY_FK
    FOREIGN KEY (ACTIVITY_ID) REFERENCES BATCH_ACTIVITIES (ID);

