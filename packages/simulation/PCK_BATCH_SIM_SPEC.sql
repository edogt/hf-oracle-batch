/**
 * Package: PCK_BATCH_SIM
 * Description: Simulation procedures for batch processing testing and validation.
 *
 * This package provides simulation capabilities for testing batch processes
 * without affecting production data or systems. It allows developers and
 * testers to validate process flows, timing, and error scenarios in a
 * controlled environment.
 *
 * Key Features:
 * - Simulate activities with configurable durations
 * - Random duration generation for realistic testing
 * - Comprehensive logging for debugging and analysis
 * - Safe testing environment without production impact
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * License: See LICENSE file in the project root.
 * For documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */


CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_SIM AS
/**
 * Package description: Simulation procedures for batch processing testing and validation.
 *
 * This package provides simulation capabilities for testing batch processes
 * without affecting production data or systems. It allows developers and
 * testers to validate process flows, timing, and error scenarios in a
 * controlled environment.
 *
 * Key Features:
 * - Simulate activities with configurable durations
 * - Random duration generation for realistic testing
 * - Comprehensive logging for debugging and analysis
 * - Safe testing environment without production impact
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * License: See LICENSE file in the project root.
 * For documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

-- Configuration constants for simulation behavior
-- minimum and maximum durations in seconds for random duration generation
MIN_DURATION    number := 10 ;  -- Minimum activity duration in seconds
MAX_DURATION    number := 120 ; -- Maximum activity duration in seconds

/**
 * Procedure: activity
 * Description: Simulates an activity execution with configurable duration.
 *
 * Purpose: 
 * This procedure simulates the execution of a batch activity for testing
 * purposes. It provides a safe way to test process flows, timing scenarios,
 * and integration points without affecting production systems or data.
 *
 * Use Cases:
 * - Testing process chain execution flows
 * - Validating timing and performance scenarios
 * - Simulating long-running activities
 * - Testing error handling and recovery mechanisms
 * - Validating monitoring and alerting systems
 * - Training and demonstration purposes
 *
 * Examples:
 * 
 * 1. Simulate activity with fixed duration:
 *    BEGIN
 *      PCK_BATCH_SIM.activity('DATA_EXTRACTION', 45);
 *    END;
 *    /
 *
 * 2. Simulate activity with random duration:
 *    BEGIN
 *      PCK_BATCH_SIM.activity('PROCESSING_STEP');
 *    END;
 *    /
 *
 * 3. Simulate multiple activities in sequence:
 *    BEGIN
 *      PCK_BATCH_SIM.activity('EXTRACT_DATA', 30);
 *      PCK_BATCH_SIM.activity('TRANSFORM_DATA', 60);
 *      PCK_BATCH_SIM.activity('LOAD_DATA', 45);
 *    END;
 *    /
 *
 * 4. Simulate activity for testing monitoring:
 *    BEGIN
 *      PCK_BATCH_SIM.activity('LONG_RUNNING_PROCESS', 90);
 *    END;
 *    /
 *
 * Parameters:
 *   p_name: Name of the activity being simulated (VARCHAR2, default: 'unknown')
 *           Used for logging and identification purposes
 *   p_duration: Duration of the activity in seconds (INT, default: 0)
 *               - 0: Random duration between MIN_DURATION and MAX_DURATION
 *               - >0: Fixed duration (clamped to MIN_DURATION-MAX_DURATION range)
 *
 * Returns:
 *   None
 *
 * Behavior:
 * - If p_duration = 0: Generates random duration between MIN_DURATION and MAX_DURATION
 * - If p_duration < MIN_DURATION: Uses MIN_DURATION
 * - If p_duration > MAX_DURATION: Uses MAX_DURATION
 * - Logs start and end messages with activity name and duration
 * - Uses DBMS_LOCK.SLEEP for actual time delay
 *
 * Logging:
 * - Logs activity start with duration information
 * - Logs activity completion
 * - Outputs to both logger and DBMS_OUTPUT for debugging
 *
 * Notes:
 * - This procedure is designed for testing and should not be used in production
 * - The actual sleep time may vary slightly due to system scheduling
 * - All durations are rounded to nearest second
 * - Activity names should be descriptive for better debugging
 * - Use in conjunction with PCK_BATCH_MANAGER for complete process simulation
 *
 * Related:
 * - PCK_BATCH_MANAGER: For managing actual batch processes
 * - PCK_BATCH_MONITOR: For monitoring simulation executions
 * - BATCH_LOGGER: For detailed logging capabilities
 *
 * Security:
 * - Requires USR_BATCH_EXEC or ROLE_HF_BATCH privileges
 * - Safe for testing environments
 * - No impact on production data or systems
 **/
procedure activity( p_name in varchar2 default 'unknown'
                   ,p_duration in int default 0) ; -- p_duration => 0 for random duration 



END pck_batch_sim ;

GRANT EXECUTE ON PCK_BATCH_SIM TO USR_BATCH_EXEC;
GRANT EXECUTE ON PCK_BATCH_SIM TO ROLE_HF_BATCH;

/
