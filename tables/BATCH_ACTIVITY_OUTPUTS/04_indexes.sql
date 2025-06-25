/**
 * Indexes: BATCH_ACTIVITY_OUTPUTS
 * Description: Indexes to improve query performance and support efficient lookups for activity output records.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Speed up lookups by ACTIVITY_EXECUTION_ID
 *   - Support efficient joins with BATCH_ACTIVITY_EXECUTIONS
 *   - Improve performance for output processing and reporting
 */

-- Index for fast lookup by activity execution
CREATE INDEX IDX_BACT_OUT_EXEC_ID
  ON BATCH_ACTIVITY_OUTPUTS (ACTIVITY_EXECUTION_ID); 
