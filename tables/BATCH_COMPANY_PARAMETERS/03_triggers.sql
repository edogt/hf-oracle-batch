/**
 * Trigger: BATCH_COMPANY_PARAMETERS_TRG
 * Description: Automatic audit trail management for company parameter records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Automatically set audit fields (CREATED_BY, CREATED_DATE, UPDATED_BY, UPDATED_DATE)
 *   - Ensure a consistent audit trail across all parameter changes
 *   - Maintain data lineage and change tracking for company parameters
 */

--------------------------------------------------------
--  DDL for Trigger BATCH_COMPANY_PARAMETERS_TRG
--------------------------------------------------------

CREATE OR REPLACE TRIGGER BATCH_COMPANY_PARAMETERS_TRG 
BEFORE INSERT OR UPDATE ON BATCH_COMPANY_PARAMETERS
REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
/****************************************************************************************/
/* Descripción: Automatización de Procesos Batch                                        */
/*  SAR 5665, REQ 4909 Error 54309                                                      */
/****************************************************************************************/
BEGIN
    IF INSERTING THEN
        :NEW.CREATED_BY   := USER;
        :NEW.CREATED_DATE := SYSDATE;
    END IF;
    :NEW.UPDATED_BY   := USER;
    :NEW.UPDATED_DATE := SYSDATE;
END;
/

ALTER TRIGGER BATCH_COMPANY_PARAMETERS_TRG ENABLE; 
