/**
 * Package: PCK_BATCH_CHECK
 * Description: Testing and validation utility for batch processes and execution flows.
 *              Provides a comprehensive simulation mechanism to test batch execution
 *              without affecting real data or business logic, enabling safe debugging
 *              and validation of batch workflows.
 *
 * Author: Eduardo Gutiérrez Tapia
 * Contact: edogt@hotmail.com
 *
 * Key features:
 *   - Process simulation with configurable or random duration
 *   - Comprehensive logging of process lifecycle events
 *   - Safe testing environment for batch workflows and chains
 *   - Minimal overhead for debugging and validation purposes
 *   - Integration with batch execution monitoring system
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_CHECK AS 

/**
 * Package: PCK_BATCH_CHECK
 * Description: Testing and validation utility for batch processes and execution flows.
 *              Provides a comprehensive simulation mechanism to test batch execution
 *              without affecting real data or business logic, enabling safe debugging
 *              and validation of batch workflows.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Key features:
 *   - Process simulation with configurable or random duration
 *   - Comprehensive logging of process lifecycle events
 *   - Safe testing environment for batch workflows and chains
 *   - Minimal overhead for debugging and validation purposes
 *   - Integration with batch execution monitoring system
 *
 * For detailed documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

/**
 * Procedure: process
 * Description: Simulates a batch process execution with configurable or random duration.
 *              This procedure creates a controlled test environment for validating batch
 *              execution flows, timing, and monitoring capabilities without affecting
 *              production data or business logic.
 *
 * Parameters:
 *   p_name: Name of the process for identification and logging purposes
 *   p_duration: Duration of the process simulation in seconds (0 for random duration between 1-60 seconds)
 *
 * Returns:
 *   None
 *
 * Example:
 *   -- Simulate a process with fixed duration
 *   PCK_BATCH_CHECK.process('Data Validation Process', 30);
 *   
 *   -- Simulate a process with random duration
 *   PCK_BATCH_CHECK.process('Random Test Process', 0);
 *   
 *   -- Quick test with default random duration
 *   PCK_BATCH_CHECK.process('Quick Test');
 *
 * Notes:
 *   - Process duration is randomized between 1-60 seconds when p_duration is 0
 *   - Process name is used for logging and identification in monitoring systems
 *   - Simulation includes proper start/end logging for execution tracking
 *   - Safe for use in production environments as it doesn't modify data
 *   - Useful for testing batch chain execution flows and timing
 *   - Integration with batch monitoring and reporting systems
 *   - Can be used to validate execution timeouts and error handling
 **/

procedure process( p_name in varchar2
                  ,p_duration in int default 0) ; -- p_duration => 0 for random duration 




end pck_batch_check ;

/

GRANT EXECUTE ON PCK_BATCH_CHECK TO USR_BATCH_EXEC;
GRANT EXECUTE ON PCK_BATCH_CHECK TO ROLE_HF_BATCH;
