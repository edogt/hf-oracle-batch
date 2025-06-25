/**
 * Indexes: BATCH_PROC_ACTIV_PARAM_VALUES
 * Description: Supporting indexes for efficient access to process-activity parameter values.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Improve query performance for parameter value lookups by process-activity and parameter.
 *   - Support foreign key relationships and reporting use cases.
 *
 * Indexes:
 *   - IDX_PRCACTPRMVAL_PROC_ACT_ID: For filtering by PROCESS_ACTIVITY_ID
 *   - IDX_PRCACTPRMVAL_ACT_PRM_ID: For filtering by ACTIVITY_PARAMETER_ID
 */

CREATE INDEX IDX_PRCACTPRMVAL_PROC_ACT_ID ON BATCH_PROC_ACTIV_PARAM_VALUES (PROCESS_ACTIVITY_ID);
CREATE INDEX IDX_PRCACTPRMVAL_ACT_PRM_ID ON BATCH_PROC_ACTIV_PARAM_VALUES (ACTIVITY_PARAMETER_ID); 
