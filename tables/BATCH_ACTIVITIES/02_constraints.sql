/**
 * Constraints: BATCH_ACTIVITIES
 * Description: Defines the database constraints for the BATCH_ACTIVITIES table.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for activity definitions.
 *   - Enforce uniqueness of activity codes.
 *   - Prevent null values in critical columns.
 */

-- Primary Key
ALTER TABLE BATCH_ACTIVITIES ADD CONSTRAINT BATCH_ACTIVITIES_PK PRIMARY KEY (ID);

-- Unique Constraint
ALTER TABLE BATCH_ACTIVITIES ADD CONSTRAINT BATCH_ACTIVITIES_CODE_UK UNIQUE (CODE, COMPANY_ID);

-- Not Null Constraints
ALTER TABLE BATCH_ACTIVITIES MODIFY (
    NAME NOT NULL ENABLE,
    STATE NOT NULL ENABLE,
    COMPANY_ID NOT NULL ENABLE
);

-- Foreign Key to BATCH_COMPANIES
ALTER TABLE BATCH_ACTIVITIES ADD CONSTRAINT BATCH_ACTIVITIES_COMP_FK
    FOREIGN KEY (COMPANY_ID) REFERENCES BATCH_COMPANIES (ID) ENABLE;

-- Check constraint for STATE column
ALTER TABLE BATCH_ACTIVITIES ADD CONSTRAINT BATCH_ACTIVITIES_STATE_CK
    CHECK (STATE IN ('VALID', 'DEPRECATED', 'IN_DEVELOPMENT')) ENABLE;

