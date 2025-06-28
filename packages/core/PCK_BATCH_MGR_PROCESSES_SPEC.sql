/**
 * Package: PCK_BATCH_MGR_PROCESSES
 * Description: Process management utilities for batch processing operations.
 *              Provides functions for retrieving process information and execution
 *              details, supporting the batch manager's process lifecycle management
 *              and execution tracking capabilities.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Process information retrieval by ID
 *   - Process execution details and status tracking
 *   - Integration with batch execution lifecycle
 *   - Error handling and logging for process operations
 *   - Support for process execution context management
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_MGR_PROCESSES AS
/**
 * Package: PCK_BATCH_MGR_PROCESSES
 * Description: Process management utilities for batch processing operations.
 *              Provides functions for retrieving process information and execution
 *              details, supporting the batch manager's process lifecycle management
 *              and execution tracking capabilities.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Process information retrieval by ID
 *   - Process execution details and status tracking
 *   - Integration with batch execution lifecycle
 *   - Error handling and logging for process operations
 *   - Support for process execution context management
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

/**
 * Function: getProcessById
 * Description: Retrieves complete process information by its unique identifier.
 *              Returns the full process definition including name, description, status,
 *              configuration, and all associated metadata from the BATCH_PROCESSES table.
 *
 * Parameters:
 *   process_id: Unique identifier of the process to retrieve
 *
 * Returns:
 *   BATCH_PROCESSES%rowtype - Complete process record with all columns
 *
 * Example:
 *   declare
 *     process batch_processes%rowtype;
 *   begin
 *     process := pck_batch_mgr_processes.getProcessById(123);
 *     if process is not null then
 *       dbms_output.put_line('Process: ' || process.name || ' - Status: ' || process.status);
 *       dbms_output.put_line('Code: ' || process.code || ' - Description: ' || process.description);
 *     end if;
 *   end;
 *
 * Notes:
 *   - Process ID must exist in BATCH_PROCESSES table
 *   - Returns complete process record with all metadata and configuration
 *   - Used by PCK_BATCH_MANAGER for process validation and execution
 *   - Can be used to check process status and configuration before execution
 *   - Process information includes rules, configuration, and execution context
 *   - Raises exception if process not found or on database errors
 **/

function getProcessById(process_id in number) return batch_processes%rowtype ;

/**
 * Function: getProcessExecutionById
 * Description: Retrieves complete process execution information by its unique identifier.
 *              Returns detailed execution data including timing, status, parameters,
 *              and results from the BATCH_PROCESS_EXECUTIONS table.
 *
 * Parameters:
 *   execution_id: Unique identifier of the process execution to retrieve
 *
 * Returns:
 *   BATCH_PROCESS_EXECUTIONS%rowtype - Complete execution record with all columns
 *
 * Example:
 *   declare
 *     execution batch_process_executions%rowtype;
 *   begin
 *     execution := pck_batch_mgr_processes.getProcessExecutionById(45678);
 *     if execution is not null then
 *       dbms_output.put_line('Execution ID: ' || execution.id);
 *       dbms_output.put_line('Status: ' || execution.status);
 *       dbms_output.put_line('Start Time: ' || execution.start_time);
 *       dbms_output.put_line('End Time: ' || execution.end_time);
 *     end if;
 *   end;
 *
 * Notes:
 *   - Execution ID must exist in BATCH_PROCESS_EXECUTIONS table
 *   - Returns null if execution not found (no_data_found exception handled)
 *   - Returns complete execution record with all timing and status information
 *   - Used by PCK_BATCH_MANAGER for execution monitoring and troubleshooting
 *   - Includes parameter values and execution results
 *   - Can be used for performance analysis and audit purposes
 *   - Used by BATCH_LOGGER for execution context in log entries
 **/

function getProcessExecutionById(execution_id in number) return batch_process_executions%rowtype ;

end pck_batch_mgr_processes ;




/

  GRANT EXECUTE ON PCK_BATCH_MGR_PROCESSES TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_MGR_PROCESSES TO ROLE_HF_BATCH;
