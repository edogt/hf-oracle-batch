/**
 * Function: GETJOBSDESTS
 * Description: Oracle Scheduler job destinations retrieval function.
 *              Provides access to Oracle Scheduler job destination information
 *              through a pipelined function that returns job destination details
 *              for monitoring and management purposes.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Retrieve Oracle Scheduler job destination information
 *   - Provide job destination monitoring capabilities
 *   - Support job destination analysis and reporting
 *   - Enable job destination management operations
 *
 * Query Description:
 *   - Queries USER_SCHEDULER_JOB_DESTS view for job destination information
 *   - Returns pipelined TYP_SCHED_JOB_DESTS_SET for efficient data streaming
 *   - Provides comprehensive job destination details including status and timing
 *   - Enables real-time monitoring of job destinations
 *
 * Usage Examples:
 * 
 * -- Get all job destinations
 * SELECT * FROM TABLE(GETJOBSDESTS())
 * ORDER BY JOB_NAME;
 *
 * -- Get enabled job destinations
 * SELECT * FROM TABLE(GETJOBSDESTS())
 * WHERE ENABLED = 'TRUE'
 * ORDER BY JOB_NAME;
 *
 * -- Get job destinations with recent activity
 * SELECT * FROM TABLE(GETJOBSDESTS())
 * WHERE LAST_START_DATE > SYSTIMESTAMP - INTERVAL '1' DAY
 * ORDER BY LAST_START_DATE DESC;
 *
 * -- Get job destinations by state
 * SELECT STATE, COUNT(*) as destination_count
 * FROM TABLE(GETJOBSDESTS())
 * GROUP BY STATE
 * ORDER BY destination_count DESC;
 *
 * -- Get failed job destinations
 * SELECT * FROM TABLE(GETJOBSDESTS())
 * WHERE FAILURE_COUNT > 0
 * ORDER BY FAILURE_COUNT DESC;
 *
 * -- Get job destinations summary
 * SELECT 
 *   COUNT(*) as total_destinations,
 *   SUM(CASE WHEN ENABLED = 'TRUE' THEN 1 ELSE 0 END) as enabled_destinations,
 *   SUM(RUN_COUNT) as total_runs,
 *   SUM(FAILURE_COUNT) as total_failures
 * FROM TABLE(GETJOBSDESTS());
 *
 * Related Objects:
 * - Types: TYP_SCHED_JOB_DESTS, TYP_SCHED_JOB_DESTS_SET
 * - Views: V_BATCH_SCHED_JOB_DESTS (uses this function)
 * - Packages: PCK_BATCH_MONITOR (related monitoring functions)
 * - Tables: USER_SCHEDULER_JOB_DESTS (Oracle system view)
 */


CREATE OR REPLACE EDITIONABLE FUNCTION GETJOBSDESTS 
RETURN TYP_SCHED_JOB_DESTS_SET PIPELINED IS

  outputObject TYP_SCHED_JOB_DESTS := TYP_SCHED_JOB_DESTS(
    null, null, null, null, null, null, null, null, null, null, null
  );

BEGIN
    --
    FOR rec IN (SELECT * FROM user_scheduler_job_dests) LOOP
        --
        outputObject.job_name           := rec.job_name;
        outputObject.job_subname        := rec.job_subname;
        outputObject.enabled            := rec.enabled;
        outputObject.refs_enabled       := rec.refs_enabled;
        outputObject.state              := rec.state;
        outputObject.next_start_date    := rec.next_start_date;
        outputObject.run_count          := rec.run_count;
        outputObject.retry_count        := rec.retry_count;
        outputObject.failure_count      := rec.failure_count;
        outputObject.last_start_date    := rec.last_start_date;
        outputObject.last_end_date      := rec.last_end_date;
        --
        PIPE ROW(outputObject);
        --
    END LOOP;
    --
    RETURN;
    --
END GETJOBSDESTS;

/
