/**
 * Constraints: BATCH_PROCESSES
 * Description: Defines database constraints for batch process definitions.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for process definition records
 *   - Maintain referential integrity with BATCH_COMPANIES
 *   - Prevent null values in critical columns
 *   - Maintain process definition consistency
 */

-- Primary Key
ALTER TABLE BATCH_PROCESSES ADD CONSTRAINT BATCH_PROCESSES_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_PROCESSES MODIFY ID NOT NULL;
ALTER TABLE BATCH_PROCESSES MODIFY NAME NOT NULL;
ALTER TABLE BATCH_PROCESSES MODIFY CODE NOT NULL;

-- Foreign Key
ALTER TABLE BATCH_PROCESSES ADD CONSTRAINT BATCH_PROCESSES_COMPANY_FK 
    FOREIGN KEY (COMPANY_ID) REFERENCES BATCH_COMPANIES (ID);

