/**
 * View: V_BATCH_SIMPLE_LOG
 * Description: Comprehensive view of batch system logging with hierarchical context.
 *              Provides complete logging information including source relationships,
 *              company context, and hierarchical structure for audit and troubleshooting.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Provide comprehensive logging information for audit and troubleshooting
 *   - Support hierarchical log analysis with parent-child relationships
 *   - Enable log filtering and analysis by company, source type, and level
 *   - Facilitate system monitoring and error tracking
 *
 * Query Description:
 *   - Direct view of BATCH_SIMPLE_LOG table with all logging attributes
 *   - Includes hierarchical relationships (source, parent, company)
 *   - Provides complete context for log analysis and troubleshooting
 *   - Supports filtering by log level, source type, and company
 *
 * Usage Examples:
 * 
 * -- Get all error logs
 * SELECT * FROM V_BATCH_SIMPLE_LOG 
 * WHERE LOG_LEVEL = 'ERROR'
 * ORDER BY LOG_TIME DESC;
 *
 * -- Get logs for a specific company
 * SELECT * FROM V_BATCH_SIMPLE_LOG 
 * WHERE LOG_SOURCE_COMPANY_NAME = 'ACME Corp'
 * ORDER BY LOG_TIME DESC;
 *
 * -- Get recent logs (last 24 hours)
 * SELECT * FROM V_BATCH_SIMPLE_LOG 
 * WHERE LOG_TIME > SYSTIMESTAMP - INTERVAL '1' DAY
 * ORDER BY LOG_TIME DESC;
 *
 * -- Get logs by source type
 * SELECT LOG_SOURCE_TYPE, COUNT(*) as log_count,
 *        MIN(LOG_TIME) as earliest_log,
 *        MAX(LOG_TIME) as latest_log
 * FROM V_BATCH_SIMPLE_LOG 
 * GROUP BY LOG_SOURCE_TYPE
 * ORDER BY log_count DESC;
 *
 * -- Get error summary by company
 * SELECT LOG_SOURCE_COMPANY_NAME, COUNT(*) as total_logs,
 *        SUM(CASE WHEN LOG_LEVEL = 'ERROR' THEN 1 ELSE 0 END) as error_count,
 *        SUM(CASE WHEN LOG_LEVEL = 'WARNING' THEN 1 ELSE 0 END) as warning_count
 * FROM V_BATCH_SIMPLE_LOG 
 * GROUP BY LOG_SOURCE_COMPANY_NAME
 * ORDER BY error_count DESC;
 *
 * -- Get logs for a specific chain execution
 * SELECT * FROM V_BATCH_SIMPLE_LOG 
 * WHERE LOG_SOURCE_TYPE = 'CHAIN_EXECUTION'
 * AND LOG_SOURCE_ID = 12345
 * ORDER BY LOG_TIME;
 *
 * -- Get hierarchical log analysis
 * SELECT LOG_SOURCE_PARENT_NAME, LOG_SOURCE_NAME, COUNT(*) as log_count
 * FROM V_BATCH_SIMPLE_LOG 
 * WHERE LOG_SOURCE_PARENT_ID IS NOT NULL
 * GROUP BY LOG_SOURCE_PARENT_NAME, LOG_SOURCE_NAME
 * ORDER BY log_count DESC;
 *
 * Related Objects:
 * - Tables: BATCH_SIMPLE_LOG
 * - Views: V_BATCH_LAST_SIMPLE_LOG
 * - Packages: PCK_BATCH_MGR_LOG, PCK_BATCH_TOOLS, PCK_BATCH_MONITOR
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SIMPLE_LOG
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SIMPLE_LOG (
    ID,                        -- Unique log entry identifier
    LOG_TIME,                  -- Timestamp when the log entry was created
    LOG_TYPE,                  -- Type of log entry (INFO, ERROR, WARNING, etc.)
    LOG_MESSAGE,               -- Main log message
    LOG_DETAILS,               -- Detailed log information
    LOG_LEVEL,                 -- Log level (DEBUG, INFO, WARNING, ERROR, FATAL)
    LOG_SOURCE,                -- Source of the log entry
    LOG_SOURCE_TYPE,           -- Type of source (ACTIVITY, PROCESS, CHAIN, etc.)
    LOG_SOURCE_ID,             -- Identifier of the source object
    LOG_SOURCE_NAME,           -- Name of the source object
    LOG_SOURCE_CODE,           -- Code of the source object
    LOG_SOURCE_PARENT_ID,      -- Identifier of the parent source object
    LOG_SOURCE_PARENT_NAME,    -- Name of the parent source object
    LOG_SOURCE_PARENT_CODE,    -- Code of the parent source object
    LOG_SOURCE_PARENT_TYPE,    -- Type of the parent source object
    LOG_SOURCE_COMPANY_ID,     -- Company identifier
    LOG_SOURCE_COMPANY_NAME,   -- Company name
    LOG_SOURCE_COMPANY_CODE    -- Company code
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
GRANT SELECT ON V_BATCH_SIMPLE_LOG TO ROLE_BATCH_MAN;
