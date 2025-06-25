/**
 * Constraints: BATCH_CHAINS
 * Description: Defines database constraints for batch chain records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for batch chain records.
 *   - Maintain referential integrity with BATCH_COMPANIES.
 *   - Prevent orphaned chain records.
 */

-- Primary Key
ALTER TABLE BATCH_CHAINS 
ADD CONSTRAINT BATCH_CHAINS_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_CHAINS MODIFY (COMPANY_ID NOT NULL);
ALTER TABLE BATCH_CHAINS MODIFY (ID NOT NULL);

-- Foreign Key to BATCH_COMPANIES
ALTER TABLE BATCH_CHAINS ADD CONSTRAINT BATCH_CHAINS_COMPANY_FK 
    FOREIGN KEY (COMPANY_ID) REFERENCES BATCH_COMPANIES (ID); 
