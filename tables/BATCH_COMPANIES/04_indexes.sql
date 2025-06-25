/**
 * Indexes: BATCH_COMPANIES
 * Description: Indexes to improve query performance for company lookups.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Speed up lookups by COMPANY_CODE
 *   - Support efficient joins with related tables
 *   - Improve performance for company-based filtering and reporting
 */

-- Index for fast lookup by company code
CREATE INDEX IDX_BCOMPANY_CODE
  ON BATCH_COMPANIES (COMPANY_CODE); 
