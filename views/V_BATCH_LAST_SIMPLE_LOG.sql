/**
 * View: V_BATCH_LAST_SIMPLE_LOG
 * Description: Comprehensive batch system logging view with hierarchical context.
 *              Provides access to all batch system log entries with complete
 *              source information including parent relationships and company context.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Provide comprehensive access to batch system log entries
 *   - Support hierarchical log analysis with parent-child relationships
 *   - Enable company-based log filtering and reporting
 *   - Support system-wide logging and troubleshooting
 *
 * Query Description:
 *   - Direct access to BATCH_SIMPLE_LOG table with all log attributes
 *   - Provides complete log context including source hierarchy and company information
 *   - Enables comprehensive log analysis and reporting across the entire system
 *   - Supports troubleshooting and audit trail analysis
 *
 * Usage Examples:
 * 
 * -- Get all log entries
 * SELECT * FROM V_BATCH_LAST_SIMPLE_LOG 
 * ORDER BY LOG_TIME DESC;
 *
 * -- Get recent log entries (last 24 hours)
 * SELECT * FROM V_BATCH_LAST_SIMPLE_LOG 
 * WHERE LOG_TIME > SYSTIMESTAMP - INTERVAL '1' DAY
 * ORDER BY LOG_TIME DESC;
 *
 * -- Get error logs only
 * SELECT * FROM V_BATCH_LAST_SIMPLE_LOG 
 * WHERE LOG_LEVEL = 'ERROR'
 * ORDER BY LOG_TIME DESC;
 *
 * -- Get logs for a specific company
 * SELECT * FROM V_BATCH_LAST_SIMPLE_LOG 
 * WHERE LOG_SOURCE_COMPANY_NAME = 'ACME Corp'
 * ORDER BY LOG_TIME DESC;
 *
 * -- Get logs by source type
 * SELECT LOG_SOURCE_TYPE, COUNT(*) as log_count,
 *        COUNT(DISTINCT LOG_SOURCE_ID) as unique_sources
 * FROM V_BATCH_LAST_SIMPLE_LOG 
 * GROUP BY LOG_SOURCE_TYPE
 * ORDER BY log_count DESC;
 *
 * -- Get logs with parent context
 * SELECT * FROM V_BATCH_LAST_SIMPLE_LOG 
 * WHERE LOG_SOURCE_PARENT_ID IS NOT NULL
 * ORDER BY LOG_TIME DESC;
 *
 * -- Get log summary by level and company
 * SELECT LOG_LEVEL, LOG_SOURCE_COMPANY_NAME, COUNT(*) as log_count
 * FROM V_BATCH_LAST_SIMPLE_LOG 
 * GROUP BY LOG_LEVEL, LOG_SOURCE_COMPANY_NAME
 * ORDER BY LOG_SOURCE_COMPANY_NAME, LOG_LEVEL;
 *
 * Related Objects:
 * - Tables: BATCH_SIMPLE_LOG
 * - Views: V_BATCH_SIMPLE_LOG (filtered view)
 * - Packages: PCK_BATCH_MGR_LOG, PCK_BATCH_LOGGER
 * - Types: BATCH_LOGGER, BATCH_SIMPLE_LOG_OBJ
 */

--------------------------------------------------------
--  DDL for View V_BATCH_LAST_SIMPLE_LOG
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_LAST_SIMPLE_LOG (
    ID,                    -- Unique log entry identifier
    LOG_TIME,              -- Log entry timestamp
    LOG_TYPE,              -- Type of log entry
    LOG_MESSAGE,           -- Log message text
    LOG_DETAILS,           -- Detailed log information
    LOG_LEVEL,             -- Log level (INFO, WARNING, ERROR, etc.)
    LOG_SOURCE,            -- Source of the log entry
    LOG_SOURCE_TYPE,       -- Type of the source (CHAIN, PROCESS, ACTIVITY, etc.)
    LOG_SOURCE_ID,         -- Source identifier
    LOG_SOURCE_NAME,       -- Source name
    LOG_SOURCE_CODE,       -- Source code
    LOG_SOURCE_PARENT_ID,  -- Parent source identifier
    LOG_SOURCE_PARENT_NAME, -- Parent source name
    LOG_SOURCE_PARENT_CODE, -- Parent source code
    LOG_SOURCE_PARENT_TYPE, -- Parent source type
    LOG_SOURCE_COMPANY_ID,  -- Company identifier
    LOG_SOURCE_COMPANY_NAME, -- Company name
    LOG_SOURCE_COMPANY_CODE -- Company code
) AS 
select log.id,
       log.log_time,
       log.log_type,
       log.log_message,
       log.log_details,
       log.log_level,
       log.log_source,
       log.log_source_type,
       log.log_source_id,
       log.log_source_name,
       log.log_source_code,
       log.log_source_parent_id,
       log.log_source_parent_name,
       log.log_source_parent_code,
       log.log_source_parent_type,
       log.log_source_company_id,
       log.log_source_company_name,
       log.log_source_company_code
from BATCH_SIMPLE_LOG log
;
GRANT SELECT ON V_BATCH_LAST_SIMPLE_LOG TO ROLE_BATCH_MAN;
