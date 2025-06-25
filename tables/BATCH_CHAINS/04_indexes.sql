/**
 * Indexes: BATCH_CHAINS
 * Description: Indexes to improve query performance for batch chain lookups.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Speed up lookups by CODE and COMPANY_ID
 *   - Support efficient joins with BATCH_COMPANIES
 *   - Improve performance for chain retrieval and monitoring
 */

-- Index for fast lookup by chain code (within a company)
CREATE INDEX IDX_BCHAIN_CODE_COMPANY
  ON BATCH_CHAINS (CODE, COMPANY_ID);

-- Index for fast lookup by company
CREATE INDEX IDX_BCHAIN_COMPANY
  ON BATCH_CHAINS (COMPANY_ID); 
