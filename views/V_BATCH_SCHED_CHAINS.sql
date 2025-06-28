/**
 * View: V_BATCH_SCHED_CHAINS
 * Description: Oracle Scheduler chain information view with company context.
 *              Provides comprehensive chain scheduling information including
 *              execution status, timing, and company ownership for monitoring and management.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor Oracle Scheduler chain status and scheduling
 *   - Provide chain execution history and next run information
 *   - Support chain management across multiple companies
 *   - Enable chain scheduling analysis and reporting
 *
 * Query Description:
 *   - Joins BATCH_CHAINS with BATCH_COMPANIES to provide company context
 *   - Includes all chain scheduling attributes and execution status
 *   - Provides complete chain information for monitoring and management
 *   - Supports filtering and analysis by company
 *
 * Usage Examples:
 * 
 * -- Get all active chains
 * SELECT * FROM V_BATCH_SCHED_CHAINS 
 * WHERE SCHEDULE_STATE = 'ACTIVE';
 *
 * -- Get chains for a specific company
 * SELECT * FROM V_BATCH_SCHED_CHAINS 
 * WHERE COMPANY_NAME = 'ACME Corp'
 * ORDER BY SCHEDULE_NEXT_RUN;
 *
 * -- Get chains that need to run soon (next 24 hours)
 * SELECT * FROM V_BATCH_SCHED_CHAINS 
 * WHERE SCHEDULE_NEXT_RUN BETWEEN SYSTIMESTAMP 
 *   AND SYSTIMESTAMP + INTERVAL '1' DAY
 * ORDER BY SCHEDULE_NEXT_RUN;
 *
 * -- Get chain execution summary by company
 * SELECT COMPANY_NAME, COUNT(*) as total_chains,
 *        SUM(CASE WHEN SCHEDULE_STATE = 'ACTIVE' THEN 1 ELSE 0 END) as active_chains,
 *        SUM(CASE WHEN SCHEDULE_STATE = 'DISABLED' THEN 1 ELSE 0 END) as disabled_chains
 * FROM V_BATCH_SCHED_CHAINS 
 * GROUP BY COMPANY_NAME;
 *
 * -- Get chains that haven't run recently (> 7 days)
 * SELECT * FROM V_BATCH_SCHED_CHAINS 
 * WHERE SCHEDULE_LAST_RUN < SYSTIMESTAMP - INTERVAL '7' DAY
 * OR SCHEDULE_LAST_RUN IS NULL;
 *
 * Related Objects:
 * - Tables: BATCH_CHAINS, BATCH_COMPANIES
 * - Types: TYP_SCHED_CHAINS, TYP_SCHED_CHAINS_SET
 * - Views: V_BATCH_SCHED_RUNNING_CHAINS, V_BATCH_SCHED_CHAIN_RULES
 * - Packages: PCK_BATCH_MGR_CHAINS, PCK_BATCH_MONITOR
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SCHED_CHAINS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SCHED_CHAINS (
    ID,                    -- Chain identifier
    CODE,                  -- Chain code for identification
    NAME,                  -- Chain name and description
    DESCRIPTION,           -- Detailed chain description
    COMPANY_ID,            -- Company identifier
    COMPANY_CODE,          -- Company code for identification
    COMPANY_NAME,          -- Company name
    SCHEDULE_TYPE,         -- Type of schedule (DAILY, WEEKLY, etc.)
    SCHEDULE_VALUE,        -- Schedule configuration value
    SCHEDULE_START_DATE,   -- Schedule start date
    SCHEDULE_END_DATE,     -- Schedule end date (null if ongoing)
    SCHEDULE_LAST_RUN,     -- Last execution timestamp
    SCHEDULE_NEXT_RUN,     -- Next scheduled execution timestamp
    SCHEDULE_STATE,        -- Current schedule state (ACTIVE, DISABLED, etc.)
    SCHEDULE_COMMENTS      -- Schedule-related comments and notes
) AS 
select chain.id,
       chain.code,
       chain.name,
       chain.description,
       comp.id company_id,
       comp.code company_code,
       comp.name company_name,
       chain.schedule_type,
       chain.schedule_value,
       chain.schedule_start_date,
       chain.schedule_end_date,
       chain.schedule_last_run,
       chain.schedule_next_run,
       chain.schedule_state,
       chain.schedule_comments
from BATCH_CHAINS chain,
     BATCH_COMPANIES comp
where ( 1 = 1 )
    and comp.id = chain.company_id
;
GRANT SELECT ON V_BATCH_SCHED_CHAINS TO ROLE_HF_BATCH;
