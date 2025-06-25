/**
 * Trigger: BATCH_COMPANIES_TRG
 * Description: Automatic audit trail management for company master data records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Automatically set audit fields (CREATED_BY, CREATED_DATE, UPDATED_BY, UPDATED_DATE)
 *   - Ensure a consistent audit trail across all company changes
 *   - Maintain data lineage and change tracking for company records
 */

--------------------------------------------------------
--  DDL for Trigger BATCH_COMPANIES_TRG
--------------------------------------------------------

CREATE OR REPLACE TRIGGER BATCH_COMPANIES_TRG 
BEFORE INSERT OR UPDATE ON BATCH_COMPANIES
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

ALTER TRIGGER BATCH_COMPANIES_TRG ENABLE; 
