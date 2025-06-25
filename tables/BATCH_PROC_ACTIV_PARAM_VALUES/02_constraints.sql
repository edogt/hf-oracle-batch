/**
 * Constraints: BATCH_PROC_ACTIV_PARAM_VALUES
 * Description: Defines database constraints for process-activity parameter value records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for parameter value records.
 *   - Maintain referential integrity with BATCH_PROCESS_ACTIVITIES and BATCH_ACTIVITY_PARAMETERS.
 *   - Prevent orphaned or duplicate parameter value records.
 */

-- Primary Key
ALTER TABLE BATCH_PROC_ACTIV_PARAM_VALUES ADD CONSTRAINT BATCH_PROC_ACTIV_PARAM_VALUES_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_PROC_ACTIV_PARAM_VALUES MODIFY ID NOT NULL;

-- Foreign Key
ALTER TABLE BATCH_PROC_ACTIV_PARAM_VALUES ADD CONSTRAINT BATCH_PRCACTPRM_TO_ACTPRM_FK 
    FOREIGN KEY (ACTIVITY_PARAMETER_ID) REFERENCES BATCH_ACTIVITY_PARAMETERS (ID);

