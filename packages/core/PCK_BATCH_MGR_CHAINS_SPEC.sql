/**
 * Package: PCK_BATCH_MGR_CHAINS
 * Description: Comprehensive chain management utilities for batch processing operations.
 *              Provides functions for creating, configuring, and managing batch chains,
 *              processes, and activities with proper relationship management and
 *              execution orchestration capabilities.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Chain creation and configuration management
 *   - Process and activity creation within chains
 *   - Relationship management and dependency handling
 *   - Parameter configuration and value assignment
 *   - Chain launcher configuration for automated execution
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */
CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_MGR_CHAINS as
/**
 * Package: PCK_BATCH_MGR_CHAINS
 * Description: Comprehensive chain management utilities for batch processing operations.
 *              Provides functions for creating, configuring, and managing batch chains,
 *              processes, and activities with proper relationship management and
 *              execution orchestration capabilities.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Chain creation and configuration management
 *   - Process and activity creation within chains
 *   - Relationship management and dependency handling
 *   - Parameter configuration and value assignment
 *   - Chain launcher configuration for automated execution
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

/**
 * Function: create_chain
 * Description: Creates a new batch chain with specified configuration and metadata.
 *              Establishes the top-level workflow structure for batch processing
 *              operations with proper validation and relationship management.
 *
 * Parameters:
 *   p_name: Human-readable name for the chain
 *   p_code: Unique identifier code for the chain
 *   p_description: Optional description of the chain's purpose
 *   p_config: JSON configuration for the chain (default: '{}')
 *
 * Returns:
 *   BATCH_CHAINS%rowtype - Complete chain record with all metadata
 *
 * Example:
 *   declare
 *     chain_record batch_chains%rowtype;
 *   begin
 *     chain_record := pck_batch_mgr_chains.create_chain(
 *       'Monthly Report Generation',
 *       'MONTHLY_REPORT_CHAIN',
 *       'Generates monthly financial reports for all companies',
 *       '{"timeout": 3600, "retry_count": 3, "notification_email": "admin@company.com"}'
 *     );
 *     dbms_output.put_line('Chain created with ID: ' || chain_record.id);
 *   end;
 *
 * Notes:
 *   - Chain code must be unique within the system
 *   - Configuration supports JSON format for flexible settings
 *   - Chain is created in 'ACTIVE' status by default
 *   - Returns complete chain record for further operations
 *   - Used as foundation for building complex batch workflows
 **/

function create_chain( p_name in varchar2
                      ,p_code in varchar2
                      ,p_description in varchar2 default null
                      ,p_config in varchar2 default '{}' ) return BATCH_CHAINS%rowtype ;

/**
 * Function: create_process
 * Description: Creates a new batch process with specified configuration and metadata.
 *              Establishes a process-level workflow component that can contain
 *              multiple activities and be included in chains.
 *
 * Parameters:
 *   p_name: Human-readable name for the process
 *   p_code: Unique identifier code for the process
 *   p_description: Optional description of the process's purpose
 *   p_config: JSON configuration for the process (default: '{}')
 *   p_chain: Optional chain code to associate the process with
 *   p_order: Optional execution order within the chain
 *
 * Returns:
 *   batch_processes%rowtype - Complete process record with all metadata
 *
 * Example:
 *   declare
 *     process_record batch_processes%rowtype;
 *   begin
 *     process_record := pck_batch_mgr_chains.create_process(
 *       'Data Extraction Process',
 *       'DATA_EXTRACTION_PROC',
 *       'Extracts data from multiple sources for reporting',
 *       '{"batch_size": 1000, "timeout": 1800, "parallel_jobs": 4}',
 *       'MONTHLY_REPORT_CHAIN',
 *       '1'
 *     );
 *     dbms_output.put_line('Process created with ID: ' || process_record.id);
 *   end;
 *
 * Notes:
 *   - Process code must be unique within the system
 *   - Configuration supports JSON format for flexible settings
 *   - Process is created in 'ACTIVE' status by default
 *   - Chain association enables automatic relationship management
 *   - Order parameter controls execution sequence within chains
 **/

function create_process( p_name in varchar2
                        ,p_code in varchar2
                        ,p_description in varchar2 default null
                        ,p_config in varchar2 default '{}'
                        ,p_chain in varchar2 default null
                        ,p_order in varchar2 default null
                        ) return batch_processes%rowtype ;

/**
 * Function: create_activity
 * Description: Creates a new batch activity with specified action and configuration.
 *              Establishes the lowest-level executable unit in the batch processing
 *              hierarchy that performs actual work.
 *
 * Parameters:
 *   p_name: Human-readable name for the activity
 *   p_action: PL/SQL procedure or function to execute
 *   p_code: Unique identifier code for the activity
 *   p_description: Optional description of the activity's purpose
 *   p_parameters: JSON configuration for activity parameters (default: '{}')
 *
 * Returns:
 *   batch_activities%rowtype - Complete activity record with all metadata
 *
 * Example:
 *   declare
 *     activity_record batch_activities%rowtype;
 *   begin
 *     activity_record := pck_batch_mgr_chains.create_activity(
 *       'Extract Sales Data',
 *       'PCK_SALES.extract_monthly_data',
 *       'EXTRACT_SALES_DATA',
 *       'Extracts sales data for monthly reporting',
 *       '{"date_format": "YYYY-MM-DD", "output_path": "/reports/", "include_details": true}'
 *     );
 *     dbms_output.put_line('Activity created with ID: ' || activity_record.id);
 *   end;
 *
 * Notes:
 *   - Activity code must be unique within the system
 *   - Action must reference a valid PL/SQL procedure or function
 *   - Parameters support JSON format for flexible configuration
 *   - Activity is created in 'ACTIVE' status by default
 *   - Used for building the execution components of processes
 **/

function create_activity( p_name in varchar2
                         ,p_action in varchar2
                         ,p_code in varchar2
                         ,p_description in varchar2 default null
                         ,p_parameters in varchar2 default '{}' ) return batch_activities%rowtype ;

/**
 * Procedure: add_process_to_chain
 * Description: Associates a process with a chain, establishing the relationship
 *              and execution order within the chain workflow.
 *
 * Parameters:
 *   p_chain: Chain record to add the process to
 *   p_process: Process record to be added to the chain
 *   p_predecesors: JSON array of predecessor process codes (default: '{}')
 *   comments: Optional comments describing the relationship
 *
 * Returns:
 *   None
 *
 * Example:
 *   declare
 *     chain_record batch_chains%rowtype;
 *     process_record batch_processes%rowtype;
 *   begin
 *     -- Get existing chain and process
 *     chain_record := pck_batch_mgr_chains.getChainById(1);
 *     process_record := pck_batch_mgr_chains.create_process('Validation', 'VALID_PROC');
 *     
 *     -- Add process to chain
 *     pck_batch_mgr_chains.add_process_to_chain(
 *       chain_record,
 *       process_record,
 *       '["DATA_EXTRACTION_PROC"]',
 *       'Data validation after extraction'
 *     );
 *   end;
 *
 * Notes:
 *   - Chain and process must exist before creating the relationship
 *   - Predecessors define execution dependencies and order
 *   - Multiple processes can be added to the same chain
 *   - Chain execution follows the defined predecessor relationships
 *   - Comments are stored for audit and documentation purposes
 **/

procedure add_process_to_chain( p_chain in BATCH_CHAINS%rowtype
                               ,p_process in BATCH_PROCESSES%rowtype
                               ,p_predecesors in varchar2 default'{}'
                               ,comments in varchar2 default null ) ;

/**
 * Function: add_activity_to_process
 * Description: Associates an activity with a process, establishing the relationship
 *              and execution order within the process workflow.
 *
 * Parameters:
 *   p_process: Process record to add the activity to
 *   p_activity: Activity record to be added to the process
 *   p_name: Custom name for the activity within the process
 *   p_config: JSON configuration for the activity within the process (default: '{}')
 *   p_predecessors: JSON array of predecessor activity codes (default: '{}')
 *
 * Returns:
 *   batch_process_activities%rowtype - Process activity relationship record
 *
 * Example:
 *   declare
 *     process_record batch_processes%rowtype;
 *     activity_record batch_activities%rowtype;
 *     proc_activ_record batch_process_activities%rowtype;
 *   begin
 *     -- Get existing process and activity
 *     process_record := pck_batch_mgr_chains.create_process('Extraction', 'EXTRACT_PROC');
 *     activity_record := pck_batch_mgr_chains.create_activity('Sales Extract', 'PCK_SALES.extract', 'SALES_EXTRACT');
 *     
 *     -- Add activity to process
 *     proc_activ_record := pck_batch_mgr_chains.add_activity_to_process(
 *       process_record,
 *       activity_record,
 *       'Sales Data Extraction',
 *       '{"batch_size": 500, "timeout": 900}',
 *       '["VALIDATE_PARAMS"]'
 *     );
 *   end;
 *
 * Notes:
 *   - Process and activity must exist before creating the relationship
 *   - Predecessors define execution dependencies and order
 *   - Custom names allow process-specific activity identification
 *   - Configuration can override default activity settings
 *   - Returns relationship record for further parameter configuration
 **/

function add_activity_to_process( p_process in BATCH_PROCESSES%rowtype
                                 ,p_activity in BATCH_ACTIVITIES%rowtype
                                 ,p_name in varchar2
                                 ,p_config in varchar2 default '{}'
                                 ,p_predecessors in varchar2 default '{}' ) return batch_process_activities%rowtype  ;

/**
 * Function: create_activity_parameter
 * Description: Creates a parameter definition for an activity with type and metadata.
 *              Establishes the parameter structure that activities can accept
 *              during execution with proper validation and default values.
 *
 * Parameters:
 *   activity: Activity record to create the parameter for
 *   parameter_name: Name of the parameter
 *   parameter_type: Data type of the parameter (NUMBER, VARCHAR2, DATE, etc.)
 *   parameter_position: Position of the parameter in the activity signature
 *   parameter_description: Optional description of the parameter's purpose
 *   parameter_default_value: Optional default value for the parameter
 *
 * Returns:
 *   batch_activity_parameters%rowtype - Parameter definition record
 *
 * Example:
 *   declare
 *     activity_record batch_activities%rowtype;
 *     param_record batch_activity_parameters%rowtype;
 *   begin
 *     activity_record := pck_batch_mgr_chains.create_activity('Extract', 'PCK_DATA.extract', 'EXTRACT_DATA');
 *     
 *     param_record := pck_batch_mgr_chains.create_activity_parameter(
 *       activity_record,
 *       'start_date',
 *       'DATE',
 *       1,
 *       'Start date for data extraction',
 *       'sysdate - 30'
 *     );
 *   end;
 *
 * Notes:
 *   - Activity must exist before creating parameters
 *   - Parameter names must be unique within the activity
 *   - Position determines parameter order in activity calls
 *   - Default values are evaluated at runtime
 *   - Used for parameter validation and documentation
 **/

function create_activity_parameter( activity batch_activities%rowtype
                                  ,parameter_name in varchar2
                                  ,parameter_type in varchar2
                                  ,parameter_position in number
                                  ,parameter_description in varchar2 default null
                                  ,parameter_default_value in varchar2 default null ) return batch_activity_parameters%rowtype ;

/**
 * Procedure: add_proc_activ_param_value
 * Description: Assigns a specific value to a process activity parameter.
 *              Sets runtime parameter values for activities within process contexts,
 *              enabling process-specific parameter customization.
 *
 * Parameters:
 *   proc_activ_id: Process activity relationship identifier
 *   activ_param_id: Activity parameter identifier
 *   parameter_value: Value to assign to the parameter (default: null)
 *
 * Returns:
 *   None
 *
 * Example:
 *   declare
 *     proc_activ_id number := 123;
 *     activ_param_id number := 456;
 *   begin
 *     pck_batch_mgr_chains.add_proc_activ_param_value(
 *       proc_activ_id,
 *       activ_param_id,
 *       '2024-01-01'
 *     );
 *   end;
 *
 * Notes:
 *   - Process activity and parameter must exist before assignment
 *   - Values override default parameter values at runtime
 *   - Null values use parameter defaults if available
 *   - Used for process-specific parameter customization
 *   - Values are validated against parameter type definitions
 **/

procedure add_proc_activ_param_value( proc_activ_id number,
                                      activ_param_id in number,
                                      parameter_value in varchar2 default null ) ;

/**
 * Function: getChainById
 * Description: Retrieves complete chain information by its unique identifier.
 *              Returns the full chain definition including name, description, status,
 *              and all associated metadata from the BATCH_CHAINS table.
 *
 * Parameters:
 *   chain_id: Unique identifier of the chain to retrieve
 *
 * Returns:
 *   batch_chains%rowtype - Complete chain record with all columns
 *
 * Example:
 *   declare
 *     chain_record batch_chains%rowtype;
 *   begin
 *     chain_record := pck_batch_mgr_chains.getChainById(1);
 *     if chain_record is not null then
 *       dbms_output.put_line('Chain: ' || chain_record.name || ' - Status: ' || chain_record.status);
 *       dbms_output.put_line('Code: ' || chain_record.code || ' - Config: ' || chain_record.config);
 *     end if;
 *   end;
 *
 * Notes:
 *   - Chain ID must exist in BATCH_CHAINS table
 *   - Returns complete chain record with all metadata and configuration
 *   - Useful for validation before chain execution
 *   - Can be used to check chain status and configuration
 *   - Chain information includes process relationships and execution context
 **/

function getChainById(chain_id in number) return batch_chains%rowtype  ;

/**
 * Function: getChainExecutionById
 * Description: Retrieves complete chain execution information by its unique identifier.
 *              Returns detailed execution data including timing, status, and results
 *              from the BATCH_CHAIN_EXECUTIONS table.
 *
 * Parameters:
 *   execution_id: Unique identifier of the chain execution to retrieve
 *
 * Returns:
 *   BATCH_CHAIN_EXECUTIONS%rowtype - Complete execution record with all columns
 *
 * Example:
 *   declare
 *     execution_record batch_chain_executions%rowtype;
 *   begin
 *     execution_record := pck_batch_mgr_chains.getChainExecutionById(12345);
 *     if execution_record is not null then
 *       dbms_output.put_line('Execution ID: ' || execution_record.id);
 *       dbms_output.put_line('Chain ID: ' || execution_record.chain_id);
 *       dbms_output.put_line('Status: ' || execution_record.status);
 *       dbms_output.put_line('Start Time: ' || execution_record.start_time);
 *     end if;
 *   end;
 *
 * Notes:
 *   - Execution ID must exist in BATCH_CHAIN_EXECUTIONS table
 *   - Returns complete execution record with all timing and status information
 *   - Useful for execution monitoring and troubleshooting
 *   - Includes execution context and result information
 *   - Can be used for performance analysis and audit purposes
 **/

function getChainExecutionById(execution_id in number) return BATCH_CHAIN_EXECUTIONS%rowtype ;

/**
 * Procedure: set_chain_launcher
 * Description: Configures automated launcher settings for a chain.
 *              Enables scheduled or event-driven execution of chains
 *              with configurable parameters and conditions.
 *
 * Parameters:
 *   chain_id: Unique identifier of the chain to configure
 *   new_config: JSON configuration for the chain launcher
 *
 * Returns:
 *   None
 *
 * Example:
 *   begin
 *     pck_batch_mgr_chains.set_chain_launcher(
 *       1,
 *       '{"schedule": "FREQ=DAILY; BYHOUR=2", "enabled": true, "max_retries": 3}'
 *     );
 *   end;
 *
 * Notes:
 *   - Chain must exist before configuring launcher
 *   - Configuration supports various scheduling options
 *   - Enables automated chain execution without manual intervention
 *   - Configuration includes retry logic and error handling
 *   - Used for production automation and scheduled batch processing
 **/

procedure set_chain_launcher( chain_id in number, new_config in varchar2 ) ;

/**
 * Procedure: remove_chain_launcher
 * Description: Removes automated launcher configuration from a chain.
 *              Disables scheduled or event-driven execution, returning
 *              the chain to manual execution mode only.
 *
 * Parameters:
 *   chain_id: Unique identifier of the chain to remove launcher from
 *
 * Returns:
 *   None
 *
 * Example:
 *   begin
 *     pck_batch_mgr_chains.remove_chain_launcher(1);
 *     dbms_output.put_line('Chain launcher removed for chain ID: 1');
 *   end;
 *
 * Notes:
 *   - Chain must exist before removing launcher
 *   - Disables all automated execution for the chain
 *   - Chain can still be executed manually
 *   - Used for maintenance or configuration changes
 *   - Safe operation that doesn't affect chain definition
 **/

procedure remove_chain_launcher( chain_id in number ) ;

end PCK_BATCH_MGR_CHAINS ;

/

  GRANT EXECUTE ON PCK_BATCH_MGR_CHAINS TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_MGR_CHAINS TO ROLE_HF_BATCH;
