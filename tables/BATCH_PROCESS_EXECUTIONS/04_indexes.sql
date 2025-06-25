/**
 * Indexes: BATCH_PROCESS_EXECUTIONS
 * Description: Supporting indexes for efficient access to process execution records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Improve query performance for lookups by PROCESS_ID and CHAIN_EXEC_ID
 *   - Support foreign key relationships and reporting use cases
 *
 * Indexes:
 *   - IDX_PROC_EXEC_PROC_ID: For filtering by PROCESS_ID
 *   - IDX_PROC_EXEC_CHAIN_EXEC_ID: For filtering by CHAIN_EXEC_ID
 */

CREATE INDEX IDX_PROC_EXEC_PROC_ID ON BATCH_PROCESS_EXECUTIONS (PROCESS_ID);
CREATE INDEX IDX_PROC_EXEC_CHAIN_EXEC_ID ON BATCH_PROCESS_EXECUTIONS (CHAIN_EXEC_ID); 
