/**
 * Package: PCK_BATCH_UTILS
 * Description: Utility procedures and functions for batch management.
 *              Provides administrative functions for creating and configuring
 *              batch chains, processes, and activities with proper validation
 *              and relationship management.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Chain, process, and activity creation and configuration
 *   - Relationship management between batch components
 *   - Duplicate activity handling and validation
 *   - Administrative utilities for batch system setup
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_UTILS AS

/**
 * Package: PCK_BATCH_UTILS
 * Description: Utility procedures and functions for batch management.
 *              Provides administrative functions for creating and configuring
 *              batch chains, processes, and activities with proper validation
 *              and relationship management.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Chain, process, and activity creation and configuration
 *   - Relationship management between batch components
 *   - Duplicate activity handling and validation
 *   - Administrative utilities for batch system setup
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

/**
 * Procedure: ignore_duplicate_activity
 * Description: Configures the behavior for handling duplicate activity definitions.
 *              Controls whether the system should ignore or raise errors when
 *              encountering duplicate activity codes during batch operations.
 *
 * Parameters:
 *   ignore: If true, duplicate activities are ignored; if false, errors are raised
 *
 * Returns:
 *   None
 *
 * Example:
 *   -- Configure to ignore duplicate activities
 *   PCK_BATCH_UTILS.ignore_duplicate_activity(true);
 *   
 *   -- Configure to raise errors for duplicates
 *   PCK_BATCH_UTILS.ignore_duplicate_activity(false);
 *
 * Notes:
 *   - Affects behavior of activity creation and validation
 *   - Useful for bulk operations where duplicates are expected
 *   - Default behavior is to ignore duplicates (true)
 *   - Setting affects subsequent batch operations
 **/

procedure ignore_duplicate_activity( ignore boolean default true )  ;

/**
 * Procedure: createChain
 * Description: Creates a new batch chain with specified configuration and rules.
 *              Establishes the top-level workflow structure for batch processing
 *              operations with proper validation and relationship management.
 *
 * Parameters:
 *   chain_code: Unique identifier for the chain
 *   chain_name: Human-readable name for the chain
 *   chain_description: Optional description of the chain's purpose
 *   chain_config: JSON configuration for the chain (default: '{}')
 *   chain_rules_set: Optional rules set for complex workflow logic
 *   chain_company_id: Optional company identifier for multi-company environments
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_UTILS.createChain(
 *     'MONTHLY_REPORT_CHAIN',
 *     'Monthly Report Generation',
 *     'Generates monthly financial reports for all companies',
 *     '{"timeout": 3600, "retry_count": 3}',
 *     'REPORT_RULES',
 *     'COMPANY_001'
 *   );
 *
 * Notes:
 *   - Chain code must be unique within the system
 *   - Configuration supports JSON format for flexible settings
 *   - Rules set enables complex workflow orchestration
 *   - Company ID enables multi-company batch processing
 **/

  procedure createChain( chain_code          in BATCH_CHAINS.code%type,
                         chain_name          in BATCH_CHAINS.name%type,
                         chain_description   in BATCH_CHAINS.description%type default null,
                         chain_config        in BATCH_CHAINS.config%type default '{}',
                         chain_rules_set     in BATCH_CHAINS.rules_set%type default null,
                         chain_company_id    in BATCH_CHAINS.config%type default null  );

/**
 * Procedure: createProcess
 * Description: Creates a new batch process with specified configuration and rules.
 *              Establishes a process-level workflow component that can contain
 *              multiple activities and be included in chains.
 *
 * Parameters:
 *   code: Unique identifier for the process
 *   name: Human-readable name for the process
 *   description: Optional description of the process's purpose
 *   config: JSON configuration for the process (default: '{}')
 *   rules_set: Optional rules set for process-level workflow logic
 *   propagate_failed_state: Whether to propagate failures to parent chain ('YES'/'NO')
 *   company_id: Optional company identifier for multi-company environments
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_UTILS.createProcess(
 *     'DATA_EXTRACTION_PROC',
 *     'Data Extraction Process',
 *     'Extracts data from multiple sources for reporting',
 *     '{"batch_size": 1000, "timeout": 1800}',
 *     'EXTRACTION_RULES',
 *     'YES',
 *     'COMPANY_001'
 *   );
 *
 * Notes:
 *   - Process code must be unique within the system
 *   - Propagate_failed_state controls error handling behavior
 *   - Configuration supports JSON format for flexible settings
 *   - Company ID enables multi-company batch processing
 **/

  procedure createProcess( code                    in BATCH_PROCESSES.code%type,
                           name                    in BATCH_PROCESSES.name%type,
                           description             in BATCH_PROCESSES.description%type default null,
                           config                  in BATCH_PROCESSES.config%type default '{}',
                           rules_set               in BATCH_PROCESSES.rules_set%type default null,
                           propagate_failed_state  in BATCH_PROCESSES.propagate_failed_state%type default 'NO',
                           company_id              in BATCH_PROCESSES.config%type default null  ) ;

/**
 * Procedure: createActivity
 * Description: Creates a new batch activity with specified action and configuration.
 *              Establishes the lowest-level executable unit in the batch processing
 *              hierarchy that performs actual work.
 *
 * Parameters:
 *   code: Unique identifier for the activity
 *   name: Human-readable name for the activity
 *   action: PL/SQL procedure or function to execute
 *   description: Optional description of the activity's purpose
 *   config: JSON configuration for the activity (default: '{}')
 *   propagate_failed_state: Whether to propagate failures to parent process ('YES'/'NO')
 *   company_id: Optional company identifier for multi-company environments
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_UTILS.createActivity(
 *     'EXTRACT_SALES_DATA',
 *     'Extract Sales Data',
 *     'PCK_SALES.extract_monthly_data',
 *     'Extracts sales data for monthly reporting',
 *     '{"date_format": "YYYY-MM-DD", "output_path": "/reports/"}',
 *     'YES',
 *     'COMPANY_001'
 *   );
 *
 * Notes:
 *   - Activity code must be unique within the system
 *   - Action must reference a valid PL/SQL procedure or function
 *   - Propagate_failed_state controls error handling behavior
 *   - Configuration supports JSON format for flexible settings
 **/

  procedure createActivity( code                    in BATCH_ACTIVITIES.code%type,
                            name                    in BATCH_ACTIVITIES.name%type,
                            action                  in BATCH_ACTIVITIES.action%type,
                            description             in BATCH_ACTIVITIES.description%type default null,
                            config                  in BATCH_ACTIVITIES.config%type default '{}',
                            propagate_failed_state  in BATCH_ACTIVITIES.propagate_failed_state%type default 'NO',
                            company_id              in BATCH_ACTIVITIES.config%type default null  );

/**
 * Procedure: addActivityToProcess
 * Description: Associates an activity with a process, establishing the relationship
 *              and execution order within the process workflow.
 *
 * Parameters:
 *   p_activity_code: Code of the activity to add to the process
 *   p_process_code: Code of the process to add the activity to
 *   p_activity_code_on_process: Optional custom code for the activity within the process
 *   p_activity_name_on_process: Optional custom name for the activity within the process
 *   p_predecessors: Comma-separated list of predecessor activity codes
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_UTILS.addActivityToProcess(
 *     'EXTRACT_SALES_DATA',
 *     'DATA_EXTRACTION_PROC',
 *     'SALES_EXTRACT',
 *     'Sales Data Extraction',
 *     'VALIDATE_PARAMETERS,CHECK_CONNECTIONS'
 *   );
 *
 * Notes:
 *   - Activity and process must exist before creating the relationship
 *   - Predecessors define execution dependencies and order
 *   - Custom codes and names allow process-specific customization
 *   - Multiple activities can be added to the same process
 **/

  procedure addActivityToProcess( p_activity_code in varchar2, 
                                  p_process_code in varchar2, 
                                  p_activity_code_on_process in varchar2 default null, 
                                  p_activity_name_on_process in varchar2 default null,
                                  p_predecessors in varchar2 default null );

/**
 * Procedure: addProcessToChain
 * Description: Associates a process with a chain, establishing the relationship
 *              and execution order within the chain workflow.
 *
 * Parameters:
 *   p_process_code: Code of the process to add to the chain
 *   p_chain_code: Code of the chain to add the process to
 *   p_predecessors: Comma-separated list of predecessor process codes
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_UTILS.addProcessToChain(
 *     'DATA_EXTRACTION_PROC',
 *     'MONTHLY_REPORT_CHAIN',
 *     'DATA_VALIDATION_PROC'
 *   );
 *
 * Notes:
 *   - Process and chain must exist before creating the relationship
 *   - Predecessors define execution dependencies and order
 *   - Multiple processes can be added to the same chain
 *   - Chain execution follows the defined predecessor relationships
 **/

  procedure addProcessToChain( p_process_code in varchar2,
                               p_chain_code in varchar2,
                               p_predecessors in varchar2 );

end PCK_BATCH_UTILS ;


/

  GRANT EXECUTE ON PCK_BATCH_UTILS TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_UTILS TO ROLE_HF_BATCH;
