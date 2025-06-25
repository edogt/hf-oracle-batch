/**
 * Constraints: BATCH_ACTIV_EXEC_PARAM_VALUES
 * Description: Database constraints for activity execution parameter values.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for parameter value storage
 *   - Maintain referential integrity with parameter definitions
 *   - Prevent orphaned parameter value records
 */

-- Primary Key
ALTER TABLE BATCH_ACTIV_EXEC_PARAM_VALUES ADD CONSTRAINT BATCH_ACTIV_EXEC_PARAM_VALUES_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_ACTIV_EXEC_PARAM_VALUES MODIFY ID NOT NULL;

-- Foreign Key to Activity Parameter Definition
ALTER TABLE BATCH_ACTIV_EXEC_PARAM_VALUES ADD CONSTRAINT BATCH_ACTIV_EXEC_PARAM_VALUES_ACTPRM_FK 
    FOREIGN KEY (ACTIVITY_PARAMETER_ID) REFERENCES BATCH_ACTIVITY_PARAMETERS (ID);

-- Foreign Key to Activity Execution
ALTER TABLE BATCH_ACTIV_EXEC_PARAM_VALUES ADD CONSTRAINT BATCH_ACTIV_EXEC_PARAM_VALUES_ACTEXEC_FK 
    FOREIGN KEY (ACTIVITY_EXECUTION_ID) REFERENCES BATCH_ACTIVITY_EXECUTIONS (ID);

