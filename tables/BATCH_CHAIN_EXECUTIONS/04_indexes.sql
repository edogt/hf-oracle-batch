/**
 * Indexes: BATCH_CHAIN_EXECUTIONS
 * Description: Indexes to improve query performance for chain execution lookups.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Speed up lookups by CHAIN_ID
 *   - Support efficient joins with BATCH_CHAINS
 *   - Improve performance for execution monitoring and reporting
 */

-- Index for fast lookup by chain
CREATE INDEX IDX_BCHAIN_EXEC_CHAIN_ID
  ON BATCH_CHAIN_EXECUTIONS (CHAIN_ID); 
