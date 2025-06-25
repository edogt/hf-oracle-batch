/**
 * Trigger: BATCH_SIMPLE_LOG_TRG
 * Description: Automatic audit trail management for application log records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Automatically set audit fields (CREATED_BY, CREATED_DATE, UPDATED_BY, UPDATED_DATE)
 *   - Ensure a consistent audit trail across all log changes
 *   - Maintain data lineage and change tracking for log entries
 */

CREATE OR REPLACE TRIGGER BATCH_SIMPLE_LOG_TRG 
BEFORE INSERT OR UPDATE ON BATCH_SIMPLE_LOG
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

ALTER TRIGGER BATCH_SIMPLE_LOG_TRG ENABLE; 
