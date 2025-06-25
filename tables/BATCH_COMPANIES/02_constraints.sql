/**
 * Constraints: BATCH_COMPANIES
 * Description: Defines database constraints for company master data records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for company records.
 *   - Enforce uniqueness and not null constraints for key company fields.
 *   - Prevent orphaned or duplicate company records.
 */

-- Primary Key
ALTER TABLE BATCH_COMPANIES ADD CONSTRAINT BATCH_COMPANIES_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_COMPANIES MODIFY ID NOT NULL;
ALTER TABLE BATCH_COMPANIES MODIFY COMPANY_CODE NOT NULL;
ALTER TABLE BATCH_COMPANIES MODIFY COMPANY_NAME NOT NULL;

-- Unique Constraints
ALTER TABLE BATCH_COMPANIES ADD CONSTRAINT BATCH_COMPANIES_CODE_UK UNIQUE (COMPANY_CODE); 
