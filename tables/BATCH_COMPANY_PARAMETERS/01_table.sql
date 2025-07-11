/**
 * Table: BATCH_COMPANY_PARAMETERS
 *              Enables multi-tenant configuration management and company-specific behavior.
 *
 * Author: Eduardo Guti??rrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Enable multi-tenant batch processing with different settings per company
 *   - Support dynamic configuration changes without code modifications
 *   - Provide company-specific behavior control and customization
 *
 * Usage:
 *   - Referenced by all batch execution components for company-specific settings
 *   - Used for configuration management and multi-tenant operations
 */

--------------------------------------------------------
--  DDL for Table BATCH_COMPANY_PARAMETERS
--------------------------------------------------------

CREATE TABLE BATCH_COMPANY_PARAMETERS (
    ID NUMBER NOT NULL,
    COMPANY_ID NUMBER NOT NULL,
    PARAM_KEY VARCHAR2(100) NOT NULL,
    PARAM_VALUE VARCHAR2(4000),
    PARAM_TYPE VARCHAR2(50),
    COMMENTS VARCHAR2(4000),
    CREATED_BY VARCHAR2(30),
    CREATED_DATE DATE,
    STATE VARCHAR2(20),
    UPDATED_BY VARCHAR2(30),
    UPDATED_DATE DATE
);

-- Table comment
COMMENT ON TABLE BATCH_COMPANY_PARAMETERS IS 'Stores company-specific configuration parameters that control batch processing behavior and settings per company';

-- Column comments
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.ID IS 'Primary key identifier for the company parameter record';
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.COMPANY_ID IS 'Reference to the company that owns this parameter (FK to BATCH_COMPANIES)';
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.PARAM_KEY IS 'Parameter name/key used to identify the configuration setting';
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.PARAM_VALUE IS 'Parameter value that defines the configuration setting (max 4000 chars)';
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.PARAM_TYPE IS 'Data type of the parameter (STRING, NUMBER, BOOLEAN, JSON, etc.)';
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.COMMENTS IS 'Description of the parameter purpose and usage context';
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.CREATED_BY IS 'User who created the company parameter';
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.CREATED_DATE IS 'Date and time when the company parameter was created';
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.STATE IS 'Current state of the parameter (ACTIVE, INACTIVE, DELETED)';
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.UPDATED_BY IS 'User who performed the last update to the company parameter';
COMMENT ON COLUMN BATCH_COMPANY_PARAMETERS.UPDATED_DATE IS 'Date and time of the last update to the company parameter';
