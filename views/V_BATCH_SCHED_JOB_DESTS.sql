/**
 * View: V_BATCH_SCHED_JOB_DESTS
 * Description: Oracle Scheduler job destinations monitoring view.
 *              Provides information about job destinations and their configurations
 *              for Oracle Scheduler job management and monitoring.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor Oracle Scheduler job destinations and configurations
 *   - Provide destination information for job management
 *   - Support job destination analysis and reporting
 *   - Enable destination-based job filtering and monitoring
 *
 * Query Description:
 *   - Uses PCK_BATCH_MONITOR.GET_SCHED_JOB_DESTS function to retrieve job destinations
 *   - Provides destination type, value, and configuration information
 *   - Enables destination-based job analysis and management
 *   - Supports job routing and destination optimization
 *
 * Usage Examples:
 * 
 * -- Get all job destinations
 * SELECT * FROM V_BATCH_SCHED_JOB_DESTS 
 * ORDER BY JOB_NAME, DESTINATION;
 *
 * -- Get destinations by type
 * SELECT DESTINATION_TYPE, COUNT(*) as destination_count,
 *        COUNT(DISTINCT JOB_NAME) as unique_jobs
 * FROM V_BATCH_SCHED_JOB_DESTS 
 * GROUP BY DESTINATION_TYPE
 * ORDER BY destination_count DESC;
 *
 * -- Get destinations for a specific job
 * SELECT * FROM V_BATCH_SCHED_JOB_DESTS 
 * WHERE JOB_NAME = 'DAILY_BATCH_JOB'
 * ORDER BY DESTINATION;
 *
 * -- Get jobs with multiple destinations
 * SELECT JOB_NAME, COUNT(*) as destination_count
 * FROM V_BATCH_SCHED_JOB_DESTS 
 * GROUP BY JOB_NAME
 * HAVING COUNT(*) > 1
 * ORDER BY destination_count DESC;
 *
 * -- Get destinations with specific values
 * SELECT * FROM V_BATCH_SCHED_JOB_DESTS 
 * WHERE DESTINATION_VALUE LIKE '%PROD%'
 * ORDER BY JOB_NAME;
 *
 * -- Get destination summary
 * SELECT 
 *   COUNT(*) as total_destinations,
 *   COUNT(DISTINCT JOB_NAME) as unique_jobs,
 *   COUNT(DISTINCT DESTINATION_TYPE) as unique_types
 * FROM V_BATCH_SCHED_JOB_DESTS;
 *
 * Related Objects:
 * - Packages: PCK_BATCH_MONITOR (GET_SCHED_JOB_DESTS function)
 * - Types: TYP_SCHED_JOB_DESTS, TYP_SCHED_JOB_DESTS_SET
 * - Views: V_BATCH_SCHED_JOBS, V_BATCH_SCHED_JOB_LOG
 * - Tables: BATCH_SCHED_JOB_DESTS, BATCH_SCHEDULER_JOBS
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SCHED_JOB_DESTS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SCHED_JOB_DESTS (
    JOB_NAME,              -- Oracle Scheduler job name
    DESTINATION,           -- Destination identifier
    DESTINATION_TYPE,      -- Type of destination
    DESTINATION_VALUE,     -- Destination configuration value
    COMMENTS               -- Additional comments and notes
) AS
select JOB_NAME, DESTINATION, DESTINATION_TYPE, DESTINATION_VALUE, COMMENTS 
from table(PCK_BATCH_MONITOR.get_sched_job_dests)
;
GRANT SELECT ON V_BATCH_SCHED_JOB_DESTS TO ROLE_BATCH_MAN;
