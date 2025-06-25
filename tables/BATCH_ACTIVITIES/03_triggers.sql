/**
 * Trigger: BATCH_ACTIVITIES_TRG
 * Description: Automatic audit trail management for batch activities.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Automatically set audit fields (CREATED_BY, CREATED_DATE, UPDATED_BY, UPDATED_DATE)
 *   - Ensure consistent audit trail across all activity changes
 *   - Maintain data lineage and change tracking
 */

CREATE OR REPLACE TRIGGER BATCH_ACTIVITIES_TRG 
BEFORE INSERT OR UPDATE ON BATCH_ACTIVITIES
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

ALTER TRIGGER BATCH_ACTIVITIES_TRG ENABLE; 
