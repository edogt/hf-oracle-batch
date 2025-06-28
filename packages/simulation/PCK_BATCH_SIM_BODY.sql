/**
 * Package Body: PCK_BATCH_SIM
 * Description: Implementation of simulation procedures for batch processing testing.
 *
 * This package body implements the simulation functionality for testing batch
 * processes in a safe, controlled environment without affecting production
 * systems or data.
 *
 * Implementation Details:
 * - Uses BATCH_LOGGER for comprehensive logging
 * - Implements duration validation and clamping
 * - Provides random duration generation for realistic testing
 * - Uses DBMS_LOCK.SLEEP for actual time delays
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * License: See LICENSE file in the project root.
 */

CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_SIM AS

-- Initialize logger instance for simulation logging
logger  Batch_Logger := new Batch_Logger() ;

/**
 * Internal procedure: log
 * Description: Internal logging procedure that outputs to both logger and DBMS_OUTPUT
 *
 * Purpose: Provides consistent logging across the simulation package
 *
 * Parameters:
 *   text: Message to log (VARCHAR2)
 *
 * Behavior:
 * - Logs message to BATCH_LOGGER
 * - Outputs message to DBMS_OUTPUT for immediate visibility
 * - Used internally by other procedures in this package
 */
procedure log(text in varchar2) is
begin
    logger.log(text) ;
    dbms_output.put_line(text) ;
end ;

/**
 * Procedure: activity
 * Description: Simulates an activity execution with configurable duration
 *
 * Implementation Details:
 * - Validates and clamps duration to MIN_DURATION-MAX_DURATION range
 * - Generates random duration if p_duration = 0
 * - Logs activity start with duration information
 * - Uses DBMS_LOCK.SLEEP for actual time delay
 * - Logs activity completion
 *
 * Algorithm:
 * 1. Validate and process duration parameter
 * 2. Generate random duration if needed
 * 3. Clamp duration to valid range
 * 4. Log activity start
 * 5. Execute time delay
 * 6. Log activity completion
 */
procedure activity( p_name in varchar2 default 'unknown'
                  ,p_duration in int default 0)  is

duration_ number ;

begin
    -- Step 1: Process and validate duration parameter
    -- Convert to absolute value and round to nearest second
    duration_ := abs(round(p_duration)) ;
    
    -- Step 2: Handle duration logic
    if (duration_ = 0) then 
        -- Generate random duration between MIN_DURATION and MAX_DURATION
        duration_ := round( dbms_random.value(MIN_DURATION,MAX_DURATION) ) ;
    elsif (duration_ < MIN_DURATION) then   
        -- Clamp to minimum duration
        duration_ := MIN_DURATION ;
    elsif (duration_ > MAX_DURATION) then    
        -- Clamp to maximum duration
        duration_ := MAX_DURATION ;
    end if ;
    
    -- Step 3: Log activity start with duration information
    logger.log( p_name || '  started (' || duration_ || ' seconds)' ) ;
    
    -- Step 4: Execute time delay using DBMS_LOCK.SLEEP
    dbms_lock.sleep(duration_) ;
    
    -- Step 5: Log activity completion
    logger.log( p_name || '  ended' ) ;
    
end activity ;

end pck_batch_sim;

/

GRANT EXECUTE ON PCK_BATCH_SIM TO USR_BATCH_EXEC;
GRANT EXECUTE ON PCK_BATCH_SIM TO ROLE_HF_BATCH;
