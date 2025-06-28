/**
 * Package: PCK_BATCH_MGR_LOG
 * Description: Comprehensive logging and audit system for batch processing operations.
 *              Provides centralized logging capabilities for batch chains, processes,
 *              and activities with support for different log levels, execution context
 *              tracking, and automatic transaction management for reliable log persistence.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Multi-level logging (debug, log, info, alert, error, form_trigger_failure)
 *   - Execution context linking (chain, process, activity execution IDs)
 *   - Autonomous transaction support for reliable logging
 *   - Company-specific logging for multi-tenant environments
 *   - Automatic timestamp and sequence ID generation
 *   - Integration with BATCH_LOGGER type for enhanced logging
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

  CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_MGR_LOG AS
/**
 * Package: PCK_BATCH_MGR_LOG
 * Description: Comprehensive logging and audit system for batch processing operations.
 *              Provides centralized logging capabilities for batch chains, processes,
 *              and activities with support for different log levels, execution context
 *              tracking, and automatic transaction management for reliable log persistence.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Multi-level logging (debug, log, info, alert, error, form_trigger_failure)
 *   - Execution context linking (chain, process, activity execution IDs)
 *   - Autonomous transaction support for reliable logging
 *   - Company-specific logging for multi-tenant environments
 *   - Automatic timestamp and sequence ID generation
 *   - Integration with BATCH_LOGGER type for enhanced logging
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */


/**
 * Procedure: log
 * Description: Records a log entry with comprehensive context information.
 *              Creates a detailed log record in the BATCH_SIMPLE_LOG table with
 *              execution context, log level, and optional data payload for
 *              complete audit trail and troubleshooting capabilities.
 *
 * Parameters:
 *   log_text: Text message to be logged
 *   log_data: Optional CLOB data for additional information (default: null)
 *   activity_exec_id: Optional activity execution ID for context linking (default: null)
 *   process_exec_id: Optional process execution ID for context linking (default: null)
 *   chain_exec_id: Optional chain execution ID for context linking (default: null)
 *   log_type: Log level/type (default: null, uses package default)
 *   company_id: Optional company identifier for multi-tenant logging (default: null)
 *
 * Returns:
 *   None
 *
 * Example:
 *   -- Basic log entry
 *   pck_batch_mgr_log.log('Process started successfully');
 *   
 *   -- Detailed log with context
 *   pck_batch_mgr_log.log(
 *     'Data extraction completed',
 *     '{"records_processed": 15000, "duration_seconds": 45}',
 *     123,  -- activity_exec_id
 *     456,  -- process_exec_id
 *     789,  -- chain_exec_id
 *     'info',
 *     1     -- company_id
 *   );
 *
 * Notes:
 *   - Uses autonomous transaction for reliable logging even if main transaction fails
 *   - Automatically generates sequence ID and timestamp
 *   - Log entries are stored in BATCH_SIMPLE_LOG table
 *   - Supports linking to execution context for complete audit trail
 *   - Used extensively by BATCH_LOGGER type and other batch components
 *   - Log type determines visibility and filtering in monitoring tools
 **/

procedure log( log_text             in varchar2,
               log_data             in clob default null,
               activity_exec_id     in number default null,
               process_exec_id      in number default null,
               chain_exec_id        in number default null,
               log_type             in varchar2 default null,
               company_id           in number default null ) ;

/**
 * Procedure: autoRaise (Setter)
 * Description: Configures the automatic exception raising behavior for logging operations.
 *              Controls whether the logging system should automatically raise exceptions
 *              when logging errors occur, allowing for flexible error handling strategies.
 *
 * Parameters:
 *   p_auto_rise: If true, exceptions are automatically raised; if false, exceptions are suppressed
 *
 * Returns:
 *   None
 *
 * Example:
 *   -- Enable automatic exception raising
 *   pck_batch_mgr_log.autoRaise(true);
 *   
 *   -- Disable automatic exception raising
 *   pck_batch_mgr_log.autoRaise(false);
 *
 * Notes:
 *   - Affects behavior of all logging operations in the package
 *   - Default value is true (exceptions are raised)
 *   - Useful for controlling error propagation in batch operations
 *   - Setting affects subsequent log() calls
 *   - Used by BATCH_LOGGER type for error handling configuration
 **/

procedure autoRaise(p_auto_rise in boolean) ;

/**
 * Function: autoRaise (Getter)
 * Description: Retrieves the current automatic exception raising configuration.
 *              Returns the current setting for automatic exception raising behavior
 *              to allow components to adapt their error handling accordingly.
 *
 * Parameters:
 *   None
 *
 * Returns:
 *   boolean - Current auto-raise setting (true = raise exceptions, false = suppress)
 *
 * Example:
 *   declare
 *     current_setting boolean;
 *   begin
 *     current_setting := pck_batch_mgr_log.autoRaise();
 *     if current_setting then
 *       dbms_output.put_line('Auto-raise is enabled');
 *     else
 *       dbms_output.put_line('Auto-raise is disabled');
 *     end if;
 *   end;
 *
 * Notes:
 *   - Returns the current package-level auto-raise setting
 *   - Used by BATCH_LOGGER type to determine error handling behavior
 *   - Allows components to check current configuration before operations
 *   - Default return value is true if not explicitly set
 **/

function autoRaise return boolean ;

end PCK_BATCH_MGR_LOG;


/

  GRANT EXECUTE ON PCK_BATCH_MGR_LOG TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_MGR_LOG TO ROLE_HF_BATCH;
