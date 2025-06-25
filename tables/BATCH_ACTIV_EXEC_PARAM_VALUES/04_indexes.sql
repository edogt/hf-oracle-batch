/**
 * Indexes: BATCH_ACTIV_EXEC_PARAM_VALUES
 * Description: Indexes to improve query performance and support efficient joins for activity execution parameter values.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Speed up lookups by ACTIVITY_EXECUTION_ID and ACTIVITY_PARAMETER_ID
 *   - Support efficient joins with BATCH_ACTIVITY_EXECUTIONS and BATCH_ACTIVITY_PARAMETERS
 *   - Improve performance for audit and reporting queries
 */

-- Index for fast lookup by activity execution
CREATE INDEX IDX_BACT_ACTEXEC_ID
  ON BATCH_ACTIV_EXEC_PARAM_VALUES (ACTIVITY_EXECUTION_ID);

-- Index for fast lookup by activity parameter
CREATE INDEX IDX_BACT_ACTPRM_ID
  ON BATCH_ACTIV_EXEC_PARAM_VALUES (ACTIVITY_PARAMETER_ID);

-- Composite index for frequent queries involving both columns
CREATE INDEX IDX_BACT_ACTEXEC_PRM
  ON BATCH_ACTIV_EXEC_PARAM_VALUES (ACTIVITY_EXECUTION_ID, ACTIVITY_PARAMETER_ID); 
