/**
 * Constraints: BATCH_COMPANY_PARAMETERS
 * Description: Defines database constraints for company parameter records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for company parameter records.
 *   - Maintain referential integrity with BATCH_COMPANIES.
 *   - Prevent orphaned or duplicate parameter records.
 */

-- Primary Key
ALTER TABLE BATCH_COMPANY_PARAMETERS ADD CONSTRAINT BATCH_COMPANY_PARAMETERS_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_COMPANY_PARAMETERS MODIFY ID NOT NULL;
ALTER TABLE BATCH_COMPANY_PARAMETERS MODIFY COMPANY_ID NOT NULL;

-- Foreign Key
ALTER TABLE BATCH_COMPANY_PARAMETERS ADD CONSTRAINT BATCH_COMPANY_PARAMETERS_COMPANY_FK 
    FOREIGN KEY (COMPANY_ID) REFERENCES BATCH_COMPANIES (ID); 
