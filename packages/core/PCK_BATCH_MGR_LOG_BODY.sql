CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_MGR_LOG AS


auto_rise   boolean := true ;
log_level   varchar2(20) := 'log' ;

logLevels pck_batch_tools.simpleMap_type ;



  procedure log( log_text             in varchar2,
               log_data             in clob default null,
               activity_exec_id     in number default null,
               process_exec_id      in number default null,
               chain_exec_id        in number default null,
               log_type             in varchar2 default null,
               company_id           in number default null )   is

pragma autonomous_transaction ;

begin
    --
    insert into BATCH_SIMPLE_LOG(
                id,
                text,
                data,
                timestamp,
                type,
                activity_execution_id,
                process_execution_id,
                chain_execution_id,
                company_id
        )
        values( BATCH_GLOBAL_ID_SEQ.nextval,
                log_text,
                log_data,
                CURRENT_TIMESTAMP,
                log_type,
                activity_exec_id,
                process_exec_id,
                chain_exec_id,
                nvl(company_id,1) ) ;
    --
    commit ;
    --
end ;


procedure autoRaise(p_auto_rise in boolean) is
begin
    --
    auto_rise := p_auto_rise ;
    --
end ;

function autoRaise return boolean is
begin
    --
    return auto_rise ;
    --
end ;




begin
    --
    logLevels('debbug') := 1 ;
    logLevels('log') := 2 ;
    logLevels('info') := 3 ;
    logLevels('alert') := 4 ;
    logLevels('form_trigger_failure') := 5 ;
    logLevels('error') := 6 ;
    --
end pck_batch_mgr_log ;


/

  GRANT EXECUTE ON PCK_BATCH_MGR_LOG TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_MGR_LOG TO ROLE_HF_BATCH;
