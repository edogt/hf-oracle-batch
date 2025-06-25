  /**
  * Package: PCK_BATCH_MONITOR
  * Description: Comprehensive monitoring and reporting utilities for batch processing operations.
  *              Provides real-time access to scheduler information, execution status,
  *              and performance metrics for chains, jobs, programs, and activities.
  *
  * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
  *
  * Key features:
  *   - Real-time scheduler chain monitoring and status reporting
  *   - Job execution tracking and performance metrics
  *   - Program and activity execution monitoring
  *   - Running job and chain status queries
  *   - Execution log and detail retrieval
  *   - Pipelined functions for efficient data streaming
  *
  * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
  */
CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_MONITOR AS 
  /**
  * Package: PCK_BATCH_MONITOR
  * Description: Comprehensive monitoring and reporting utilities for batch processing operations.
  *              Provides real-time access to scheduler information, execution status,
  *              and performance metrics for chains, jobs, programs, and activities.
  *
  * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
  *
  * Key features:
  *   - Real-time scheduler chain monitoring and status reporting
  *   - Job execution tracking and performance metrics
  *   - Program and activity execution monitoring
  *   - Running job and chain status queries
  *   - Execution log and detail retrieval
  *   - Pipelined functions for efficient data streaming
  *
  * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
  */



/**
 * Function: get_sched_chain_rules
 * Description: Retrieves all scheduler chain rules with their configuration and status.
 *              Returns information about workflow rules that control chain execution
 *              flow, dependencies, and conditional logic.
 *
 * Returns:
 *   TYP_SCHED_CHAIN_RULES_SET PIPELINED - Collection of chain rule information
 *
 * Example:
 *   select * from table(PCK_BATCH_MONITOR.get_sched_chain_rules())
 *   where chain_name = 'MY_CHAIN';
 *
 * Notes:
 *   - Returns rules that define execution flow and dependencies
 *   - Includes rule conditions, actions, and evaluation logic
 *   - Used for understanding chain workflow behavior
 *   - Pipelined function for efficient memory usage with large datasets
 **/

function get_sched_chain_rules return TYP_SCHED_CHAIN_RULES_SET PIPELINED ;

/**
 * Function: get_sched_chains
 * Description: Retrieves all scheduler chains with their configuration and status.
 *              Returns comprehensive information about chain definitions, including
 *              creation details, status, and execution configuration.
 *
 * Returns:
 *   TYP_SCHED_CHAINS_SET PIPELINED - Collection of chain information
 *
 * Example:
 *   select chain_name, status, enabled, created 
 *   from table(PCK_BATCH_MONITOR.get_sched_chains())
 *   where status = 'ENABLED';
 *
 * Notes:
 *   - Returns all chains in the scheduler, including system and user-defined
 *   - Includes chain status, creation date, and configuration details
 *   - Used for chain inventory and status monitoring
 *   - Pipelined function for efficient memory usage with large datasets
 **/

function get_sched_chains return TYP_SCHED_CHAINS_SET PIPELINED ;

/**
 * Function: get_sched_chain_steps
 * Description: Retrieves all scheduler chain steps with their configuration and status.
 *              Returns detailed information about individual steps within chains,
 *              including program references and execution order.
 *
 * Returns:
 *   TYP_SCHED_CHAIN_STEPS_SET PIPELINED - Collection of chain step information
 *
 * Example:
 *   select chain_name, step_name, program_name, step_type
 *   from table(PCK_BATCH_MONITOR.get_sched_chain_steps())
 *   where chain_name = 'MY_CHAIN'
 *   order by step_no;
 *
 * Notes:
 *   - Returns steps that define the actual work within chains
 *   - Includes step order, program references, and execution type
 *   - Used for understanding chain structure and workflow
 *   - Pipelined function for efficient memory usage with large datasets
 **/

function get_sched_chain_steps return TYP_SCHED_CHAIN_STEPS_SET PIPELINED ;

/**
 * Function: get_sched_job_dests
 * Description: Retrieves scheduler job destinations and routing information.
 *              Returns details about where jobs are executed, including
 *              destination types, configurations, and routing rules.
 *
 * Returns:
 *   TYP_SCHED_JOB_DESTS_SET PIPELINED - Collection of job destination information
 *
 * Example:
 *   select job_name, destination_type, destination_name
 *   from table(PCK_BATCH_MONITOR.get_sched_job_dests())
 *   where destination_type = 'DATABASE';
 *
 * Notes:
 *   - Returns job execution destinations and routing information
 *   - Includes database, external, and remote execution targets
 *   - Used for understanding job distribution and load balancing
 *   - Pipelined function for efficient memory usage with large datasets
 **/

function get_sched_job_dests return TYP_SCHED_JOB_DESTS_SET PIPELINED ;

/**
 * Function: get_sched_job_log
 * Description: Retrieves scheduler job execution logs with detailed status information.
 *              Returns comprehensive execution history including start/end times,
 *              status, error messages, and performance metrics.
 *
 * Returns:
 *   TYP_SCHED_JOB_LOG_SET PIPELINED - Collection of job log information
 *
 * Example:
 *   select job_name, status, log_date, error# 
 *   from table(PCK_BATCH_MONITOR.get_sched_job_log())
 *   where log_date > sysdate - 1
 *   order by log_date desc;
 *
 * Notes:
 *   - Returns detailed execution history for all jobs
 *   - Includes success/failure status and error details
 *   - Used for troubleshooting and performance analysis
 *   - Pipelined function for efficient memory usage with large datasets
 **/

function get_sched_job_log return TYP_SCHED_JOB_LOG_SET PIPELINED ;

/**
 * Function: get_sched_job_run_details
 * Description: Retrieves detailed runtime information for scheduler job executions.
 *              Returns comprehensive execution details including resource usage,
 *              timing information, and execution context.
 *
 * Returns:
 *   TYP_SCHED_JOB_RUN_DETAILS_SET PIPELINED - Collection of job run detail information
 *
 * Example:
 *   select job_name, run_duration, cpu_used, max_mem_used
 *   from table(PCK_BATCH_MONITOR.get_sched_job_run_details())
 *   where run_duration > interval '0 00:05:00' day to second;
 *
 * Notes:
 *   - Returns detailed runtime metrics and resource usage
 *   - Includes CPU, memory, and timing information
 *   - Used for performance analysis and capacity planning
 *   - Pipelined function for efficient memory usage with large datasets
 **/

function get_sched_job_run_details return TYP_SCHED_JOB_RUN_DETAILS_SET PIPELINED ;

/**
 * Function: get_sched_jobs
 * Description: Retrieves all scheduler jobs with their configuration and status.
 *              Returns comprehensive information about job definitions, including
 *              schedule, program references, and current status.
 *
 * Returns:
 *   TYP_SCHED_JOBS_SET PIPELINED - Collection of job information
 *
 * Example:
 *   select job_name, job_type, enabled, state, last_start_date
 *   from table(PCK_BATCH_MONITOR.get_sched_jobs())
 *   where enabled = 'TRUE'
 *   order by last_start_date desc;
 *
 * Notes:
 *   - Returns all jobs in the scheduler, including system and user-defined
 *   - Includes job status, schedule, and execution configuration
 *   - Used for job inventory and status monitoring
 *   - Pipelined function for efficient memory usage with large datasets
 **/

function get_sched_jobs return TYP_SCHED_JOBS_SET PIPELINED ;

/**
 * Function: get_sched_programs
 * Description: Retrieves all scheduler programs with their configuration and status.
 *              Returns detailed information about program definitions, including
 *              program type, action, and execution parameters.
 *
 * Returns:
 *   TYP_SCHED_PROGRAMS_SET PIPELINED - Collection of program information
 *
 * Example:
 *   select program_name, program_type, enabled, number_of_arguments
 *   from table(PCK_BATCH_MONITOR.get_sched_programs())
 *   where program_type = 'PLSQL_BLOCK';
 *
 * Notes:
 *   - Returns all programs in the scheduler, including system and user-defined
 *   - Includes program type, action, and parameter configuration
 *   - Used for program inventory and configuration monitoring
 *   - Pipelined function for efficient memory usage with large datasets
 **/

function get_sched_programs return TYP_SCHED_PROGRAMS_SET PIPELINED ;

/**
 * Function: get_sched_running_chains
 * Description: Retrieves currently running scheduler chains with real-time status.
 *              Returns active chain executions including start time, current step,
 *              and execution progress information.
 *
 * Returns:
 *   TYP_SCHED_RUNNING_CHAINS_SET PIPELINED - Collection of running chain information
 *
 * Example:
 *   select chain_name, state, start_date, current_step_name
 *   from table(PCK_BATCH_MONITOR.get_sched_running_chains())
 *   where state = 'RUNNING';
 *
 * Notes:
 *   - Returns only currently active chain executions
 *   - Includes real-time status and progress information
 *   - Used for monitoring active workflows and execution progress
 *   - Pipelined function for efficient memory usage with large datasets
 **/

function get_sched_running_chains return TYP_SCHED_RUNNING_CHAINS_SET PIPELINED ;

/**
 * Function: get_sched_running_jobs
 * Description: Retrieves currently running scheduler jobs with real-time status.
 *              Returns active job executions including start time, progress,
 *              and resource usage information.
 *
 * Returns:
 *   TYP_SCHED_RUNNING_JOBS_SET PIPELINED - Collection of running job information
 *
 * Example:
 *   select job_name, state, start_date, elapsed_time
 *   from table(PCK_BATCH_MONITOR.get_sched_running_jobs())
 *   where state = 'RUNNING'
 *   order by start_date;
 *
 * Notes:
 *   - Returns only currently active job executions
 *   - Includes real-time status and resource usage information
 *   - Used for monitoring active jobs and performance analysis
 *   - Pipelined function for efficient memory usage with large datasets
 **/

function get_sched_running_jobs return TYP_SCHED_RUNNING_JOBS_SET PIPELINED ;


end PCK_BATCH_MONITOR ;

GRANT EXECUTE ON PCK_BATCH_MONITOR TO USR_BATCH_EXEC;
GRANT EXECUTE ON PCK_BATCH_MONITOR TO ROLE_BATCH_MAN;

/
