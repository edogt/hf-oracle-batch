/**
 * Indexes: BATCH_ACTIVITY_PARAMETERS
 * Description: Indexes to improve query performance for activity parameter lookups.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Speed up lookups by ACTIVITY_ID, as parameters are always queried in the context of an activity.
 *   - Support efficient joins with BATCH_ACTIVITIES.
 */

-- Index for fast lookup by activity
CREATE INDEX IDX_BACT_PARAM_ACTIVITY_ID
  ON BATCH_ACTIVITY_PARAMETERS (ACTIVITY_ID); 
