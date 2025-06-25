/**
 * Indexes: BATCH_PROCESS_ACTIVITIES
 * Description: Supporting indexes for efficient access to process-activity associations.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Improve query performance for lookups by PROCESS_ID and ACTIVITY_ID
 *   - Support foreign key relationships and reporting use cases
 *
 * Indexes:
 *   - IDX_PROC_ACTIV_PROC_ID: For filtering by PROCESS_ID
 *   - IDX_PROC_ACTIV_ACT_ID: For filtering by ACTIVITY_ID
 */

CREATE INDEX IDX_PROC_ACTIV_PROC_ID ON BATCH_PROCESS_ACTIVITIES (PROCESS_ID);
CREATE INDEX IDX_PROC_ACTIV_ACT_ID ON BATCH_PROCESS_ACTIVITIES (ACTIVITY_ID); 
