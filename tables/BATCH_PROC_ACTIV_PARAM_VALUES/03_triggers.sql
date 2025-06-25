/**
 * Trigger: BATCH_PROC_ACTIV_PARAM_VALUES_TRG
 * Description: Automatic audit trail management for process-activity parameter value records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Automatically set audit fields (CREATED_BY, CREATED_DATE, UPDATED_BY, UPDATED_DATE)
 *   - Ensure a consistent audit trail across all parameter value changes
 *   - Maintain data lineage and change tracking for parameter values
 */

CREATE OR REPLACE TRIGGER BATCH_PROC_ACTIV_PARAM_VALUES_TRG 
BEFORE INSERT OR UPDATE ON BATCH_PROC_ACTIV_PARAM_VALUES
REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :NEW.CREATED_BY   := USER;
        :NEW.CREATED_DATE := SYSDATE;
    END IF;
    :NEW.UPDATED_BY   := USER;
    :NEW.UPDATED_DATE := SYSDATE;
END;
/

ALTER TRIGGER BATCH_PROC_ACTIV_PARAM_VALUES_TRG ENABLE; 
