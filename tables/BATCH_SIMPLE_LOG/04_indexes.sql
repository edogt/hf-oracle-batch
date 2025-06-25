/**
 * Indexes: BATCH_SIMPLE_LOG
 * Description: Supporting indexes for efficient access to application log records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Improve query performance for log lookups by execution references and timestamp
 *   - Support foreign key relationships and reporting use cases
 *
 * Indexes:
 *   - IDX_SIMPLE_LOG_TIMESTAMP: For filtering by TIMESTAMP (most common query)
 *   - IDX_SIMPLE_LOG_TYPE: For filtering by log TYPE
 *   - IDX_SIMPLE_LOG_ACTIV_EXEC_ID: For filtering by ACTIVITY_EXECUTION_ID
 *   - IDX_SIMPLE_LOG_PROC_EXEC_ID: For filtering by PROCESS_EXECUTION_ID
 *   - IDX_SIMPLE_LOG_CHAIN_EXEC_ID: For filtering by CHAIN_EXECUTION_ID
 *   - IDX_SIMPLE_LOG_COMPANY_ID: For filtering by COMPANY_ID
 */

CREATE INDEX IDX_SIMPLE_LOG_TIMESTAMP ON BATCH_SIMPLE_LOG (TIMESTAMP);
CREATE INDEX IDX_SIMPLE_LOG_TYPE ON BATCH_SIMPLE_LOG (TYPE);
CREATE INDEX IDX_SIMPLE_LOG_ACTIV_EXEC_ID ON BATCH_SIMPLE_LOG (ACTIVITY_EXECUTION_ID);
CREATE INDEX IDX_SIMPLE_LOG_PROC_EXEC_ID ON BATCH_SIMPLE_LOG (PROCESS_EXECUTION_ID);
CREATE INDEX IDX_SIMPLE_LOG_CHAIN_EXEC_ID ON BATCH_SIMPLE_LOG (CHAIN_EXECUTION_ID);
CREATE INDEX IDX_SIMPLE_LOG_COMPANY_ID ON BATCH_SIMPLE_LOG (COMPANY_ID); 
