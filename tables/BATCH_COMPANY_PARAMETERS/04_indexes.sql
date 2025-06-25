/**
 * Indexes: BATCH_COMPANY_PARAMETERS
 * Description: Indexes to improve query performance for company parameter lookups.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Speed up lookups by COMPANY_ID
 *   - Support efficient joins with BATCH_COMPANIES
 *   - Improve performance for parameter-based filtering and reporting
 */

-- Index for fast lookup by company
CREATE INDEX IDX_BCOMPANY_PARAM_COMPANY_ID
  ON BATCH_COMPANY_PARAMETERS (COMPANY_ID); 
