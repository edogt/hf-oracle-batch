/**
 * Constraints: BATCH_CHAIN_EXECUTIONS
 * Description: Defines database constraints for chain execution records.
 *
 * Author: Eduardo Guti??rrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Ensure data integrity for chain execution records.
 *   - Maintain referential integrity with the parent BATCH_CHAINS table.
 *   - Prevent orphaned execution records.
 */

-- Primary Key
ALTER TABLE BATCH_CHAIN_EXECUTIONS 
ADD CONSTRAINT BATCH_CHAIN_EXECUTIONS_PK PRIMARY KEY (ID);

-- Not Null Constraints
ALTER TABLE BATCH_CHAIN_EXECUTIONS MODIFY (CHAIN_ID NOT NULL);
ALTER TABLE BATCH_CHAIN_EXECUTIONS MODIFY (ID NOT NULL);

-- Foreign Key to BATCH_CHAINS
ALTER TABLE BATCH_CHAIN_EXECUTIONS ADD CONSTRAINT BATCH_CHAIN_EXECUTIONS_CHAIN_FK 
    FOREIGN KEY (CHAIN_ID) REFERENCES BATCH_CHAINS (ID);
