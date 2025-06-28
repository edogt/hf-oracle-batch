CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_MGR_CHAINS as

function getChainExecutionById(execution_id in number) return BATCH_CHAIN_EXECUTIONS%rowtype is
exec_ BATCH_CHAIN_EXECUTIONS%rowtype ;
begin
    --
    select chain_exec.*
    into exec_
    from BATCH_CHAIN_EXECUTIONS chain_exec
    where (1=1)
      and id = execution_id ;
    --
    return exec_ ;
    --
exception
    when no_data_found then
        --
        return null ;
        --
    when others then
        pck_batch_mgr_log.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end getChainExecutionById ;






function getChainById(chain_id in number) return batch_chains%rowtype is
chain_ batch_chains%rowtype ;
begin
    --
    select chain.*
        into chain_
    from BATCH_CHAINS chain
    where chain.id = chain_id ;
    --
    return chain_ ;
    --
exception
    when no_data_found then
        raise_application_error(-20010,'Chain not exists') ;
    when others then
        pck_batch_mgr_log.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end getChainById ;


function save_chain(chain in out batch_chains%rowtype) return batch_chains%rowtype is

begin
    --
    chain.id := pck_batch_tools.getNewId() ;
    --
    insert into BATCH_CHAINS (
            id,
            name,
            code,
            description,
            config,
            company_id
        )
    values (
            chain.id,
            chain.name,
            chain.code,
            chain.description,
            chain.config,
            chain.company_id
        ) ;
    --
    return chain ;
    --
end save_chain ;

function create_chain( p_name in varchar2
                      ,p_code in varchar2
                      ,p_description in varchar2 default null
                      ,p_config in varchar2 default '{}' ) return BATCH_CHAINS%rowtype  as

chain batch_chains%rowtype ;

begin
    --
    chain.name := p_name ;
    chain.description := p_description ;
    chain.config := p_config ;
    chain.code := p_code ;
    chain.company_id := 1 ;
    --
    return save_chain(chain) ;
    --
end create_chain ;

procedure add_process_to_chain( p_chain in BATCH_CHAINS%rowtype
                               ,p_process in BATCH_PROCESSES%rowtype
                               ,p_predecesors in varchar2 default'{}'
                               ,comments in varchar2 default null) is

begin
    --
    insert into BATCH_CHAIN_PROCESSES(
                id,
                chain_id,
                process_id,
                predecessors )
        values  (
            pck_batch_tools.getNewId,
            p_chain.id,
            p_process.id,
            p_predecesors
        ) ;
    --
end ;

procedure save_process( process in out batch_processes%rowtype ) is
begin
    --
    if ( process.id is null ) then
        --
        process.id := pck_batch_tools.getNewId ;
        --
        insert into BATCH_PROCESSES (
                id,
                name,
                code,
                description,
                config,
                company_id
            )
        values
            (
                process.id,
                process.name,
                process.code,
                process.description,
                process.config,
                process.company_id
            ) ;
    end if ;
    --
end ;

function create_process( p_name in varchar2
                        ,p_code in varchar2
                        ,p_description in varchar2 default null
                        ,p_config in varchar2 default '{}'
                        ,p_chain in varchar2 default null
                        ,p_order in varchar2 default null
                        ) return batch_processes%rowtype is

process batch_processes%rowtype ;

begin
    --
    process.name := p_name ;
    process.code := p_code ;
    process.description := p_description ;
    process.config := p_config ;
    process.company_id := 1 ;

    --
    save_process(process) ;
    --
    return process ;
    --
end ;

function add_activity_to_process( p_process in BATCH_PROCESSES%rowtype
                                 ,p_activity in BATCH_ACTIVITIES%rowtype
                                 ,p_name in varchar2
                                 ,p_config in varchar2 default '{}'
                                 ,p_predecessors in varchar2 default '{}' ) return batch_process_activities%rowtype is

proc_activity batch_process_activities%rowtype ;

begin
    --
    proc_activity.id := pck_batch_tools.getNewId ;
    proc_activity.name := p_name ;
    proc_activity.process_id := p_process.id ;
    proc_activity.activity_id := p_activity.id ;
    proc_activity.config := p_config ;
    proc_activity.predecessors := p_predecessors ;
    --
    insert into BATCH_PROCESS_ACTIVITIES(
                id,
                name,
                process_id,
                activity_id,
                config,
                predecessors )
        values  (
            proc_activity.id,
            proc_activity.name,
            proc_activity.process_id,
            proc_activity.activity_id,
            proc_activity.config,
            proc_activity.predecessors
        ) ;
    --
    return proc_activity ;
    --
end ;

procedure save_activity( activity in out batch_activities%rowtype ) is
begin
    --
    if ( activity.id is null ) then
        --
        activity.id := pck_batch_tools.getNewId ;
        --
        insert into BATCH_ACTIVITIES (
                id,
                name,
                action,
                code,
                description,
                company_id
            )
        values
            (
                activity.id,
                activity.name,
                activity.action,
                activity.code,
                activity.description,
                activity.company_id
            ) ;
    end if ;
    --
end ;

function create_activity( p_name in varchar2
                         ,p_action in varchar2
                         ,p_code in varchar2
                         ,p_description in varchar2 default null
                         ,p_parameters in varchar2 default '{}' ) return batch_activities%rowtype is

activity batch_activities%rowtype ;

begin
    --
    activity.name := p_name ;
    activity.action := p_action ;
    activity.code := p_code ;
    activity.description := p_description ;
    activity.company_id := 1 ;
--    activity.parameters := p_parameters ;
    --
    save_activity(activity) ;
    --
    return activity ;
    --
end ;

function create_activity_parameter( activity batch_activities%rowtype
                                   ,parameter_name in varchar2
                                   ,parameter_type in varchar2
                                   ,parameter_position in number
                                   ,parameter_description in varchar2 default null
                                   ,parameter_default_value in varchar2 default null ) return batch_activity_parameters%rowtype is

    param batch_activity_parameters%rowtype ;

begin
    --
    param.id            := pck_batch_tools.getNewId ;
    param.name          := parameter_name ;
    param.type          := parameter_type ;
    param.position      := parameter_position ;
    param.description   := parameter_description ;
    param.default_value := parameter_default_value ;
    --
    insert into BATCH_ACTIVITY_PARAMETERS(
            id,
            activity_id,
            name,
            type,
            position,
            description,
            default_value
    ) values (
            param.id,
            activity.id,
            param.name,
            param.type,
            param.position,
            param.description,
            param.default_value
    ) ;
    --
    return param ;
    --
end ;

procedure add_activ_exec_param_value( activity_exec_id in number
                                     ,activity_param_id in number
                                     ,parameter_value in varchar2 ) is

begin
    --
    insert into BATCH_ACTIV_EXEC_PARAM_VALUES (
            id,
            activity_execution_id,
            activity_parameter_id,
            value
    ) values (
            pck_batch_tools.getNewId,
            activity_exec_id,
            activity_param_id,
            parameter_value
    ) ;
    --
end ;

procedure add_proc_activ_param_value( proc_activ_id number,
                                      activ_param_id in number,
                                      parameter_value in varchar2 default null ) is
begin
    --
    insert into BATCH_PROC_ACTIV_PARAM_VALUES(
            id,
            process_activity_id,
            activity_parameter_id,
            value
    ) values (
            pck_batch_tools.getNewId,
            proc_activ_id,
            activ_param_id,
            parameter_value
    ) ;
    --
end ;


function get_chain_launcher_name( chain_id in number ) return varchar2 is
begin
    --
    return 'CHN_LAUNCHER_' || chain_id ;
    --
end get_chain_launcher_name ;

procedure set_chain_launcher( chain_id in number, new_config in varchar2 ) is

chain batch_chains%rowtype ;
repeat_interval varchar2(5000) ;    

logger Batch_Logger := new Batch_Logger() ;

begin
    --
    --chain := pck_batch_mgr_chains.getChainById( chain_id ) ;
    --
    logger.log('chain config' , new_config) ;
    --
    repeat_interval := pck_batch_tools.getValueFromSimpleJSON(new_config, 'repeat_interval') ;
    --
    -- logger.log('repeat_interval : ' || repeat_interval ) ;
    --
    if (repeat_interval is not null) then   
        --
        pck_batch_dsi.create_job( job_name => get_chain_launcher_name(chain_id) 
                                 ,job_type => 'PLSQL_BLOCK'
                                 ,job_action => 'pck_batch_manager.run_chain(' || chain_id || ') ;'
                                 ,repeat_interval => repeat_interval
                                 ,start_date => sysdate + 20/(24*60*60)) ;
        --
    end if ;
    --
end set_chain_launcher ;

procedure remove_chain_launcher( chain_id in number ) is



begin
    -- 
    pck_batch_dsi.drop_job ( get_chain_launcher_name( chain_id ) ) ;
    --
exception
    when others then
        raise ;
end remove_chain_launcher ;

end PCK_BATCH_MGR_CHAINS ;

/

GRANT EXECUTE ON PCK_BATCH_MGR_CHAINS TO ROLE_HF_BATCH;
