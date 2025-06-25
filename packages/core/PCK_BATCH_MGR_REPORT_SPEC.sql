/**
 * Package: PCK_BATCH_MGR_REPORT
 * Description: Comprehensive reporting utilities for batch processing operations.
 *              Provides functions for generating reports through Oracle Reports Server,
 *              managing report parameters, and handling report execution lifecycle
 *              with proper logging and error handling.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Oracle Reports Server integration for report generation
 *   - Dynamic parameter list creation and management
 *   - Report execution with comprehensive logging
 *   - Timestamped file naming for report outputs
 *   - Gateway configuration for report server connectivity
 *   - Error handling and recovery mechanisms
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */



  CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_MGR_REPORT AS
/**
 * Package: PCK_BATCH_MGR_REPORT
 * Description: Comprehensive reporting utilities for batch processing operations.
 *              Provides functions for generating reports through Oracle Reports Server,
 *              managing report parameters, and handling report execution lifecycle
 *              with proper logging and error handling.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Oracle Reports Server integration for report generation
 *   - Dynamic parameter list creation and management
 *   - Report execution with comprehensive logging
 *   - Timestamped file naming for report outputs
 *   - Gateway configuration for report server connectivity
 *   - Error handling and recovery mechanisms
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

 
/**
 * Procedure: set_gateway
 * Description: Configures the gateway URL for Oracle Reports Server connectivity.
 *              Sets the endpoint URL that will be used for all report generation
 *              operations, allowing dynamic configuration of the report server
 *              connection without code changes.
 *
 * Parameters:
 *   gateway: URL endpoint for the Oracle Reports Server gateway
 *
 * Returns:
 *   None
 *
 * Example:
 *   -- Configure report server gateway
 *   PCK_BATCH_MGR_REPORT.set_gateway('http://reports.company.com/cgi-bin/rwcgi60.exe/runp');
 *   
 *   -- Use environment variable for gateway
 *   PCK_BATCH_MGR_REPORT.set_gateway(environmentMap('REPORTSERVER_GATEWAY'));
 *
 * Notes:
 *   - Gateway URL is stored in package variable for subsequent report operations
 *   - Used by PCK_BATCH_MANAGER for dynamic gateway configuration
 *   - Supports both HTTP and HTTPS endpoints
 *   - Gateway configuration affects all report generation operations
 **/

procedure set_gateway(gateway in varchar2) ;

/**
 * Function: get_new_report_param_list
 * Description: Creates a new parameter list for Oracle Reports Server report execution.
 *              Builds a comprehensive parameter list including gateway configuration,
 *              report name, destination settings, and database connection parameters
 *              required for successful report generation.
 *
 * Parameters:
 *   p_report_name: Name of the report to be executed (must exist on Reports Server)
 *   p_desname: Destination name for the generated report file
 *   p_destype: Destination type for report output (default: 'FILE')
 *   p_desformat: Output format for the report (default: 'PDF')
 *
 * Returns:
 *   srw_paramlist - Parameter list configured for report execution
 *
 * Example:
 *   declare
 *     param_list srw_paramlist;
 *   begin
 *     param_list := PCK_BATCH_MGR_REPORT.get_new_report_param_list(
 *       'MONTHLY_SALES_REPORT',
 *       '/reports/sales_2024_01.pdf',
 *       'FILE',
 *       'PDF'
 *     );
 *   end;
 *
 * Notes:
 *   - Automatically includes gateway configuration from set_gateway()
 *   - Database connection string is configured from environment settings
 *   - Supports various output formats: PDF, HTML, RTF, etc.
 *   - Destination types include FILE, EMAIL, PRINTER, etc.
 *   - Parameter list is ready for use with run_report() function
 **/

function get_new_report_param_list( p_report_name in varchar2,
                                    p_desname in varchar2,
                                    p_destype in varchar2 default 'FILE',
                                    p_desformat in varchar2 default 'PDF') return srw_paramlist ;

/**
 * Function: run_report
 * Description: Executes a report using Oracle Reports Server with comprehensive logging.
 *              Generates reports based on the provided parameter list, handles execution
 *              lifecycle, and provides detailed logging of the report generation process
 *              including success/failure status and error information.
 *
 * Parameters:
 *   parametersList: Parameter list created by get_new_report_param_list()
 *   exec_id: Optional execution ID for linking report generation to batch execution
 *   message: Optional message to include in log entries for report identification
 *
 * Returns:
 *   srw.job_ident - Job identifier for the report execution
 *
 * Example:
 *   declare
 *     param_list srw_paramlist;
 *     job_id srw.job_ident;
 *   begin
 *     -- Create parameter list
 *     param_list := PCK_BATCH_MGR_REPORT.get_new_report_param_list(
 *       'SALES_REPORT', '/reports/sales.pdf'
 *     );
 *     
 *     -- Execute report
 *     job_id := PCK_BATCH_MGR_REPORT.run_report(
 *       param_list, 
 *       75634, 
 *       'SALDOS A FAVOR DEVUELTOS'
 *     );
 *   end;
 *
 * Notes:
 *   - Automatically logs start and completion of report generation
 *   - Handles Oracle Reports Server errors gracefully
 *   - Links report execution to batch execution context when exec_id provided
 *   - Returns job identifier for tracking report execution status
 *   - Supports error recovery and retry mechanisms
 *   - Logs are stored in BATCH_SIMPLE_LOG table for audit purposes
 **/

function run_report(    parametersList in srw_paramlist, -- parametros que definen la ejecucin del reporte
                        exec_id in number default null, -- id de la ejecucin desde la que est siendo invocado
                        message in varchar2 default null -- mensaje para incluir como referencia en BATCH_SIMPLE_LOG
                    ) return srw.job_ident ;

/**
 * Function: getTimestampedName
 * Description: Generates a timestamped filename for report outputs.
 *              Creates unique filenames by appending current timestamp to the base
 *              filename, ensuring no filename conflicts and providing chronological
 *              organization of generated reports.
 *
 * Parameters:
 *   p_desname: Base filename for the report
 *   p_destype: File extension/type (default: 'pdf')
 *
 * Returns:
 *   varchar2 - Timestamped filename with format: filename.yyyy-mm-dd_hh24-mi-ss.ext
 *
 * Example:
 *   declare
 *     timestamped_name varchar2(200);
 *   begin
 *     timestamped_name := PCK_BATCH_MGR_REPORT.getTimestampedName(
 *       'monthly_report', 'pdf'
 *     );
 *     -- Result: monthly_report.2024-01-15_14-30-25.pdf
 *   end;
 *
 * Notes:
 *   - Timestamp format: YYYY-MM-DD_HH24-MI-SS
 *   - Ensures unique filenames for concurrent report generations
 *   - Useful for report archiving and version control
 *   - Supports any file extension/type
 *   - Timestamp is based on current system time
 **/

function getTimestampedName( p_desname in varchar2, p_destype in varchar2 default 'pdf' ) return varchar2 ;

end  ;



/

  GRANT EXECUTE ON PCK_BATCH_MGR_REPORT TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_MGR_REPORT TO ROLE_BATCH_MAN;
