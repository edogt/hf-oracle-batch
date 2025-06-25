/**
 * Indexes: BATCH_ACTIVITY_EXECUTIONS
 * Description: Indexes to improve query performance and support efficient lookups for activity execution records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Speed up lookups by ACTIVITY_ID and CHAIN_EXECUTION_ID
 *   - Support efficient joins with BATCH_ACTIVITIES and BATCH_CHAIN_EXECUTIONS
 *   - Improve performance for execution monitoring and reporting
 */

-- Index for fast lookup by activity
CREATE INDEX IDX_BACT_EXEC_ACTIVITY
  ON BATCH_ACTIVITY_EXECUTIONS (ACTIVITY_ID);

-- Index for fast lookup by chain execution
CREATE INDEX IDX_BACT_EXEC_CHAIN
  ON BATCH_ACTIVITY_EXECUTIONS (CHAIN_EXECUTION_ID); 
