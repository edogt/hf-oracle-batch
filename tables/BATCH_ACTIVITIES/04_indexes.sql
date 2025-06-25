/**
 * Indexes: BATCH_ACTIVITIES
 * Description: Indexes to improve query performance and support efficient lookups for batch activities.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Speed up lookups by CODE and COMPANY_ID
 *   - Support efficient joins with BATCH_COMPANIES
 *   - Improve performance for activity monitoring and reporting
 */

-- Index for fast lookup by activity code (within a company)
CREATE INDEX IDX_BACT_CODE_COMPANY
  ON BATCH_ACTIVITIES (CODE, COMPANY_ID);

-- Index for fast lookup by company
CREATE INDEX IDX_BACT_COMPANY
  ON BATCH_ACTIVITIES (COMPANY_ID); 
