/**
 * Package: PCK_BATCH_MANAGER
 * Description: Central orchestrator for batch automation. Provides the main API for executing, registering, monitoring, and managing batch chains, processes, and activities.
 *              Supports dynamic parameterization, context injection, simulation mode, and automated notifications.
 *              Designed for extensibility, traceability, and integration with external systems.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Dynamic execution of chains, processes, and activities with JSON parameter support.
 *   - Registration and tracking of all executions for full traceability.
 *   - Context-aware parameter evaluation and validation.
 *   - Automated result reporting and notification.
 *   - Simulation mode for safe testing.
 *   - Centralized configuration and extensibility.
 *
 * For detailed documentation and usage examples, refer to SYSTEM_ARCHITECTURE.md.
 */

CREATE OR REPLACE PACKAGE PCK_BATCH_MANAGER AS
  /**
   * Package: PCK_BATCH_MANAGER
   * Description: Central orchestrator for batch automation. Provides the main API for executing, registering, monitoring, and managing batch chains, processes, and activities.
   *              Supports dynamic parameterization, context injection, simulation mode, and automated notifications.
   *              Designed for extensibility, traceability, and integration with external systems.
 *
   * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Dynamic execution of chains, processes, and activities with JSON parameter support.
 *   - Registration and tracking of all executions for full traceability.
 *   - Context-aware parameter evaluation and validation.
 *   - Automated result reporting and notification.
 *   - Simulation mode for safe testing.
 *   - Centralized configuration and extensibility.
 *
 * For detailed documentation and usage examples, refer to SYSTEM_ARCHITECTURE.md.
 */

-- Execution status constants
RUNNING     constant varchar2(50) := 'running' ;
FINISHED    constant varchar2(50) := 'finished' ;
ERROR       constant varchar2(50) := 'error' ;
ALERT       constant varchar2(50) := 'alert' ;


-- The following values are placeholders and should be configured per environment
MAILS_SENDER            varchar2(50) := 'Batch Manager <batch_manager@example.com>' ;
ENVIRONMENT_NAME        varchar2(50) := 'Development' ;
WEBAPP_URL              varchar2(50) := 'http://your-webapp-url/' ;
REPORTSERVER_GATEWAY    varchar2(50) := 'http://your-reportserver-url/' ;


PROCESS_ERROR exception ;

SIMULATION_MODE boolean := false ;

/**
 * Procedure: run_chain
 * Description: Executes a complete batch chain workflow with dynamic parameter injection.
 *              Orchestrates the execution of all processes and activities within the chain,
 *              creating dynamic Oracle scheduler objects via PCK_BATCH_DSI and providing
 *              full traceability through execution logging.
 *
 * Overloads:
 *   1. run_chain(chain_id in number) - Execute chain without parameters
 *   2. run_chain(chain_id in number, paramsJSON in varchar2) - Execute chain with parameters
 *
 * Parameters:  
 *   chain_id: Unique identifier of the chain to execute (must exist in BATCH_CHAINS table)
 *   paramsJSON: JSON string containing parameters to inject into all chain activities
 *
 * Returns: 
 *   None
 *
 * Example:
 *   -- Execute monthly report chain with date parameters
 *   PCK_BATCH_MANAGER.run_chain(1, '{"report_date": "2024-01-31", "company_id": "COMP001"}');
 *   
 *   -- Execute data extraction chain in simulation mode
 *   PCK_BATCH_MANAGER.run_chain(2, '{"extract_mode": "incremental", "simulation": true}');
 *   
 *   -- Execute simple chain without parameters
 *   PCK_BATCH_MANAGER.run_chain(3);
 *
 * Notes:
 *   - Chain must exist in BATCH_CHAINS table before execution
 *   - paramsJSON supports dynamic parameter injection for all activities in the chain
 *   - Execution creates dynamic Oracle scheduler chains via PCK_BATCH_DSI
 *   - All executions are logged in BATCH_CHAIN_EXECUTIONS for full traceability
 *   - Use simulation mode for testing without actual database changes
 *   - Failed executions are automatically logged with detailed error information
 *   - Chain execution status can be monitored through V_BATCH_CHAIN_EXECUTIONS view
 **/
procedure run_chain(chain_id in number) ;
procedure run_chain(chain_id in number, paramsJSON in varchar2) ;

/**
 * Function: chain_execution_register
 * Description: Registers the start of a chain execution and returns a unique execution identifier.
 *              This function creates the initial execution record that tracks the entire
 *              lifecycle of a chain execution, including timing, status, and simulation mode.
 *
 * Parameters:
 *   chain_code: Unique code identifier of the chain to register for execution
 *   execution_type: Type of execution ('start', 'manual', 'scheduled', 'retry')
 *   sim_mode: If true, execution runs in simulation mode without actual database changes
 *   execution_comments: Optional comments describing the execution context or purpose
 *
 * Returns:
 *   number - Unique execution identifier for tracking this chain execution
 *
 * Example:
 *   declare
 *     chain_exec_id number;
 *   begin
 *     -- Register monthly report chain execution
 *     chain_exec_id := PCK_BATCH_MANAGER.chain_execution_register(
 *       'MONTHLY_REPORT_CHAIN', 'scheduled', false, 'Monthly report generation for January 2024');
 *     dbms_output.put_line('Chain execution ID: ' || chain_exec_id);
 *   end;
 *
 * Notes:
 *   - Chain must exist in BATCH_CHAINS table before registration
 *   - Execution ID is used throughout the chain lifecycle for traceability
 *   - Simulation mode allows testing without actual database modifications
 *   - Execution record includes timestamp, status, and full context
 *   - Can be linked to parent chain executions for complex workflows
 *   - Execution status can be monitored through V_BATCH_CHAIN_EXECUTIONS view
 **/
function chain_execution_register(  chain_code in varchar2,
                                    execution_type in varchar2,
                                    sim_mode in boolean,
                                    execution_comments in varchar default null) return number ;

/**
 * Procedure: chain_exec_end_register
 * Description: Registers the completion of a chain execution with final status and timing.
 *              This procedure updates the execution record with end time, status, and
 *              completion details, providing full traceability of the execution lifecycle.
 *
 * Parameters:
 *   chain_exec_id: Unique execution identifier returned by chain_execution_register
 *   end_type: Final status of the execution ('finished', 'error', 'cancelled', 'timeout')
 *   end_comments: Optional comments describing the execution outcome or issues
 *
 * Returns:
 *   None
 *
 * Example:
 *   -- Register successful completion
 *   PCK_BATCH_MANAGER.chain_exec_end_register(12345, 'finished', 'Monthly report generated successfully');
 *   
 *   -- Register execution failure
 *   PCK_BATCH_MANAGER.chain_exec_end_register(12346, 'error', 'Database connection timeout during data extraction');
 *
 * Notes:
 *   - Execution ID must correspond to an active chain execution
 *   - End time is automatically recorded when procedure is called
 *   - Execution duration is calculated from start to end time
 *   - Final status is used for reporting and monitoring purposes
 *   - Failed executions can be analyzed through error details in comments
 *   - Execution history is preserved for audit and troubleshooting
 **/
procedure chain_exec_end_register( chain_exec_id in number,
                                      end_type in varchar2 default 'finished',
                                      end_comments in varchar2 default null ) ;

/**
 * Procedure: run_process
 * Description: Executes a batch process workflow with dynamic parameter injection.
 *              Processes contain multiple activities that are executed sequentially
 *              or in parallel based on the process definition and rules.
 *
 * Parameters:
 *   process_id: Unique identifier of the process to execute (must exist in BATCH_PROCESSES table)
 *   paramsJSON: JSON string containing parameters to inject into all process activities
 *
 * Returns:
 *   None
 *
 * Example:
 *   -- Execute data extraction process with source parameters
 *   PCK_BATCH_MANAGER.run_process(1, '{"source_system": "SAP", "extract_date": "2024-01-31"}');
 *   
 *   -- Execute report generation process with output format
 *   PCK_BATCH_MANAGER.run_process(2, '{"output_format": "PDF", "include_charts": true}');
 *
 * Notes:
 *   - Process must exist in BATCH_PROCESSES table before execution
 *   - Process execution is automatically registered in BATCH_PROCESS_EXECUTIONS
 *   - All activities within the process inherit the provided parameters
 *   - Process execution can be monitored through V_BATCH_PROCESS_EXECUTIONS view
 *   - Failed process executions are logged with detailed error information
 *   - Use simulation mode for testing process logic without actual execution
 **/
procedure run_process(process_id in number, paramsJSON in varchar2) ;

/**
 * Procedure: run_processActivity
 * Description: Runs a process activity. 
 *
 * Parameters:
 *   processActivity_id: ID of the process activity to run.
 *   paramsJSON: JSON with the parameters for the process activity.
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_MANAGER.run_processActivity(1, '{"param1": "value1", "param2": "value2"}') ;
 *
 * Notes:
 *   - The process activity id is used for getting the process activity information for starting the process activity execution.
 *   - The paramsJSON is used like a container of parameters for the process activity.
 **/
procedure run_processActivity(processActivity_id in number, paramsJSON in varchar2) ;

/**
 * Function: getChainByCode
 * Description: Gets a chain by code and returns a row of batch_chains.
 *
 * Parameters:
 *   chain_code: Code of the chain to get.
 *
 * Returns:
 *   batch_chains%rowtype
 *
 * Example:
 *   declare
 *     chain batch_chains%rowtype ;
 *   begin
 *     chain := PCK_BATCH_MANAGER.getChainByCode('CHAIN_1') ;
 *     dbms_output.put_line('Chain name: ' || chain.name) ;
 *   end ;
 *
 * Notes:
 *   - The chain code is used for getting the chain information from batch_chains.
 **/
function getChainByCode(chain_code in varchar2) return batch_chains%rowtype ;

/**
 * Function: getActivityById
 * Description: Retrieves complete activity information by its unique identifier.
 *              Returns the full activity definition including name, description, status,
 *              and all associated metadata from the BATCH_ACTIVITIES table.
 *
 * Parameters:
 *   activity_id: Unique identifier of the activity to retrieve
 *   raise_error: If true, raises an exception if activity is not found; if false, returns null
 *
 * Returns:
 *   batch_activities%rowtype - Complete activity record with all columns
 *
 * Example:
 *   declare
 *     activity batch_activities%rowtype;
 *   begin
 *     activity := PCK_BATCH_MANAGER.getActivityById(1, true);
 *     if activity is not null then
 *       dbms_output.put_line('Activity: ' || activity.name || ' - Status: ' || activity.status);
 *     end if;
 *   end;
 *
 * Notes:
 *   - Activity ID must exist in BATCH_ACTIVITIES table when raise_error=true
 *   - Returns complete activity record with all metadata and configuration
 *   - Useful for validation before activity execution
 *   - Can be used to check activity status and parameter requirements
 *   - Returns null if activity doesn't exist and raise_error=false
 *   - Activity information includes parameter definitions and execution context
 **/
function getActivityById(activity_id in varchar2, raise_error in boolean default true) return BATCH_ACTIVITIES%rowtype ;

/**
 * Function: getCompanyByFiscalID
 * Description: Retrieves complete company information by its fiscal identifier.
 *              Returns the full company definition including name, status, configuration,
 *              and all associated metadata from the BATCH_COMPANIES table.
 *
 * Parameters:
 *   company_fiscal_id: Fiscal identifier of the company to retrieve (unique business identifier)
 *
 * Returns:
 *   batch_companies%rowtype - Complete company record with all columns and metadata
 *
 * Example:
 *   declare
 *     company batch_companies%rowtype;
 *   begin
 *     company := PCK_BATCH_MANAGER.getCompanyByFiscalID('1234567890');
 *     if company is not null then
 *       dbms_output.put_line('Company: ' || company.name || ' - Status: ' || company.status);
 *       dbms_output.put_line('Fiscal ID: ' || company.fiscal_id || ' - Created: ' || company.created_at);
 *     end if;
 *   end;
 *
 * Notes:
 *   - Company fiscal ID must exist in BATCH_COMPANIES table
 *   - Returns complete company record with all configuration and metadata
 *   - Useful for validation before company-specific operations
 *   - Can be used to check company status and parameter requirements
 *   - Company information includes parameter definitions and execution context
 *   - Fiscal ID is the primary business identifier for company operations
 *   - Company status affects whether batch operations can be executed
 **/
function getCompanyByFiscalID(company_fiscal_id in varchar2) return batch_companies%rowtype ;

/**
 * Function: getActivityByCode
 * Description: Retrieves complete activity information by company fiscal ID and activity code.
 *              Returns the full activity definition including name, description, status,
 *              and all associated metadata from the BATCH_ACTIVITIES table for the specified company.
 *
 * Parameters:
 *   company_fiscal_id: Fiscal identifier of the company (used for company context and validation)
 *   activity_code: Unique code of the activity to retrieve (must exist for the specified company)
 *
 * Returns:
 *   batch_activities%rowtype - Complete activity record with all columns and metadata
 *
 * Example:
 *   declare
 *     activity batch_activities%rowtype;
 *   begin
 *     activity := PCK_BATCH_MANAGER.getActivityByCode('1234567890', 'EXTRACT_SALES_DATA');
 *     if activity is not null then
 *       dbms_output.put_line('Activity: ' || activity.name || ' - Status: ' || activity.status);
 *       dbms_output.put_line('Code: ' || activity.code || ' - Company: ' || activity.company_fiscal_id);
 *     end if;
 *   end;
 *
 * Notes:
 *   - Company fiscal ID must exist in BATCH_COMPANIES table
 *   - Activity code must exist in BATCH_ACTIVITIES table for the specified company
 *   - Returns complete activity record with all metadata and configuration
 *   - Useful for validation before activity execution within company context
 *   - Can be used to check activity status and parameter requirements
 *   - Activity information includes parameter definitions and execution context
 *   - Company context ensures proper parameter resolution and access control
 **/
function getActivityByCode(company_fiscal_id in varchar2, activity_code in varchar2 ) return BATCH_ACTIVITIES%rowtype  ;

/**
 * Procedure: cleanExecutions
 * Description: Purges execution records from all system tables starting from a specific ID (see GLOBAL_ID reference on SYSTEM_ARCHITECTURE.md).
 *              This is useful for cleaning up test data or managing data retention.
 *
 * Parameters:
 *   logPoint: The execution ID from which all records will be deleted. 
 *
 * Returns: 
 *   None
 *
 * Example:
 *   -- Clean all executions starting from ID 5800
 *   BEGIN
 *     cleanExecutions(logPoint => 5800);
 *     COMMIT; -- The transaction must be committed by the caller.
 *   END;
 *
 * Notes:
 *   - This procedure's logic relies on the system's use of a single global sequence (global_id_seq)
 *     for generating all execution-related IDs.
 *   - This design ensures that IDs are unique and chronologically consistent across all log, 
 *     status, and result tables.
 *   - By providing a single ID, the procedure can safely and efficiently purge all subsequent data 
 *     without needing complex joins or date-based filters.
 *   - Use with caution, especially in production environments, as the deletion is permanent.
 *
 **/
procedure cleanExecutions(logPoint in number) ;

/**
 * Function: getActivityExecutionString
 * Description: Generates a complete, executable PL/SQL block for a specific activity, 
 *              resolving all required parameters. The resulting code is designed to be 
 *              dynamically inserted into the execution flow of a process chain, enabling 
 *              flexible and automated orchestration of activities.
 *
 * Parameters:
 *   ID: Identifier of the activity or process activity (can be BATCH_ACTIVITIES.ID or BATCH_PROCESS_ACTIVITIES.ID).
 *   evalueatedCompanyParams_SJSON: (Optional) JSON with company-level parameter values.
 *   parametersValues_SJSON: (Optional) JSON with runtime parameter overrides.
 *
 * Returns:
 *   VARCHAR2: A ready-to-execute PL/SQL anonymous block, suitable for inclusion in a chain's execution script.
 *
 * Example:
 *   -- Generate the execution string for a process activity and include it in a chain
 *   DECLARE
 *     v_sql VARCHAR2(4000);
 *   BEGIN
 *     v_sql := PCK_BATCH_MANAGER.getActivityExecutionString(123, ...);
 *     -- v_sql is then embedded into the chain's execution block and run with EXECUTE IMMEDIATE
 *   END;
 *
 * Notes:
 *   - This function is intended to be used internally by the chain/process execution engine.
 *   - The generated code block includes parameter registration and the call to the activity's action.
 *   - Parameter values are resolved in the following order: runtime overrides, company parameters, process activity values, and finally default values.
 *   - In simulation mode, the generated block simulates execution instead of performing the real action.
 */
function getActivityExecutionString(
  ID in number,
  evalueatedCompanyParams_SJSON in varchar2 default null,
  parametersValues_SJSON in varchar2 default null
) return varchar2;

/**
 * Function: isValidValueDefinition
 * Description: Checks if a given value definition (expression) is valid for a specified Oracle data type.
 *              The function attempts to evaluate the definition dynamically and returns TRUE if the
 *              expression is valid for the type, or FALSE otherwise.
 *
 * Parameters:
 *   value_type: The Oracle data type to validate against (e.g., 'char', 'varchar2', 'number', 'date', 'clob').
 *   definition: The value or expression to be validated (as a string).
 *
 * Returns:
 *   BOOLEAN: TRUE if the definition is a valid expression for the given type, FALSE otherwise.
 *
 * Example:
 *   -- Returns TRUE
 *   is_valid := PCK_BATCH_MANAGER.isValidValueDefinition('number', '123');
 *   is_valid := PCK_BATCH_MANAGER.isValidValueDefinition('date', 'sysdate');
 *   is_valid := PCK_BATCH_MANAGER.isValidValueDefinition('varchar2', '''hello''');
 *
 *   -- Returns FALSE
 *   is_valid := PCK_BATCH_MANAGER.isValidValueDefinition('number', '''not_a_number''');
 *   is_valid := PCK_BATCH_MANAGER.isValidValueDefinition('date', '''not_a_date''');
 *
 * Notes:
 *   - The function uses dynamic SQL to evaluate the definition, so the input must be a valid Oracle expression.
 *   - Useful for validating parameter default values or user-provided expressions before using them in dynamic code.
 *   - If the type is not recognized, the function will not perform validation and may return FALSE.
 */
function isValidValueDefinition(
  value_type in varchar2,
  definition in varchar2
) return boolean;

/**
 * Function: getEvaluatedCompanyParmsJSON
 * Description: Returns a JSON object containing all company parameters and their evaluated values for a given company fiscal ID.
 *              Each parameter's value is computed according to its type and default value definition, making the result ready for use in batch executions.
 *
 * Parameters:
 *   company_fiscalID: The fiscal ID (RUT) of the company whose parameters are to be evaluated.
 *   indexRef: (Optional, default 'name') Determines whether the JSON keys are the parameter names ('name') or IDs ('id').
 *
 * Returns:
 *   VARCHAR2: A JSON string (SimpleMap format) where each key is a parameter name or ID, and each value is the evaluated value for that parameter.
 *
 * Example:
 *   DECLARE
 *     evaluated_company_params_json VARCHAR2(4000);
 *   BEGIN
 *     evaluated_company_params_json := PCK_BATCH_MANAGER.getEvaluatedCompanyParmsJSON('12345678-9');
 *     -- Result: {"PARAM1":"value1", "PARAM2":"value2", ...}
 *   END;
 *
 * Notes:
 *   - The function evaluates each parameter's value using its type and default value definition.
 *   - Useful for passing all company context parameters to activities, processes, or chains in a single JSON object.
 *   - The output format is compatible with other procedures/functions that accept parameters in SimpleJSON format.
 */
function getEvaluatedCompanyParmsJSON(
  company_fiscalID in varchar2,
  indexRef in varchar2 default 'name'
) return varchar2;

/**
 * Function: getOutputDirectory
 * Description: Returns the configured output directory path for the current company context.
 *              This function retrieves the directory where batch execution output files,
 *              reports, and logs are stored for the active company session.
 *
 * Returns:
 *   varchar2 - Full directory path where output files should be stored
 *
 * Example:
 *   declare
 *     output_directory varchar2(4000);
 *   begin
 *     output_directory := PCK_BATCH_MANAGER.getOutputDirectory;
 *     dbms_output.put_line('Output directory: ' || output_directory);
 *     -- Example output: '/data/batch/output/company_1234567890/'
 *   end;
 *
 * Notes:
 *   - Output directory is company-specific and configured in company parameters
 *   - Directory path is used for storing execution results, reports, and log files
 *   - Path format follows operating system conventions (Unix/Linux style)
 *   - Directory must exist and be writable by the database user
 *   - Used by activities that generate output files or reports
 *   - Directory structure typically includes company-specific subdirectories
 *   - Path is resolved from company configuration parameters
 **/
function getOutputDirectory return varchar2 ;

/**
 * Function: getDirectoryPath
 * Description: Returns the full file system path for a specified directory name.
 *              This function resolves directory names to their actual file system paths,
 *              typically used for input/output operations in batch activities.
 *
 * Parameters:
 *   dir_name: Name of the directory to resolve (e.g., 'output', 'input', 'temp', 'logs')
 *
 * Returns:
 *   varchar2 - Full file system path for the specified directory
 *
 * Example:
 *   declare
 *     directory_path varchar2(4000);
 *   begin
 *     directory_path := PCK_BATCH_MANAGER.getDirectoryPath('output');
 *     dbms_output.put_line('Directory path: ' || directory_path);
 *     -- Example output: '/data/batch/output/'
 *     
 *     directory_path := PCK_BATCH_MANAGER.getDirectoryPath('temp');
 *     dbms_output.put_line('Temp directory: ' || directory_path);
 *     -- Example output: '/data/batch/temp/'
 *   end;
 *
 * Notes:
 *   - Directory names are predefined in the system configuration
 *   - Path format follows operating system conventions (Unix/Linux style)
 *   - Directory must exist and be accessible by the database user
 *   - Used by activities that need to read from or write to specific directories
 *   - Common directory names include: 'output', 'input', 'temp', 'logs', 'reports'
 *   - Path resolution is based on system configuration and company context
 *   - Function is read-only (WNDS) for performance optimization
 **/
function getDirectoryPath(dir_name in varchar2) return varchar2 ;
--pragma RESTRICT_REFERENCES(getDirectoryPath, WNDS) ;

/**
 * Procedure: execution_end_register
 * Description: Registers the end of an execution.
 *
 * Parameters:
 *   execution_id: ID of the execution to register.
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_MANAGER.execution_end_register(1) ;
 *
 * Notes:
 *   - The execution id is used for getting the execution information for registering the end of the execution.
 **/
procedure execution_end_register(execution_id in number) ;

/**
 * Function: get_activity_exec_id
 * Description: Returns the activity execution id for a given activity name.
 *
 * Parameters:
 *   activity_name: Name of the activity to get.
 *
 * Returns:
 *   number
 *
 * Example:
 *   declare
 *     activity_exec_id number ;
 *   begin
 *     activity_exec_id := PCK_BATCH_MANAGER.get_activity_exec_id('ACTIVITY_1') ;
 *     dbms_output.put_line('Activity execution id: ' || activity_exec_id) ;
 *   end ;
 *
 * Notes:
 *   - The activity name is used for getting the activity execution id from batch_activity_executions.
 **/
function get_activity_exec_id(activity_name in varchar2) return number ;

/**
 * Function: getLogOfLastExecutions
 * Description: Retrieves execution log entries for the most recent executions of a specific activity.
 *              Returns detailed execution history including timing, status, parameters, and
 *              results for analysis, troubleshooting, and performance monitoring.
 *
 * Parameters:
 *   activity_code: Unique code of the activity to retrieve execution logs for
 *   nexecs: Number of most recent executions to retrieve (default: 1)
 *
 * Returns:
 *   batch_log_list_type - Collection of execution log entries with detailed information
 *
 * Example:
 *   declare
 *     log_list batch_log_list_type;
 *     i number;
 *   begin
 *     -- Get last 5 executions of sales data extraction
 *     log_list := PCK_BATCH_MANAGER.getLogOfLastExecutions('EXTRACT_SALES_DATA', 5);
 *     
 *     -- Process each log entry
 *     for i in 1..log_list.count loop
 *       dbms_output.put_line('Execution ' || i || ': ID=' || log_list(i).execution_id || 
 *                           ', Status=' || log_list(i).status || 
 *                           ', Duration=' || log_list(i).duration || ' seconds');
 *     end loop;
 *   end;
 *
 * Notes:
 *   - Activity code must exist in BATCH_ACTIVITIES table
 *   - Log entries are ordered by execution timestamp (most recent first)
 *   - Each log entry includes execution ID, timing, status, parameters, and results
 *   - Useful for performance analysis and troubleshooting execution issues
 *   - Function is read-only (WNDS) for performance optimization
 *   - Returns empty collection if no executions exist for the activity
 *   - Log entries include detailed error information for failed executions
 *   - Can be used for trend analysis and execution pattern identification
 **/
function getLogOfLastExecutions( activity_code in varchar2, nexecs in number default 1) return batch_log_list_type ;
--pragma RESTRICT_REFERENCES(getLogOfLastExecutions, WNDS) ;

/**
 * Procedure: saveActivityExecution
 * Description: Saves an activity execution.
 *
 * Parameters:
 *   activityExecution: Activity execution to save.
 *
 * Returns:
 *   None
 *
 **/
procedure saveActivityExecution(activityExecution in out batch_activity_executions%rowtype) ;

/**
 * Procedure: startChainExecution
 * Description: Initiates the execution of a batch chain by setting up the execution context
 *              and preparing the chain for processing. This procedure marks the chain as
 *              active and ready to begin processing its defined sequence of processes.
 *
 * Parameters:
 *   chain_execution_id: Unique identifier of the chain execution to start
 *
 * Returns:
 *   None
 *
 * Example:
 *   declare
 *     chain_exec_id number;
 *   begin
 *     -- Register chain execution first
 *     chain_exec_id := PCK_BATCH_MANAGER.chain_execution_register(
 *       'MONTHLY_REPORT_CHAIN', 'scheduled', false, 'Monthly report generation'
 *     );
 *     
 *     -- Start the chain execution
 *     PCK_BATCH_MANAGER.startChainExecution(chain_exec_id);
 *     dbms_output.put_line('Chain execution started with ID: ' || chain_exec_id);
 *   end;
 *
 * Notes:
 *   - Chain execution ID must correspond to an existing chain execution record
 *   - Chain execution must be in 'registered' status before starting
 *   - Starting a chain sets its status to 'running' and records start time
 *   - Chain execution can be monitored through V_BATCH_CHAIN_EXECUTIONS view
 *   - Failed chain starts are logged with detailed error information
 *   - Chain execution status affects the overall batch system monitoring
 *   - Starting a chain triggers the execution of its first process
 **/
procedure startChainExecution( chain_execution_id in number ) ;

/**
 * Procedure: reportStartOfChainExecution
 * Description: Generates and sends notification reports about the start of a chain execution.
 *              This procedure handles automated reporting of chain execution initiation,
 *              including email notifications and logging for monitoring and alerting purposes.
 *
 * Parameters:
 *   chainExecID: Unique identifier of the chain execution to report
 *
 * Returns:
 *   None
 *
 * Example:
 *   declare
 *     chain_exec_id number;
 *   begin
 *     -- Start chain execution
 *     PCK_BATCH_MANAGER.startChainExecution(chain_exec_id);
 *     
 *     -- Report the start of execution
 *     PCK_BATCH_MANAGER.reportStartOfChainExecution(chain_exec_id);
 *     dbms_output.put_line('Chain execution start reported for ID: ' || chain_exec_id);
 *   end;
 *
 * Notes:
 *   - Chain execution ID must correspond to an active chain execution
 *   - Reports include chain details, start time, and execution context
 *   - Email notifications are sent to configured recipients if available
 *   - Reporting is asynchronous to avoid blocking chain execution
 *   - Start reports are logged for audit and monitoring purposes
 *   - Failed reporting doesn't affect chain execution status
 *   - Reports include chain definition and parameter information
 *   - Used for operational monitoring and alerting systems
 **/
procedure reportStartOfChainExecution( chainExecID in number ) ;

/**
 * Procedure: finishChainExecution
 * Description: Finishes a chain execution.
 *
 * Parameters:
 *   chainExecID: ID of the chain execution to finish.
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_MANAGER.finishChainExecution(1) ;
 *
 * Notes:
 *   - The chain execution id is used for finishing the chain execution.
 **/
procedure finishChainExecution( chainExecID in number ) ;

/**
 * Procedure: reportEndOfChainExecution
 * Description: Reports the end of a chain execution.
 *
 * Parameters:
 *   chainExecID: ID of the chain execution to report.
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_MANAGER.reportEndOfChainExecution(1) ;
 *
 * Notes:
 *   - The chain execution id is used for reporting the end of the chain execution.
 **/
 procedure reportEndOfChainExecution( chainExecID in number ) ;

/**
 * Procedure: startProcessExecution
 * Description: Starts a process execution.
 *
 * Parameters:
 *   process_execution_id: ID of the process execution to start.
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_MANAGER.startProcessExecution(1) ;
 *
 * Notes:
 *   - The process execution id is used for starting the process execution.
 **/
procedure startProcessExecution( process_execution_id in number ) ;

/**
 * Procedure: finishProcessExecution
 * Description: Marks a process execution as completed and updates its final status.
 *              This procedure finalizes the process execution lifecycle by recording
 *              completion details, timing, and final status for reporting and monitoring.
 *
 * Parameters:
 *   process_execution_id: Unique identifier of the process execution to finish
 *
 * Returns:
 *   None
 *
 * Example:
 *   declare
 *     proc_exec_id number;
 *   begin
 *     -- Complete process execution successfully
 *     PCK_BATCH_MANAGER.finishProcessExecution(proc_exec_id);
 *     dbms_output.put_line('Process execution finished for ID: ' || proc_exec_id);
 *     
 *     -- Or finish with specific status
 *     PCK_BATCH_MANAGER.process_exec_end_register(proc_exec_id, 'finished', 'All activities completed successfully');
 *   end;
 *
 * Notes:
 *   - Process execution ID must correspond to an active process execution
 *   - Finishing a process sets its status to 'finished' and records end time
 *   - Process execution duration is calculated from start to finish time
 *   - Final status affects the overall chain execution status
 *   - Process completion triggers final reporting and cleanup operations
 *   - Failed process completions are logged with detailed error information
 *   - Process execution history is preserved for audit and performance analysis
 *   - Completion details are used for operational reporting and alerting
 **/
procedure finishProcessExecution( process_execution_id in number ) ;

/**
 * Procedure: reportStartOfProcessExecution
 * Description: Reports the start of a process execution.
 *
 * Parameters:
 *   process_execution_id: ID of the process execution to report.
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_MANAGER.reportStartOfProcessExecution(1) ;
 *
 * Notes:
 *   - The process execution id is used for reporting the start of the process execution.
 **/
procedure reportStartOfProcessExecution( process_execution_id in number ) ;

/**
 * Procedure: reportEndOfProcessExecution
 * Description: Reports the end of a process execution.
 *
 * Parameters:
 *   process_execution_id: ID of the process execution to report.
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_MANAGER.reportEndOfProcessExecution(1) ;
 *
 * Notes:
 *   - The process execution id is used for reporting the end of the process execution.
 **/
procedure reportEndOfProcessExecution( process_execution_id in number ) ;

/**
 * Procedure: processActivityOutputs
 * Description: Processes the outputs of an activity execution.
 *
 * Parameters:
 *   activityExecution: Activity execution to process.
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_MANAGER.processActivityOutputs(activityExecution) ;
 *
 * Notes:
 *   - The activity execution is used for processing the outputs of the activity execution.
 **/
procedure processActivityOutputs( activityExecution in batch_activity_executions%rowtype) ;

/**
 * Procedure: evaluateText
 * Description: Evaluates a text.
 *
 * Parameters:
 *   text: Text to evaluate.
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_MANAGER.evaluateText('Hello, ${name}!') ;
 *
 * Notes:
 *   - The text is used for evaluating the text.
 **/
procedure evaluateText(text in out varchar2) ;

end PCK_BATCH_MANAGER ;

/

  GRANT EXECUTE ON PCK_BATCH_MANAGER TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_MANAGER TO ROLE_BATCH_MAN;
