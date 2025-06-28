/**
 * Type: BATCH_LOGGER
 * Description: Advanced logging object type for batch process execution tracking.
 *              Provides structured logging with automatic context detection and
 *              configurable error handling capabilities.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Provide centralized logging for batch processes, activities, and chains
 *   - Automatically detect execution context from execution IDs
 *   - Support multiple log levels with configurable output
 *   - Enable structured error handling and debugging
 *   - Maintain audit trail with execution references
 *
 * Log Levels (from highest to lowest priority):
 *   6: ERROR - Critical errors that may stop execution
 *   5: RAISE_FORM_TRIGGER_FAILURE - Form validation failures
 *   4: ALERT - Important warnings that require attention
 *   3: INFO - General information messages
 *   2: LOG - Standard logging messages
 *   1: DEBUG - Detailed debugging information
 *
 * Usage Examples:
 * 
 * -- Basic usage with activity execution ID
 * DECLARE
 *   v_logger BATCH_LOGGER;
 * BEGIN
 *   v_logger := BATCH_LOGGER(12345); -- activity_execution_id
 *   v_logger.info('Activity started successfully');
 *   v_logger.debug('Processing parameters', '{"param1": "value1"}');
 *   v_logger.error('Critical error occurred', '{"error_code": "E001"}');
 * END;
 *
 * -- Usage with process execution ID
 * DECLARE
 *   v_logger BATCH_LOGGER;
 * BEGIN
 *   v_logger := BATCH_LOGGER(67890); -- process_execution_id
 *   v_logger.setAutoRaise(FALSE); -- Disable automatic error raising
 *   v_logger.alert('Process performance warning');
 *   v_logger.log('Process completed', '{"duration": "120s"}');
 * END;
 *
 * -- Usage with chain execution ID
 * DECLARE
 *   v_logger BATCH_LOGGER;
 * BEGIN
 *   v_logger := BATCH_LOGGER(11111); -- chain_execution_id
 *   v_logger.info('Chain execution started');
 *   v_logger.alertStop('Chain execution failed'); -- Stops execution
 * END;
 *
 * Constructor Behavior:
 * - If exec_id is activity_execution_id: Sets activity_exec_id, process_exec_id, chain_exec_id, company_id
 * - If exec_id is process_execution_id: Sets process_exec_id, chain_exec_id, company_id
 * - If exec_id is chain_execution_id: Sets chain_exec_id, company_id
 * - If exec_id is null: Creates logger without context
 *
 * Related Objects:
 * - Uses: PCK_BATCH_MGR_ACTIVITIES, PCK_BATCH_MGR_PROCESSES, PCK_BATCH_MGR_CHAINS
 * - Writes to: BATCH_SIMPLE_LOG table
 * - Referenced by: All batch execution procedures and functions
 */


  CREATE OR REPLACE EDITIONABLE TYPE BATCH_LOGGER as object (

    --
    log_level  number,
    -- nivel de log a utilizar, se despliegan los mensajes de nivel mayor o igual a log_level, inicializado en 0
    --
    --  6 : error
    --  5 : raise_form_trigger_failure
    --  4 : alert
    --  3 : info
    --  2 : log
    --  1 : debug
    --
   -- auto_raise varchar2(5),
    -- indica si los mtodos error y raise_form_trigger_failure deben(true) o no(false) lanzar un raise_application_error,
    -- inicializado en 'true'
    --
    --  true | false
    --
    --
    activity_exec_id    number,
    process_exec_id     number,
    chain_exec_id       number,
    company_id          number,
    --

    --
    -- members
    constructor function batch_logger(exec_id in number default null) return self as result,

    --member procedure setLogLevel(logLevel in varchar2),
    --member function getLogLevel return varchar2,

    member procedure setAutoRaise(auto_rise in boolean),
    member function autoRaise return boolean,

    member procedure alertStop(text in varchar2, data in clob default null),
    member procedure debug(text in varchar2, data in clob default null),
    member procedure log(text in varchar2, data in clob default null),
    member procedure info(text in varchar2, data in clob default null),
    member procedure alert(text in varchar2, data in clob default null),
    member procedure raise_form_trigger_failure(text in varchar2, data in clob default null),
    member procedure error(text in varchar2, data in clob default null)
    --
) ;

/
CREATE OR REPLACE EDITIONABLE TYPE BODY BATCH_LOGGER as




constructor function batch_logger(exec_id in number default null) return self as result is

activity        batch_activities%rowtype ;
activExecution  batch_activity_executions%rowtype ;
--
process         batch_processes%rowtype ;
procExecution   batch_process_executions%rowtype ;
--
chain           batch_chains%rowtype ;
chainExecution  batch_chain_executions%rowtype ;


begin
    --
    if (exec_id is null) then
        --
        return ;
        --
    end if ;
    --
    activExecution := pck_batch_mgr_activities.getActivityExecutionById(exec_id) ;
    --
    if (activExecution.id is not null) then
        --
        self.activity_exec_id := activExecution.id ;
        activity := pck_batch_mgr_activities.getActivityById(activExecution.activity_id) ;
        --
        procExecution           := pck_batch_mgr_processes.getProcessExecutionById(activExecution.process_exec_id) ;
        self.process_exec_id    := activExecution.process_exec_id ;
        self.chain_exec_id      := procExecution.chain_exec_id ;
        self.company_id         := activity.company_id ;
        --
    else
        --
        procExecution := pck_batch_mgr_processes.getProcessExecutionById(exec_id) ;
        if ( procExecution.id is not null) then
            --
            process                 := pck_batch_mgr_processes.getProcessById(procExecution.process_id) ;
            self.process_exec_id    := procExecution.id ;
            self.chain_exec_id      := procExecution.chain_exec_id ;
            self.company_id         := process.company_id ;
            --
        else
            --
            chainExecution := pck_batch_mgr_chains.getChainExecutionById(exec_id) ;
            --
            if (chainExecution.id is not null) then
                --
                chain := pck_batch_mgr_chains.getChainById(chainExecution.chain_id) ;
                self.chain_exec_id      := chainExecution.id ;
                self.company_id         := chain.company_id ;
                --
            end if ;
            --
        end if ;
        --
    end if ;
    --
    --
    return ;
    --
end ;

member procedure setAutoRaise(auto_rise in boolean) is
begin
    --
    pck_batch_mgr_log.autoRaise(auto_rise) ;
    --
end ;

member function autoRaise return boolean is
begin
    --
    return pck_batch_mgr_log.autoRaise() ;
    --
end ;


member procedure log(text in varchar2, data in clob default null) is
begin
    --
    pck_batch_mgr_log.log(text, data, activity_exec_id, process_exec_id, chain_exec_id, 'log', company_id) ;
    --
end log ;

member procedure error(text in varchar2, data in clob default null) is
begin
    --
    pck_batch_mgr_log.log(text, data, activity_exec_id, process_exec_id, chain_exec_id, 'error', company_id) ;
    if (autoRaise) then
        raise_application_error(-20500, text) ;
    end if ;
    --
end error ;

member procedure raise_form_trigger_failure(text in varchar2, data in clob default null) is
begin
    --
    pck_batch_mgr_log.log(text, data, activity_exec_id, process_exec_id, chain_exec_id, 'form_trigger_failure', company_id) ;
    if (autoRaise) then
        raise_application_error(-20500, text) ;
    end if ;
    --
end raise_form_trigger_failure ;


member procedure alert(text in varchar2, data in clob default null) is
begin
    --
    pck_batch_mgr_log.log(text, data, activity_exec_id, process_exec_id, chain_exec_id, 'alert', company_id) ;
    --
end alert ;


member procedure alertStop(text in varchar2, data in clob default null) is
begin
    --
    pck_batch_mgr_log.log(text, data, activity_exec_id, process_exec_id, chain_exec_id, 'alert', company_id) ;
    raise_application_error(-20300, text) ;
    --
end alertStop ;




member procedure debug(text in varchar2, data in clob default null) is
begin
    --
    pck_batch_mgr_log.log(text, data, activity_exec_id, process_exec_id, chain_exec_id, 'debug', company_id) ;
    --
end debug ;


member procedure info(text in varchar2, data in clob default null) is
begin
    --
    pck_batch_mgr_log.log(text, data, activity_exec_id, process_exec_id, chain_exec_id, 'info', company_id) ;
    --
end info ;







end ;




/

GRANT EXECUTE ON BATCH_LOGGER TO USR_BATCH_EXEC;
GRANT EXECUTE ON BATCH_LOGGER TO ROLE_HF_BATCH;
