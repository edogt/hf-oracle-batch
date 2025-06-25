/**
 * Indexes: BATCH_CHAIN_PROCESSES
 * Description: Indexes to improve query performance for chain-process relationship lookups.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Speed up lookups by CHAIN_ID and PROCESS_ID
 *   - Support efficient joins with BATCH_CHAINS and BATCH_PROCESSES
 *   - Improve performance for chain composition and execution queries
 */

-- Index for fast lookup by chain
CREATE INDEX IDX_BCHAIN_PROC_CHAIN_ID
  ON BATCH_CHAIN_PROCESSES (CHAIN_ID);

-- Index for fast lookup by process
CREATE INDEX IDX_BCHAIN_PROC_PROCESS_ID
  ON BATCH_CHAIN_PROCESSES (PROCESS_ID); 
