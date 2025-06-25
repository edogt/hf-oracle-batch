/**
 * Package: PCK_BATCH_MGR_ACTIVITIES
 * Description: Comprehensive activity management utilities for batch processing operations.
 *              Provides functions for creating, managing, and executing batch activities
 *              with parameter handling, execution tracking, and output management.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Activity creation and configuration management
 *   - Parameter handling with type safety
 *   - Activity execution tracking and monitoring
 *   - Output management and result processing
 *   - Integration with batch execution lifecycle
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_MGR_ACTIVITIES AS
/**
 * Package: PCK_BATCH_MGR_ACTIVITIES
 * Description: Comprehensive activity management utilities for batch processing operations.
 *              Provides functions for creating, managing, and executing batch activities
 *              with parameter handling, execution tracking, and output management.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Activity creation and configuration management
 *   - Parameter handling with type safety
 *   - Activity execution tracking and monitoring
 *   - Output management and result processing
 *   - Integration with batch execution lifecycle
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

-- Type definitions for activity parameter handling
type ActionParamTypedValue_type is record (
number_value    number,
v2_value        varchar2(5000),
date_value      date
) ;

type ActionParamTypedValList_type is table of ActionParamTypedValue_type index by varchar2(30) ;

type ActivityOutputsList_type is table of batch_activity_outputs%rowtype index by binary_integer ;

/**
 * Procedure: add_parameterValue (Number)
 * Description: Adds a numeric parameter value to a typed parameter list.
 *              This procedure handles the safe addition of number-type parameters
 *              to activity parameter collections with proper type validation.
 *
 * Parameters:
 *   param_list: IN OUT parameter list to add the value to
 *   param_name: Name of the parameter to add
 *   param_value: Numeric value to assign to the parameter
 *
 * Returns:
 *   None (param_list is modified in place)
 *
 * Example:
 *   declare
 *     param_list pck_batch_mgr_activities.ActionParamTypedValList_type;
 *   begin
 *     pck_batch_mgr_activities.add_parameterValue(param_list, 'batch_size', 1000);
 *     pck_batch_mgr_activities.add_parameterValue(param_list, 'timeout_seconds', 300);
 *   end;
 *
 * Notes:
 *   - Parameter list is modified in place (IN OUT parameter)
 *   - Number values are stored in the number_value field of the record
 *   - Parameter names must be unique within the list
 *   - Used for building parameter collections for activity execution
 **/

procedure add_parameterValue(param_list in out ActionParamTypedValList_type, param_name in varchar2, param_value in number ) ;

/**
 * Procedure: add_parameterValue (Varchar2)
 * Description: Adds a string parameter value to a typed parameter list.
 *              This procedure handles the safe addition of varchar2-type parameters
 *              to activity parameter collections with proper type validation.
 *
 * Parameters:
 *   param_list: IN OUT parameter list to add the value to
 *   param_name: Name of the parameter to add
 *   param_value: String value to assign to the parameter
 *
 * Returns:
 *   None (param_list is modified in place)
 *
 * Example:
 *   declare
 *     param_list pck_batch_mgr_activities.ActionParamTypedValList_type;
 *   begin
 *     pck_batch_mgr_activities.add_parameterValue(param_list, 'file_path', '/data/reports/');
 *     pck_batch_mgr_activities.add_parameterValue(param_list, 'report_type', 'monthly');
 *   end;
 *
 * Notes:
 *   - Parameter list is modified in place (IN OUT parameter)
 *   - String values are stored in the v2_value field of the record
 *   - Supports up to 5000 characters per parameter value
 *   - Parameter names must be unique within the list
 **/

procedure add_parameterValue(param_list in out ActionParamTypedValList_type, param_name in varchar2, param_value in varchar2 ) ;

/**
 * Procedure: add_parameterValue (Date)
 * Description: Adds a date parameter value to a typed parameter list.
 *              This procedure handles the safe addition of date-type parameters
 *              to activity parameter collections with proper type validation.
 *
 * Parameters:
 *   param_list: IN OUT parameter list to add the value to
 *   param_name: Name of the parameter to add
 *   param_value: Date value to assign to the parameter
 *
 * Returns:
 *   None (param_list is modified in place)
 *
 * Example:
 *   declare
 *     param_list pck_batch_mgr_activities.ActionParamTypedValList_type;
 *   begin
 *     pck_batch_mgr_activities.add_parameterValue(param_list, 'start_date', date '2024-01-01');
 *     pck_batch_mgr_activities.add_parameterValue(param_list, 'end_date', sysdate);
 *   end;
 *
 * Notes:
 *   - Parameter list is modified in place (IN OUT parameter)
 *   - Date values are stored in the date_value field of the record
 *   - Supports standard Oracle date format
 *   - Parameter names must be unique within the list
 **/

procedure add_parameterValue(param_list in out ActionParamTypedValList_type, param_name in varchar2, param_value in date ) ;

/**
 * Function: getActivityById
 * Description: Retrieves complete activity information by its unique identifier.
 *              Returns the full activity definition including name, description, status,
 *              and all associated metadata from the BATCH_ACTIVITIES table.
 *
 * Parameters:
 *   activity_id: Unique identifier of the activity to retrieve
 *
 * Returns:
 *   BATCH_ACTIVITIES%rowtype - Complete activity record with all columns
 *
 * Example:
 *   declare
 *     activity batch_activities%rowtype;
 *   begin
 *     activity := pck_batch_mgr_activities.getActivityById('123');
 *     if activity is not null then
 *       dbms_output.put_line('Activity: ' || activity.name || ' - Status: ' || activity.status);
 *       dbms_output.put_line('Action: ' || activity.action || ' - Code: ' || activity.code);
 *     end if;
 *   end;
 *
 * Notes:
 *   - Activity ID must exist in BATCH_ACTIVITIES table
 *   - Returns complete activity record with all metadata and configuration
 *   - Useful for validation before activity execution
 *   - Can be used to check activity status and parameter requirements
 *   - Activity information includes parameter definitions and execution context
 **/

function getActivityById(activity_id in varchar2) return BATCH_ACTIVITIES%rowtype ;

/**
 * Function: getActivityExecutionById
 * Description: Retrieves complete activity execution information by its unique identifier.
 *              Returns detailed execution data including timing, status, parameters,
 *              and results from the BATCH_ACTIVITY_EXECUTIONS table.
 *
 * Parameters:
 *   execution_id: Unique identifier of the activity execution to retrieve
 *
 * Returns:
 *   batch_activity_executions%rowtype - Complete execution record with all columns
 *
 * Example:
 *   declare
 *     execution batch_activity_executions%rowtype;
 *   begin
 *     execution := pck_batch_mgr_activities.getActivityExecutionById(12345);
 *     if execution is not null then
 *       dbms_output.put_line('Execution ID: ' || execution.id);
 *       dbms_output.put_line('Status: ' || execution.status);
 *       dbms_output.put_line('Start Time: ' || execution.start_time);
 *       dbms_output.put_line('End Time: ' || execution.end_time);
 *     end if;
 *   end;
 *
 * Notes:
 *   - Execution ID must exist in BATCH_ACTIVITY_EXECUTIONS table
 *   - Returns complete execution record with all timing and status information
 *   - Useful for execution monitoring and troubleshooting
 *   - Includes parameter values and execution results
 *   - Can be used for performance analysis and audit purposes
 **/

function getActivityExecutionById(execution_id in number) return batch_activity_executions%rowtype ;

/**
 * Function: getSimpleMapFromTypedValList
 * Description: Converts a typed parameter list to a SimpleMap collection.
 *              Transforms the strongly-typed parameter structure into a flexible
 *              key-value map for use in batch operations and parameter passing.
 *
 * Parameters:
 *   typedList: Typed parameter list to be converted
 *
 * Returns:
 *   pck_batch_tools.simpleMap_type - SimpleMap collection with parameter values
 *
 * Example:
 *   declare
 *     typed_list pck_batch_mgr_activities.ActionParamTypedValList_type;
 *     simple_map pck_batch_tools.simpleMap_type;
 *   begin
 *     -- Add parameters to typed list
 *     pck_batch_mgr_activities.add_parameterValue(typed_list, 'batch_size', 1000);
 *     pck_batch_mgr_activities.add_parameterValue(typed_list, 'file_path', '/data/');
 *     pck_batch_mgr_activities.add_parameterValue(typed_list, 'start_date', date '2024-01-01');
 *     
 *     -- Convert to SimpleMap
 *     simple_map := pck_batch_mgr_activities.getSimpleMapFromTypedValList(typed_list);
 *     
 *     -- Use SimpleMap for further processing
 *     dbms_output.put_line('Batch size: ' || simple_map('batch_size'));
 *   end;
 *
 * Notes:
 *   - Converts typed parameters to string-based key-value pairs
 *   - Number values are converted to strings
 *   - Date values are converted to standard date format strings
 *   - Useful for parameter passing to other batch components
 *   - Maintains parameter names as keys in the SimpleMap
 **/

function getSimpleMapFromTypedValList(typedList ActionParamTypedValList_type) return pck_batch_tools.simpleMap_type ;




end PCK_BATCH_MGR_ACTIVITIES ;

/

  GRANT EXECUTE ON PCK_BATCH_MGR_ACTIVITIES TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_MGR_ACTIVITIES TO ROLE_BATCH_MAN;
