/**
 * Package: PCK_BATCH_DSI
 * Description: Oracle DBMS_SCHEDULER abstraction layer for dynamic batch chain orchestration.
 *              Provides a simplified interface to create, manage, and execute complex workflow
 *              chains using Oracle's native scheduler with enhanced error handling and
 *              automatic resource management.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 * 
 * License: See LICENSE file in the project root.
 *
 * Key features:
 *   - Dynamic chain creation with automatic cleanup and recreation
 *   - PL/SQL program generation for batch activities
 *   - Complex rule-based workflow orchestration
 *   - Scheduled job management for automated execution
 *   - Enhanced error handling for scheduler operations
 *   - Automatic resource cleanup and dependency management
 *
 * Usage patterns:
 *   1. Chain Creation: create_chain() -> define_chain_step() -> define_chain_rule() -> enable()
 *   2. Program Management: create_program() -> enable() -> define_chain_step()
 *   3. Job Scheduling: create_job() with repeat_interval for automated execution
 *
 * For detailed documentation and usage examples, refer to SYSTEM_ARCHITECTURE.md.
 */
 CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_DSI as
/**
 * Package: PCK_BATCH_DSI
 * Description: Oracle DBMS_SCHEDULER abstraction layer for dynamic batch chain orchestration.
 *              Provides a simplified interface to create, manage, and execute complex workflow
 *              chains using Oracle's native scheduler with enhanced error handling and
 *              automatic resource management.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 * 
 * Key features:
 *   - Dynamic chain creation with automatic cleanup and recreation
 *   - PL/SQL program generation for batch activities
 *   - Complex rule-based workflow orchestration
 *   - Scheduled job management for automated execution
 *   - Enhanced error handling for scheduler operations
 *   - Automatic resource cleanup and dependency management
 *
 * Usage patterns:
 *   1. Chain Creation: create_chain() -> define_chain_step() -> define_chain_rule() -> enable()
 *   2. Program Management: create_program() -> enable() -> define_chain_step()
 *   3. Job Scheduling: create_job() with repeat_interval for automated execution
 *
 * For detailed documentation and usage examples, refer to SYSTEM_ARCHITECTURE.md.
 */


/**
 * Procedure: create_chain
 * Description: Creates a new Oracle scheduler chain with automatic conflict resolution.
 *              If the chain already exists, it will be dropped and recreated automatically.
 *
 * Parameters:
 *   chain_name: Unique identifier for the chain (max 30 chars)
 *   rule_set_name: Optional rule set for complex workflow logic
 *   evaluation_interval: Optional interval for rule evaluation
 *   comments: Optional description for the chain
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.create_chain('CHAIN_NAME', 'RULE_SET_NAME', 'EVALUATION_INTERVAL', 'COMMENTS');
 *
 * Notes:
 *   - Automatically handles ORA-27477 (chain already exists) by dropping and recreating
 *   - Used by PCK_BATCH_MANAGER for dynamic chain creation from batch definitions
 *   - Chain names should be unique within the schema
 **/

procedure create_chain( chain_name            in varchar2,
                              rule_set_name         in varchar2 default null,
                              evaluation_interval   in interval day to second default null,
                              comments              in varchar2 default null ) ;


/**
 * Procedure: drop_chain
 * Description: Drops a chain and all its associated steps and rules.
 *              Provides safe cleanup with optional error suppression.
 *
 * Parameters:
 *   chain_name: Name of the chain to drop
 *   ignore_no_found: If true, suppresses ORA-23308 (chain not found) errors
 *   force: If true, forces drop even if chain is in use
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.drop_chain('CHAIN_NAME', true, false);
 *
 * Notes:
 *   - Automatically drops all chain steps and rules before dropping the chain
 *   - Use ignore_no_found=true for safe cleanup in dynamic environments
 *   - Use force=true only when chain is stuck or corrupted
 **/
procedure drop_chain( chain_name  in varchar2, ignore_no_found boolean default true, force in boolean default false ) ;


/**
 * Procedure: create_program
 * Description: Creates a new Oracle scheduler program for executing PL/SQL code or procedures.
 *              If the program already exists, it will be dropped and recreated automatically.
 *
 * Parameters:
 *   program_name: Unique identifier for the program (max 30 chars)
 *   program_type: Type of program (PLSQL_BLOCK, STORED_PROCEDURE, EXECUTABLE, CHAIN)
 *   program_action: The actual code or procedure name to execute
 *   number_of_arguments: Number of arguments the program accepts (default 0)
 *   enabled: Whether to enable the program immediately (default false)
 *   comments: Optional description for the program
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.create_program('PROGRAM_NAME', 'PLSQL_BLOCK', 'BEGIN my_procedure(); END;', 0, false, 'COMMENTS');
 *
 * Notes:
 *   - Automatically handles ORA-27477 (program already exists) by dropping and recreating
 *   - For PLSQL_BLOCK: program_action should contain the complete PL/SQL block
 *   - For STORED_PROCEDURE: program_action should be 'package.procedure_name'
 *   - Used by PCK_BATCH_MANAGER to create dynamic programs for batch activities
 **/
procedure create_program ( program_name         in varchar2,
                           program_type         in varchar2,
                           program_action       in varchar2,
                           number_of_arguments  in pls_integer default 0,
                           enabled              in boolean default false,
                           comments             in varchar2 default null ) ;


/**
 * Procedure: drop_program
 * Description: Drops a program from the Oracle scheduler.
 *              Provides safe cleanup with optional force option.
 *
 * Parameters:
 *   program_name: Name of the program to drop
 *   force: If true, forces drop even if program is in use by jobs or chains
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.drop_program('PROGRAM_NAME', true);
 *
 * Notes:
 *   - Automatically handles ORA-27476 (program not found) with force=true
 *   - Use force=true when program is referenced by active jobs or chains
 *   - Safe to call multiple times with ignore_no_found=true
 **/
procedure drop_program( program_name    in varchar2,
                        force           in boolean default false) ;


-----------------------------------------------------------------------------
/**
 * Procedure: define_chain_step
 * Description: Defines a step within a chain that references a program or subchain.
 *              Steps define the actual work to be performed in the workflow.
 *
 * Parameters:
 *   chain_name: Name of the chain to add the step to
 *   step_name: Unique identifier for the step within the chain
 *   program_name: Name of the program or subchain to execute in this step
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.define_chain_step('CHAIN_NAME', 'STEP_NAME', 'PROGRAM_NAME');
 *
 * Notes:
 *   - Step names must be unique within the chain
 *   - program_name can reference either a program or another chain (subchain)
 *   - Used by PCK_BATCH_MANAGER to build complex workflow hierarchies
 *   - Steps are executed based on chain rules and dependencies
 **/
procedure define_chain_step ( chain_name    in varchar2,
                              step_name     in varchar2,
                              program_name  in varchar2) ;

/**
 * Procedure: drop_chain_step
 * Description: Removes a step from a chain.
 *              Provides safe cleanup with optional force option.
 *
 * Parameters:
 *   chain_name: Name of the chain containing the step
 *   step_name: Name of the step to remove
 *   force: If true, forces removal even if step is in use
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.drop_chain_step('CHAIN_NAME', 'STEP_NAME', true);
 *
 * Notes:
 *   - Automatically removes any rules that reference this step
 *   - Use force=true when step is actively being executed
 *   - Safe operation that doesn't affect other steps in the chain
 **/
procedure drop_chain_step ( chain_name  in varchar2,
                            step_name   in varchar2,
                            force       in boolean default false) ;



-----------------------------------------------------------------------------
/**
 * Procedure: define_chain_rule
 * Description: Defines a rule that controls the flow and execution order of chain steps.
 *              Rules determine when steps start, stop, or transition to other steps.
 *
 * Parameters:
 *   chain_name: Name of the chain to add the rule to
 *   condition: Boolean expression that determines when the rule applies
 *   action: Action to take when condition is true (start, stop, end, etc.)
 *   rule_name: Optional unique identifier for the rule
 *   comments: Optional description for the rule
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.define_chain_rule('CHAIN_NAME', 'STEP1 SUCCEEDED', 'start STEP2', 'RULE_NAME', 'COMMENTS');
 *
 * Notes:
 *   - Common conditions: 'TRUE' (always), 'STEP_NAME SUCCEEDED', 'STEP_NAME FAILED'
 *   - Common actions: 'start STEP_NAME', 'stop', 'end'
 *   - Used by PCK_BATCH_MANAGER to create complex workflow logic
 *   - Rules are evaluated in order of definition
 **/
procedure define_chain_rule( chain_name in varchar2,
                             condition  in varchar2,
                             action     in varchar2,
                             rule_name  in varchar2 default null,
                             comments   in varchar2 default null ) ;

/**
 * Procedure: drop_chain_rule
 * Description: Removes a rule from a chain.
 *              Provides safe cleanup with optional force option.
 *
 * Parameters:
 *   chain_name: Name of the chain containing the rule
 *   rule_name: Name of the rule to remove
 *   force: If true, forces removal even if rule is in use
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.drop_chain_rule('CHAIN_NAME', 'RULE_NAME', true);
 *
 * Notes:
 *   - Safe operation that doesn't affect other rules in the chain
 *   - Use force=true when rule is actively being evaluated
 *   - Removing rules may change the chain's execution flow
 **/
procedure drop_chain_rule( chain_name   in varchar2,
                           rule_name    in varchar2,
                           force        in boolean default false ) ;

-------------------------------------------------------------------------------




/**
 * Procedure: enable
 * Description: Enables a chain for execution.
 *              Must be called after creating all steps and rules before the chain can run.
 *
 * Parameters:
 *   name: Name of the chain to enable
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.enable('CHAIN_NAME');
 *
 * Notes:
 *   - Chain must have at least one step and one rule to be enabled
 *   - Enabled chains can be executed immediately or scheduled
 *   - Used by PCK_BATCH_MANAGER after building complete chain definitions
 *   - Disabled chains cannot be executed
 **/
procedure enable( name  in varchar2 ) ;


/**
 * Procedure: create_job
 * Description: Creates a scheduled job that can execute chains, programs, or PL/SQL code.
 *              Supports one-time or recurring execution with flexible scheduling.
 *
 * Parameters:
 *   job_name: Unique identifier for the job (max 30 chars)
 *   job_type: Type of job (PLSQL_BLOCK, STORED_PROCEDURE, CHAIN, PROGRAM)
 *   job_action: The code, procedure, or chain to execute
 *   start_date: When to start the job (default: immediately)
 *   repeat_interval: Cron-like expression for recurring execution (e.g., 'FREQ=DAILY')
 *   end_date: When to stop recurring (default: never)
 *   enabled: Whether to enable the job immediately (default: true)
 *   auto_drop: Whether to drop the job after completion (default: false)
 *   comments: Optional description for the job
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.create_job('JOB_NAME', 'CHAIN', 'CHAIN_NAME', SYSTIMESTAMP, 'FREQ=DAILY', null, true, false, 'COMMENTS');
 *
 * Notes:
 *   - Used by PCK_BATCH_MGR_CHAINS for automated batch execution
 *   - repeat_interval supports Oracle calendar expressions
 *   - For chains: job_type='CHAIN', job_action=chain_name
 *   - For programs: job_type='PROGRAM', job_action=program_name
 *   - Jobs can be monitored through USER_SCHEDULER_JOBS view
 **/
procedure create_job( job_name             in varchar2,
                      job_type             in varchar2,
                      job_action           in varchar2,
                      start_date           in timestamp with time zone default null,
                      repeat_interval      in varchar2                 default null,
                      end_date             in timestamp with time zone default null,
                      enabled              in boolean                  default true,
                      auto_drop            in boolean                  default false,
                      comments             in varchar2                 default null ) ;


/**
 * Procedure: drop_job
 * Description: Drops a scheduled job from the Oracle scheduler.
 *              Provides safe cleanup with optional force and defer options.
 *
 * Parameters:
 *   job_name: Name of the job to drop
 *   force: If true, forces drop even if job is running
 *   defer: If true, defers the drop until job completes
 *
 * Returns:
 *   None
 *
 * Example:
 *   PCK_BATCH_DSI.drop_job('JOB_NAME', true, false);
 *
 * Notes:
 *   - Use force=true to stop running jobs immediately
 *   - Use defer=true to wait for job completion before dropping
 *   - Safe operation that doesn't affect other jobs
 *   - Dropped jobs cannot be recovered
 **/
procedure drop_job( job_name    in varchar2,
                    force       in boolean default false,
                    defer       in boolean default false ) ;




end pck_batch_dsi ;

/
