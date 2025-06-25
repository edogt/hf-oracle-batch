/**
 * Table: BATCH_COMPANIES
 * Description: Core company master data for multi-company batch processing operations.
 *              Serves as the central reference for company identification across all
 *              batch chains, processes, and activities.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Define companies for multi-tenant batch operations
 *   - Provide company context for all batch executions
 *   - Support company-specific parameter configurations
 *   - Enable company-based filtering and reporting
 *
 * Usage:
 *   - Referenced by BATCH_CHAINS (company_id FK)
 *   - Referenced by BATCH_PROCESSES (company_id FK)
 *   - Referenced by BATCH_ACTIVITIES (company_id FK)
 *   - Referenced by BATCH_COMPANY_PARAMETERS (company_id FK)
 *   - Used in all execution views for company context
 *   - Supports home company concept for default operations
 */

CREATE TABLE BATCH_COMPANIES (
    ID                          NUMBER,
    NAME                        VARCHAR2(100),
    CODE                        VARCHAR2(50),
    FISCAL_ID                   VARCHAR2(30),
    CONFIG                      VARCHAR2(4000),
    CREATED_BY                  VARCHAR2(30),
    CREATED_DATE                DATE,
    UPDATED_BY                  VARCHAR2(30),
    UPDATED_DATE                DATE
)
LOGGING;

-- Table comment
COMMENT ON TABLE BATCH_COMPANIES IS 'Core company master data for multi-company batch processing operations';

-- Column comments
COMMENT ON COLUMN BATCH_COMPANIES.ID IS 'Primary key identifier for the company entity';
COMMENT ON COLUMN BATCH_COMPANIES.NAME IS 'Legal business name of the company used for display, reporting, and business identification';
COMMENT ON COLUMN BATCH_COMPANIES.CODE IS 'Unique business code identifier for the company, used for programmatic access, integration, and multi-tenant operations';
COMMENT ON COLUMN BATCH_COMPANIES.FISCAL_ID IS 'Official fiscal identification number of the company (e.g., RUT in Chile, RFC in Mexico). Used for legal compliance and reporting';
COMMENT ON COLUMN BATCH_COMPANIES.CONFIG IS 'JSON configuration string that stores company-specific settings, business rules, and operational parameters for batch processing';
COMMENT ON COLUMN BATCH_COMPANIES.CREATED_BY IS 'User who created the company master record';
COMMENT ON COLUMN BATCH_COMPANIES.CREATED_DATE IS 'Date and time when the company master record was created';
COMMENT ON COLUMN BATCH_COMPANIES.UPDATED_BY IS 'User who performed the last update to the company master record';
COMMENT ON COLUMN BATCH_COMPANIES.UPDATED_DATE IS 'Date and time of the last update to the company master record'; 
