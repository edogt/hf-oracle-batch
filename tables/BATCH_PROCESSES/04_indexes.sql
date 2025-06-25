/**
 * Indexes: BATCH_PROCESSES
 * Description: Supporting indexes for efficient access to batch process definitions.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Improve query performance for lookups by CODE and COMPANY_ID
 *   - Support foreign key relationships and reporting use cases
 *
 * Indexes:
 *   - IDX_PROCESSES_CODE: For filtering by CODE (unique process identifier)
 *   - IDX_PROCESSES_COMPANY_ID: For filtering by COMPANY_ID
 */

CREATE INDEX IDX_PROCESSES_CODE ON BATCH_PROCESSES (CODE);
CREATE INDEX IDX_PROCESSES_COMPANY_ID ON BATCH_PROCESSES (COMPANY_ID); 
