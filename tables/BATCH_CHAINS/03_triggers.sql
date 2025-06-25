/**
 * Trigger: BATCH_CHAINS_TRG
 * Description: Automatic audit trail management for batch chain records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Automatically set audit fields (CREATED_BY, CREATED_DATE, UPDATED_BY, UPDATED_DATE)
 *   - Ensure a consistent audit trail across all chain changes
 *   - Maintain data lineage and change tracking for batch chains
 */

--------------------------------------------------------
--  DDL for Trigger BATCH_CHAINS_TRG
--------------------------------------------------------

CREATE OR REPLACE TRIGGER BATCH_CHAINS_TRG 
BEFORE INSERT OR UPDATE ON BATCH_CHAINS
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

ALTER TRIGGER BATCH_CHAINS_TRG ENABLE;
