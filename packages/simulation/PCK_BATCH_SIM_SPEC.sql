/**
 * Package: PCK_BATCH_SIM
 * Description: Simulation procedures for batch processing.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * License: See LICENSE file in the project root.
 * For documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */


CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_SIM AS
/**
 * Package description: Simulation procedures for batch processing.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * License: See LICENSE file in the project root.
 * For documentation and usage, refer to SYSTEM_ARCHITECTURE.md.
 */

-- minimum and maximum durations in seconds
MIN_DURATION    number := 10 ;
MAX_DURATION    number := 120 ; 

/**
 * Procedure: activity
 * Description: Simulates an activity.
 *
 * Purpose: Used to simulate an activity.
 *
 * Example:
 *   PCK_BATCH_SIM.activity('ACTIVITY_NAME', 30);   
 *
 * Parameters:
 *   p_name: Name of the activity.
 *   p_duration: Duration of the activity in seconds (0 for random duration).
 *
 * Returns:
 *   None
 *
 * Notes:
 *   - The activity duration is random if p_duration is 0.
 *   - The activity name is used for logging purposes.
 **/
procedure activity( p_name in varchar2 default 'unknown'
                   ,p_duration in int default 0) ; -- p_duration => 0 for random duration 



END pck_batch_sim ;

GRANT EXECUTE ON PCK_BATCH_SIM TO USR_BATCH_EXEC;
GRANT EXECUTE ON PCK_BATCH_SIM TO ROLE_BATCH_MAN;

/
