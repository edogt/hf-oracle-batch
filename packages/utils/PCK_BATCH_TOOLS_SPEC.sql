/**
 * Package: PCK_BATCH_TOOLS
 * Description: Comprehensive utility library for batch management operations.
 *              Provides essential tools for string manipulation, JSON processing,
 *              system context management, and procedure introspection within
 *              the batch processing environment.
 *
 * Author: Eduardo Gutiérrez Tapia
 * Contact: edogt@hotmail.com
 * License: See LICENSE file in the project root.
 *
 * Key features:
 *   - String manipulation and parsing utilities
 *   - JSON/SimpleMap conversion and processing
 *   - System context and environment management
 *   - Procedure argument introspection
 *   - Time and path manipulation functions
 *   - ID generation and management
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

  CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_TOOLS AS
/**
 * Package: PCK_BATCH_TOOLS
 * Description: Comprehensive utility library for batch management operations.
 *              Provides essential tools for string manipulation, JSON processing,
 *              system context management, and procedure introspection within
 *              the batch processing environment.
 *
 * Author: Eduardo Gutiérrez Tapia
 * Contact: edogt@hotmail.com
 * License: See LICENSE file in the project root.
 *
 * Key features:
 *   - String manipulation and parsing utilities
 *   - JSON/SimpleMap conversion and processing
 *   - System context and environment management
 *   - Procedure argument introspection
 *   - Time and path manipulation functions
 *   - ID generation and management
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

-- Type definitions for internal use
type simpleMap_type is table of varchar2(4000) index by varchar2(100) ;
type tabMaxV2_type is table of varchar2(32767) ;
type procArgumentsList_type is table of all_arguments%rowtype index by pls_integer ;

/**
 * Function: split
 * Description: Splits a string into an array of substrings based on a specified delimiter.
 *              Useful for parsing comma-separated values, parameter lists, and
 *              other delimited data within batch processing operations.
 *
 * Parameters:
 *   string: Input string to be split into substrings
 *   delimiter: Character or string used as the delimiter (default: ',')
 *   trimed: Whether to trim whitespace from resulting substrings (not implemented)
 *
 * Returns:
 *   tabMaxV2_type - Table of substrings resulting from the split operation
 *
 * Example:
 *   declare
 *     result pck_batch_tools.tabMaxV2_type;
 *     i number;
 *   begin
 *     result := pck_batch_tools.split('apple,banana,cherry', ',');
 *     for i in 1..result.count loop
 *       dbms_output.put_line('Item ' || i || ': ' || result(i));
 *     end loop;
 *   end;
 *
 * Notes:
 *   - Default delimiter is comma (',')
 *   - Returns empty table if input string is null or empty
 *   - Useful for parsing parameter lists and configuration values
 *   - Supports any delimiter string, not just single characters
 **/

function split( string in varchar2,
                delimiter in varchar2 default ',',
                trimed in boolean default false -- not implemented
                ) return tabMaxV2_type ;

/**
 * Function: surround
 * Description: Surrounds a text string with specified characters, typically quotes.
 *              Useful for generating properly quoted strings for SQL statements
 *              and dynamic code generation within batch operations.
 *
 * Parameters:
 *   text: Input text to be surrounded
 *   chars: Characters to surround the text with (default: single quote)
 *
 * Returns:
 *   varchar2 - Text surrounded by the specified characters
 *
 * Example:
 *   declare
 *     quoted_text varchar2(100);
 *   begin
 *     quoted_text := pck_batch_tools.surround('Hello World');
 *     dbms_output.put_line(quoted_text); -- Output: 'Hello World'
 *     
 *     quoted_text := pck_batch_tools.surround('Test', '"');
 *     dbms_output.put_line(quoted_text); -- Output: "Test"
 *   end;
 *
 * Notes:
 *   - Default surrounding character is single quote (')
 *   - Useful for SQL string literal generation
 *   - Supports any character or string as surrounding delimiter
 *   - Handles null input gracefully
 **/

function surround(text in varchar2, chars in varchar2 default '''') return string ;

/**
 * Function: replacePath
 * Description: Processes and normalizes file system paths for batch operations.
 *              Handles path separators, environment variables, and path formatting
 *              to ensure consistent path handling across different operating systems.
 *
 * Parameters:
 *   path_string: Input path string to be processed and normalized
 *
 * Returns:
 *   varchar2 - Normalized and processed path string
 *
 * Example:
 *   declare
 *     normalized_path varchar2(4000);
 *   begin
 *     normalized_path := pck_batch_tools.replacePath('/data/batch/output/');
 *     dbms_output.put_line('Normalized path: ' || normalized_path);
 *   end;
 *
 * Notes:
 *   - Handles different path separator conventions
 *   - Processes environment variable references
 *   - Ensures consistent path formatting
 *   - Used for file I/O operations in batch activities
 **/

function replacePath(path_string in varchar2) return varchar2 ;

/**
 * Function: enlapsedTimeString
 * Description: Calculates and formats the elapsed time between two timestamps.
 *              Returns a human-readable string representation of the time difference
 *              for logging and reporting purposes in batch operations.
 *
 * Parameters:
 *   start_time: Starting timestamp for the time calculation
 *   end_time: Ending timestamp for the time calculation
 *
 * Returns:
 *   varchar2 - Formatted string representing the elapsed time
 *
 * Example:
 *   declare
 *     elapsed_str varchar2(100);
 *     start_ts timestamp := systimestamp;
 *   begin
 *     -- Simulate some processing time
 *     dbms_lock.sleep(2);
 *     elapsed_str := pck_batch_tools.enlapsedTimeString(start_ts, systimestamp);
 *     dbms_output.put_line('Elapsed time: ' || elapsed_str);
 *   end;
 *
 * Notes:
 *   - Returns formatted time in human-readable format
 *   - Function is read-only (WNDS) for performance optimization
 *   - Used for performance monitoring and execution timing
 *   - Handles various time ranges from seconds to days
 **/

function enlapsedTimeString(start_time in timestamp, end_time in timestamp) return varchar2 ;
pragma restrict_references(enlapsedTimeString, WNDS) ;

/**
 * Function: getJSONFromSimpleMap
 * Description: Converts a SimpleMap collection to a JSON string representation.
 *              Useful for serializing parameter collections and configuration
 *              data for storage or transmission in batch operations.
 *
 * Parameters:
 *   simple_map: SimpleMap collection to be converted to JSON
 *
 * Returns:
 *   varchar2 - JSON string representation of the SimpleMap
 *
 * Example:
 *   declare
 *     my_map pck_batch_tools.simpleMap_type;
 *     json_str varchar2(4000);
 *   begin
 *     my_map('name') := 'John';
 *     my_map('age') := '30';
 *     json_str := pck_batch_tools.getJSONFromSimpleMap(my_map);
 *     dbms_output.put_line('JSON: ' || json_str);
 *   end;
 *
 * Notes:
 *   - Converts SimpleMap to standard JSON format
 *   - Used for parameter serialization and storage
 *   - Supports nested data structures
 *   - Compatible with other JSON processing functions
 **/

function getJSONFromSimpleMap(simple_map simpleMap_type) return varchar2 ;

/**
 * Function: getSimpleMapFromSimpleJSON
 * Description: Converts a SimpleJSON string to a SimpleMap collection.
 *              Parses JSON-formatted strings into a structured collection
 *              for easy access to parameter values in batch operations.
 *
 * Parameters:
 *   simpleJSON: JSON string to be parsed into SimpleMap
 *
 * Returns:
 *   simpleMap_type - SimpleMap collection containing the parsed data
 *
 * Example:
 *   declare
 *     json_str varchar2(4000) := '{"name":"John","age":"30","city":"New York"}';
 *     my_map pck_batch_tools.simpleMap_type;
 *   begin
 *     my_map := pck_batch_tools.getSimpleMapFromSimpleJSON(json_str);
 *     dbms_output.put_line('Name: ' || my_map('name'));
 *     dbms_output.put_line('Age: ' || my_map('age'));
 *   end;
 *
 * Notes:
 *   - Parses SimpleJSON format into structured collection
 *   - Used for parameter deserialization and configuration loading
 *   - Supports nested JSON structures
 *   - Handles malformed JSON gracefully
 **/

function getSimpleMapFromSimpleJSON(simpleJSON in varchar2) return simpleMap_type ;

/**
 * Function: getValueFromSimpleJSON
 * Description: Extracts a specific value from a SimpleJSON string by key name.
 *              Provides efficient access to individual parameter values without
 *              parsing the entire JSON structure.
 *
 * Parameters:
 *   simpleJSON: JSON string containing the data
 *   keyName: Name of the key whose value is to be extracted
 *
 * Returns:
 *   varchar2 - Value associated with the specified key, or null if not found
 *
 * Example:
 *   declare
 *     json_str varchar2(4000) := '{"name":"John","age":"30","city":"New York"}';
 *     name_val varchar2(100);
 *   begin
 *     name_val := pck_batch_tools.getValueFromSimpleJSON(json_str, 'name');
 *     dbms_output.put_line('Name: ' || name_val);
 *   end;
 *
 * Notes:
 *   - Efficient for accessing single values from large JSON strings
 *   - Returns null if key is not found
 *   - Used for parameter extraction in batch operations
 *   - Supports nested key access with dot notation
 **/

function getValueFromSimpleJSON(simpleJSON in varchar2, keyName in varchar2) return varchar2 ;
--pragma restrict_references(getValueFromSimpleJSON, RNDS) ;

/**
 * Function: getSysContextSimpleMap
 * Description: Retrieves system context information as a SimpleMap collection.
 *              Provides access to current session, user, and environment
 *              information for batch operations and logging.
 *
 * Returns:
 *   simpleMap_type - SimpleMap containing system context information
 *
 * Example:
 *   declare
 *     sys_context pck_batch_tools.simpleMap_type;
 *   begin
 *     sys_context := pck_batch_tools.getSysContextSimpleMap();
 *     dbms_output.put_line('User: ' || sys_context('USER'));
 *     dbms_output.put_line('Session ID: ' || sys_context('SESSION_ID'));
 *   end;
 *
 * Notes:
 *   - Returns current session and user information
 *   - Used for audit logging and context tracking
 *   - Includes database session details
 *   - Useful for debugging and troubleshooting
 **/

function getSysContextSimpleMap return simpleMap_type ;

/**
 * Function: getSysContextJSON
 * Description: Retrieves system context information as a JSON string.
 *              Provides serialized access to current session, user, and
 *              environment information for batch operations.
 *
 * Returns:
 *   varchar2 - JSON string containing system context information
 *
 * Example:
 *   declare
 *     context_json varchar2(4000);
 *   begin
 *     context_json := pck_batch_tools.getSysContextJSON();
 *     dbms_output.put_line('System Context: ' || context_json);
 *   end;
 *
 * Notes:
 *   - Returns system context as JSON string
 *   - Used for logging and audit purposes
 *   - Includes session and user information
 *   - Compatible with JSON processing functions
 **/

function getSysContextJSON return varchar2 ;

/**
 * Function: getNewId
 * Description: Generates a new unique identifier for batch operations.
 *              Uses the global sequence to ensure unique IDs across
 *              all batch processing operations.
 *
 * Returns:
 *   number - New unique identifier
 *
 * Example:
 *   declare
 *     new_id number;
 *   begin
 *     new_id := pck_batch_tools.getNewId();
 *     dbms_output.put_line('New ID: ' || new_id);
 *   end;
 *
 * Notes:
 *   - Uses global sequence for unique ID generation
 *   - Ensures uniqueness across all batch operations
 *   - Used for execution tracking and logging
 *   - Thread-safe and scalable
 **/

function getNewId return number ;

/**
 * Function: getProcedureArguments
 * Description: Retrieves argument information for a specified procedure.
 *              Provides introspection capabilities for understanding
 *              procedure signatures and parameter requirements.
 *
 * Parameters:
 *   p_package_name: Name of the package containing the procedure
 *   p_procedure_name: Name of the procedure to analyze
 *
 * Returns:
 *   procArgumentsList_type - Collection of argument information
 *
 * Example:
 *   declare
 *     args pck_batch_tools.procArgumentsList_type;
 *     i number;
 *   begin
 *     args := pck_batch_tools.getProcedureArguments('PCK_BATCH_MANAGER', 'run_chain');
 *     for i in 1..args.count loop
 *       dbms_output.put_line('Arg ' || i || ': ' || args(i).argument_name || ' - ' || args(i).data_type);
 *     end loop;
 *   end;
 *
 * Notes:
 *   - Returns detailed argument information including types and defaults
 *   - Used for dynamic procedure calling and validation
 *   - Supports procedure introspection and documentation generation
 *   - Includes argument position and data type information
 **/

function getProcedureArguments(p_package_name in varchar2, p_procedure_name in varchar2) return procArgumentsList_type ;

/**
 * Function: getSimpleMapFromV2List
 * Description: Converts a table of varchar2 values to a SimpleMap collection.
 *              Useful for transforming array-like data into key-value pairs
 *              for parameter processing in batch operations.
 *
 * Parameters:
 *   V2List: Table of varchar2 values to be converted
 *
 * Returns:
 *   simpleMap_type - SimpleMap collection with indexed key-value pairs
 *
 * Example:
 *   declare
 *     v2_list pck_batch_tools.tabMaxV2_type;
 *     simple_map pck_batch_tools.simpleMap_type;
 *   begin
 *     v2_list(1) := 'value1';
 *     v2_list(2) := 'value2';
 *     simple_map := pck_batch_tools.getSimpleMapFromV2List(v2_list);
 *     dbms_output.put_line('Key 1: ' || simple_map('1'));
 *   end;
 *
 * Notes:
 *   - Converts indexed array to key-value collection
 *   - Uses array index as key in SimpleMap
 *   - Useful for parameter transformation and processing
 *   - Supports large varchar2 values (up to 32767 characters)
 **/

function getSimpleMapFromV2List( V2List in pck_batch_tools.TabMaxV2_type ) return pck_batch_tools.SimpleMap_type ;

/**
 * Function: getProcedureFullName
 * Description: Generates the full qualified name of a procedure including owner.
 *              Useful for dynamic SQL generation and procedure identification
 *              in batch operations and error handling.
 *
 * Parameters:
 *   p_owner: Owner/schema name of the procedure
 *   p_name: Name of the procedure
 *   lineNumber: Line number for error context (optional)
 *
 * Returns:
 *   varchar2 - Fully qualified procedure name
 *
 * Example:
 *   declare
 *     full_name varchar2(200);
 *   begin
 *     full_name := pck_batch_tools.getProcedureFullName('BATCH_USER', 'MY_PROCEDURE', 123);
 *     dbms_output.put_line('Full name: ' || full_name);
 *   end;
 *
 * Notes:
 *   - Generates owner.procedure format
 *   - Used for error reporting and dynamic SQL
 *   - Includes line number for debugging context
 *   - Function is read-only (WNDS) for performance optimization
 **/

function getProcedureFullName(p_owner in varchar2, p_name in varchar2, lineNumber in number) return varchar2 ;
--pragma restrict_references(getProcedureFullName, WNDS) ;


end pck_batch_tools ;



/

  GRANT EXECUTE ON PCK_BATCH_TOOLS TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_TOOLS TO ROLE_HF_BATCH;
