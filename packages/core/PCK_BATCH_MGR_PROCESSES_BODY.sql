CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_MGR_PROCESSES as


function getProcessById(process_id in number) return batch_processes%rowtype is

process batch_processes%rowtype ;

begin
    --
    select proc.*
    into process
    from BATCH_PROCESSES proc
    where id = process_id ;
    --
    return process ;
    --
exception
    when others then
        pck_batch_mgr_log.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end ;



function getProcessExecutionById(execution_id in number) return BATCH_PROCESS_EXECUTIONS%rowtype is
processExecution BATCH_PROCESS_EXECUTIONS%rowtype ;
begin
    --
    select proc_exec.*
    into processExecution
    from BATCH_PROCESS_EXECUTIONS proc_exec
    where (1=1)
      and id = execution_id ;
    --
    return processExecution ;
    --
exception
    when no_data_found then
        --
        return null ;
        --
    when others then
        pck_batch_mgr_log.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end ;




end PCK_BATCH_MGR_PROCESSES ;




/

GRANT EXECUTE ON PCK_BATCH_MGR_PROCESSES TO ROLE_HF_BATCH;
