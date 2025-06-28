CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_MANAGER AS

XSL_DIRECTORY           constant varchar2(30) := 'BATCH_XSL_DIRECTORY' ;
ENVIRONMENT_FILE_NAME   constant varchar2(30) := 'environment.json' ;
--
RUNACTIV_PB_FILE_NAME   constant varchar2(30) := 'runact_plsqlblock.sql' ;
ACTEXEC_RP_FILE_NAME   constant varchar2(30) := 'ActivityExecutionReport.html' ;


CHNEXEC_RP_FILE_NAME   constant varchar2(30) := 'ChainExecutionReport.html' ;


chain batch_chains%rowtype ;

CHAIN_NOT_EXISTS exception ;
CHAIN_WITHOUT_PROCESSES  exception ;
--
PROCESS_WITHOUT_ACTIVITIES exception ;
--
PROCESS_ACTIV_WITHOUT_PARAMS exception ;
--

HomeCompany BATCH_COMPANIES%rowtype ;

--
chainExecutionId    number ;
processExecutionId  number ;
activityExecutionId number ;
--
companyId   number := 10 ;
--

logger Batch_Logger ;


environmentJSON     clob ;
environmentMap      pck_batch_tools.simpleMap_type ;



type ActivityParametersList_type    is table of BATCH_ACTIVITY_PARAMETERS%rowtype index by pls_integer ;
type CompanyParametersList_type     is table of BATCH_COMPANY_PARAMETERS%rowtype index by pls_integer ;
type ProcActivParamValuesList_type  is table of BATCH_PROC_ACTIV_PARAM_VALUES%rowtype index by pls_integer ;





type numbers_listType is table of number index by binary_integer ;

type process_listType is table of batch_processes%rowtype index by binary_integer ;

type processActivity_record is record(

    proc_activ_id           batch_process_activities.id%type,
    proc_activ_name         batch_process_activities.name%type,
    proc_activ_code         batch_process_activities.code%type,
    activity_name           batch_activities.name%type,
    activity_code           batch_activities.code%type,
    activity_action         batch_activities.action%type,
    activity_id             batch_activities.id%type,
    propagate_failed_state  batch_activities.propagate_failed_state%type

) ;
type processAtivities_listType is table of processActivity_record index by binary_integer ;

type procActivParameter_record is record(

    proc_activ_param_id         batch_proc_activ_param_values.id%type,
    parameter_id                batch_activity_parameters.id%type,
    value                       batch_proc_activ_param_values.value%type,
    name                        batch_activity_parameters.name%type,
    type                        batch_activity_parameters.type%type,
    default_value               batch_activity_parameters.default_value%type,
    company_prmt_name           batch_company_parameters.name%type,
    company_prmt_default_value  batch_company_parameters.default_value%type
) ;
type procActivParameter_listType is table of procActivParameter_record index by binary_integer ;

--
procActivExecIdList     numbers_listType ;
processExecIdList       numbers_listType ;
--
companyParametersList   pck_batch_tools.simpleMap_type ;


directory_prefix constant varchar2(32) := 'BATCH_OUTPUT_' ;
package_prefix constant varchar2(32) := 'PCK_BATCH_' ;
--
unknow_process varchar2(30) := 'UNKNOW-PROCESS' ;
unknow_activity varchar2(30) := 'UNKNOW-ACTIVITY' ;
--
owner varchar2(32) ;
name varchar2(100) ;
lineno number ;
caller_t varchar2(4000) ;




function getProcessActivities( process batch_processes%rowtype ) return processAtivities_listType is

processActivitiesList processAtivities_listType ;

begin
    --
    select procActiv.id,
            procActiv.name,
            procActiv.code,
            activ.name,
            activ.code,
            activ.action,
            activ.id,
            activ.propagate_failed_state bulk collect into processActivitiesList
        from    batch_process_activities    procActiv,
                batch_activities            activ
        where (1 = 1)
            and activ.id = procActiv.activity_id
            and procActiv.process_id = process.id
        order by procActiv.predecessors ;
    --
    return processActivitiesList ;
    --
exception
    --
    when no_data_found then
        --
        raise PROCESS_WITHOUT_ACTIVITIES ;
        --
    when others then
        raise ;
    --
end getProcessActivities ;

function getProcActivParameters(procActiv_id in  batch_process_activities.id%type) return procActivParameter_listType is

procActivParametersList procActivParameter_listType ;

begin
    --
    select val.id
            ,param.id
            ,val.value
            ,param.name
            ,param.type
            ,param.default_value
            ,compParam.name
            ,compParam.default_value  bulk collect into procActivParametersList
    from    batch_proc_activ_param_values   val,
            batch_activity_parameters       param,
            batch_company_parameters        compParam
    where (1 = 1)
        and compParam.id (+) = param.company_parameter_id
        and param.id = val.activity_parameter_id
        and val.process_activity_id = procActiv_id ;
    --
    return procActivParametersList ;
    --
exception
    --
    when no_data_found then
        --
        raise PROCESS_ACTIV_WITHOUT_PARAMS ;
        --
    when others then
        raise ;
    --
end getProcActivParameters ;



function getLogOfLastExecutions( activity_code in varchar2, nexecs in number default 1) return batch_log_list_type is

logList batch_log_list_type := batch_log_list_type() ;

type logList_type is table of batch_simple_log%rowtype index by binary_integer ;

logListRT logList_type ;

logRow batch_simple_log%rowtype ;

curr binary_integer ;

begin
    --
    select log.* bulk collect into logListRT
    from batch_simple_log log,
         (  select exe.id
              from ( select id, activity_id
                        from batch_activity_executions
                        order by 1 desc ) exe,
                   batch_activities act
             where exe.activity_id = act.id
               and act.code = activity_code
               and rownum < nexecs + 1
            order by exe.id desc) exec
    where log.activity_execution_id = exec.id
    order by 1 ;
    --
    curr := logListRT.first() ;
    while (curr is not null) loop
        --
        logRow := logListRT(curr) ;
        --
        logList.extend;
        logList(logList.last) := batch_log_row_type(logRow.id, logRow.text, logRow.data, logRow.timestamp, logRow.type, logRow.activity_execution_id );
        --
        curr := logListRT.next(curr) ;
        --
    end loop ;
    --
    return logList ;
    --
end ;

function get_activity_exec_id(activity_name in varchar2) return number is

exec_id number ;
command varchar2(4000) ;

begin
    --
    execute immediate 'select ' || activity_name || '.get_execution_id() from dual' into exec_id ;
    --
    return exec_id ;
    --
exception
    --
    when others then
        --
        return -404 ;
        --
    --
end ;







function getActivityByCode(activity_code in varchar2) return BATCH_ACTIVITIES%rowtype is

activity batch_activities%rowtype ;

begin
    --
    select act.*
    into activity
    from BATCH_ACTIVITIES act
    where code = activity_code ;
    --
    return activity ;
    --
exception
    when others then
        logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end ;

--
-- <function_name> : <:description>
function getCompanyByFiscalID(company_fiscal_id in varchar2) return batch_companies%rowtype is

company batch_companies%rowtype ;

begin
    --
    select *
    into company
    from BATCH_COMPANIES
    where fiscal_id = company_fiscal_id ;
    --
    return company ;
    --
end getCompanyByFiscalID ;

function getCompanyByID(company_id in number) return batch_companies%rowtype is

company batch_companies%rowtype ;

begin
    --
    select *
    into company
    from BATCH_COMPANIES
    where id = company_id ;
    --
    return company ;
    --
end getCompanyByID ;


--
-- getActivityByCode : Obtiene una actividad en base a un fiscalID de compa y un cdigo de actividad
function getActivityByCode(company_fiscal_id in varchar2, activity_code in varchar2 ) return BATCH_ACTIVITIES%rowtype is

activity    batch_activities%rowtype ;
company     batch_companies%rowtype ;

begin
    --
    company := getCompanyByFiscalID(company_fiscal_id) ;
    --
    select act.*
    into activity
    from BATCH_ACTIVITIES act
    where code = activity_code
      and company_id = company.id ;
    --
    return activity ;
    --
exception
    when others then
        logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end getActivityByCode ;









function getActivityByAction(activity_action in varchar2) return BATCH_ACTIVITIES%rowtype is

activity batch_activities%rowtype ;

begin
    --
    select act.*
    into activity
    from BATCH_ACTIVITIES act
    where action = activity_action ;
    --
    return activity ;
    --
exception
    when others then
        logger.log('activity action['|| activity_action ||'] not found' ||sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end getActivityByAction ;

function getActivityById(activity_id in varchar2, raise_error in boolean default true) return BATCH_ACTIVITIES%rowtype is

activity batch_activities%rowtype ;

begin
    --
    select act.*
    into activity
    from BATCH_ACTIVITIES act
    where id = activity_id ;
    --
    return activity ;
    --
exception
    when no_data_found then
        if (raise_error) then
            logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
            raise ;
        end if ;
        return activity ;
    when others then
        logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end ;


function getProcessByCode(process_code in varchar2) return batch_processes%rowtype is

process batch_processes%rowtype ;

begin
    --
    select proc.*
    into process
    from BATCH_PROCESSES proc
    where code = process_code ;
    --
    return process ;
    --
exception
    when others then
        logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end ;





function get_batch_process_id(process_name in varchar2) return varchar2 is
begin
    --
    if (instr(process_name,package_prefix) = 1) then
        return replace(process_name, package_prefix) ;
    else
        return unknow_process ;
    end if ;
    --
end ;

function getActivityCode(activity_name in varchar2) return varchar2 is
begin
    --
    if (instr(activity_name,'PCK_BATCH_') = 1) then
        return replace(activity_name, 'PCK_BATCH_') ;
    else
        return unknow_process ;
    end if ;
    --
end ;

function getOutputDirectory return varchar2 is
action varchar2(100) ;
activity batch_activities%rowtype ;
begin
    --
    owa_util.who_called_me(owner, name, lineno, caller_t) ;
    if (caller_t = 'anonymous block') then
        return null ;
    end if ;
    --
    action      := pck_batch_tools.getProcedureFullName(owner, name, lineno) ;
    activity    := getActivityByAction(action) ;
    --
    if (activity.id is not null) then
        return pck_batch_tools.getValueFromSimpleJSON(activity.config, 'output_directory') ;
    end if ;
    --
    return null ;
    --
end ;

function getDirectoryPath(dir_name in varchar2) return varchar2 is
path_ varchar2(100) ;

begin
    --
    select dir.directory_path
    into path_
    from ALL_DIRECTORIES dir
    where dir.directory_name = dir_name ;
    --
    return path_ ;
    --
end ;



function getNewExecutionId return number is
    val number ;
begin
    --
    select BATCH_GLOBAL_ID_SEQ.nextval into val from dual ;
    --
    return val ;
    --
end ;



/*
function execution_register(execution_type in varchar2, execution_comments in varchar default null) return number as
pragma autonomous_transaction ;

    process_id varchar2(50) ;
    exec_id number ;

begin
    --
    owa_util.who_called_me(owner, name, lineno, caller_t) ;
    --
    process_id := get_batch_process_id(name) ;
    --
    exec_id := getNewExecutionId() ;
    --
    insert into BATCH_PROCESS_EXECUTIONS
        values (exec_id, process_id, execution_type, 'R',  systimestamp, null, execution_comments) ;
    --
    commit ;
    --
    return exec_id ;
    --
end execution_register ;
*/


-- chain methods
function getChainByCode(chain_code in varchar2) return batch_chains%rowtype is
chain_ batch_chains%rowtype ;
begin
    --
    select chain.*
        into chain_
    from BATCH_CHAINS chain
    where chain.code = chain_code ;
    --
    return chain_ ;
    --
exception
    when no_data_found then
        raise CHAIN_NOT_EXISTS ;
    when others then
        logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end getChainByCode ;











function chain_execution_register(  chain_code in varchar2,
                                    execution_type in varchar2,
                                    sim_mode in boolean,
                                    execution_comments in varchar default null  ) return number is
pragma autonomous_transaction ;

exec_id number ;
chain batch_chains%rowtype ;

executionComments varchar2(400) ;

begin
    --
    chain := getChainByCode(chain_code) ;
    --
    exec_id := getNewExecutionId() ;
    --
    -- simulation mode (edogt)
    if (sim_mode) then
        --
        executionComments := 'EJECUCI�N SIMULADA' ;
        --
    end if ;
    --
    insert into batch_chain_executions (id, start_time, end_time, comments, state, chain_id, execution_type)
        values (exec_id, systimestamp,  null,  execution_comments,  'running',        chain.id, execution_type    ) ;
    --
    commit ;
    --
    logger.chain_exec_id := exec_id ;
    logger.log( 'inicio cadena ' || chain.name) ;
    if ( execution_comments is not null) then
        logger.process_exec_id := exec_id ;
        logger.log(text =>  execution_comments ) ;
    end if ;
    --
    return exec_id ;
    --
end ;

procedure chain_exec_end_register( chain_exec_id in number,
                                      end_type in varchar2 default 'finished',
                                      end_comments in varchar2 default null ) is
pragma autonomous_transaction ;

chain_exec batch_chain_executions%rowtype ;

begin
    --
    chain_exec := pck_batch_mgr_chains.getChainExecutionById(chain_exec_id) ;
    --
    if ( chain_exec.id is not null
            and chain_exec.end_time is null ) then
        --
        update BATCH_CHAIN_EXECUTIONS
        set state = end_type,
            end_time = systimestamp
        where id = chain_exec.id ;
        --
        commit ;
        --


        logger.chain_exec_id := nvl(chain_exec.id,'-999') ;
        logger.log( nvl(end_comments, 'execution end')) ;
        --
    end if ;
    --
end ;

-- process methods









function process_execution_register(    process_id in number,
                                        execution_type in varchar2,
                                        execution_comments in varchar default null,
                                        chain_execution_id in number default null) return number  is
pragma autonomous_transaction ;


exec_id number ;

process_ batch_processes%rowtype ;

activities_names varchar2(400) ;

processActivitiesList processAtivities_listType ;

indx_ binary_integer ;

begin
    --
    --owa_util.who_called_me(owner, name, lineno, caller_t) ;
    --
    process_ := pck_batch_mgr_processes.getProcessById(process_id) ;
    --
    exec_id := getNewExecutionId() ;
    --
    insert into BATCH_PROCESS_EXECUTIONS ( id, process_id, execution_type, execution_state, start_time, end_time, comments, chain_exec_id )
        values (exec_id, process_.id, execution_type, 'queued', null, null, execution_comments, chain_execution_id) ;
    --
    commit ;
    --
    processActivitiesList := getProcessActivities(process_) ;
    /*
    select proact.* bulk collect
        into processActivitiesList
    from batch_process_activities proact
    where proact.process_id = process_.id ;
    */
    --
    indx_ := processActivitiesList.first() ;
    while(indx_ is not null) loop
        --
        activities_names := activities_names || processActivitiesList(indx_).proc_activ_id || ' - ' ;
        --
        indx_ := processActivitiesList.next(indx_) ;
        --
    end loop ;
    --
    activities_names := ' ( ' || trim(trailing '-' from trim(activities_names)) || ')' ;
    --
    logger.process_exec_id := exec_id ;
    logger.chain_exec_id := chain_execution_id ;

    logger.log('start of ' || process_.name || activities_names, execution_comments ) ;
    --
    return exec_id ;
    --
end process_execution_register ;

procedure process_exec_end_register( proc_exec_id in number,
                                      end_type in varchar2 default 'finished',
                                      end_comments in varchar2 default null) is
pragma autonomous_transaction ;

processExecution batch_process_executions%rowtype ;

begin
    --
    processExecution := pck_batch_mgr_processes.getProcessExecutionById(proc_exec_id) ;
    --
    if ( processExecution.id is not null
            and processExecution.end_time is null ) then
        --
        update BATCH_PROCESS_EXECUTIONS
        set execution_state = end_type,
            end_time = systimestamp
        where id = processExecution.id ;
        --
        commit ;
        --
        logger.process_exec_id := nvl(processExecution.id,'-999') ;
        logger.chain_exec_id := processExecution.chain_exec_id ;
        logger.log( 'end of process', end_comments) ;
        --
    end if ;
    --
end ;


-- activity methods



function getActivExecByProcExecId(activity_id in number, process_exec_id in number) return batch_activity_executions%rowtype is
activityExecution batch_activity_executions%rowtype ;
begin
    --
    select actExec.*
    into activityExecution
    from batch_activity_executions actExec
    where actExec.process_exec_id = process_exec_id
      and actexec.activity_id = activity_id ;
    --
    return activityExecution ;
    --
exception
    when no_data_found then
        return null ;
    when others then
        logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end ;

function getActivExecById(activity_exec_id in number) return batch_activity_executions%rowtype is
activityExecution batch_activity_executions%rowtype ;
begin
    --
    select actExec.*
    into activityExecution
    from batch_activity_executions actExec
    where actexec.id = activity_exec_id ;
    --
    return activityExecution ;
    --
exception
    when no_data_found then
        return null ;
    when others then
        logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end ;


procedure saveProcessExecution(processExecution in out BATCH_PROCESS_EXECUTIONS%rowtype) is
pragma autonomous_transaction ;
begin
    --
    if (processExecution.id is null) then
        -- is a new process execution
        processExecution.id := getNewExecutionId() ;
        --
        insert into BATCH_PROCESS_EXECUTIONS (
            id,
            process_id,
            execution_type,
            execution_state,
            start_time,
            end_time,
            comments,
            chain_exec_id
        ) values (
            processExecution.id,
            processExecution.process_id,
            processExecution.execution_type,
            processExecution.execution_state,
            processExecution.start_time,
            processExecution.end_time,
            processExecution.comments,
            processExecution.chain_exec_id
        ) ;
        --
    else
        --
        update BATCH_PROCESS_EXECUTIONS
            set execution_state = processExecution.execution_state,
                start_time      =  processExecution.start_time,
                end_time        =  processExecution.end_time,
                comments        =  processExecution.comments
            where
                id = processExecution.id ;
        --
    end if ;
    --
    commit ;
    --
end saveProcessExecution ;



procedure saveActivityExecution(activityExecution in out batch_activity_executions%rowtype) is
pragma autonomous_transaction ;
begin
    --
    if (activityExecution.id is null) then
        --
        logger.log('activityExecution.id is null') ;
        --
        activityExecution.id := getNewExecutionId() ;
        activityExecution.audit_info := pck_batch_tools.getSysContextJSON() ;
        --
        insert into BATCH_ACTIVITY_EXECUTIONS
            (   id,
                activity_id,
                execution_type,
                execution_state,
                start_time,
                end_time,
                comments,
                process_exec_id,
                audit_info,
                process_activity_id)
        values
            (   activityExecution.id,
                activityExecution.activity_id,
                activityExecution.execution_type,
                activityExecution.execution_state,
                activityExecution.start_time,
                activityExecution.end_time,
                activityExecution.comments,
                activityExecution.process_exec_id,
                activityExecution.audit_info,
                activityExecution.process_activity_id) ;
        --
    else
        --
        update BATCH_ACTIVITY_EXECUTIONS
        set execution_state = activityExecution.execution_state,
            start_time      = activityExecution.start_time,
            end_time        = activityExecution.end_time,
            comments        = activityExecution.comments
        where id = activityExecution.id ;
        --
        logger.log('activityExecution.id is not null') ;
        --
    end if ;
    --
    commit ;
    --
end ;

procedure saveChainExecution( chainExecution in out batch_chain_executions%rowtype ) is
pragma autonomous_transaction ;
begin
    --
    if ( chainExecution.id is null ) then
        --
        chainExecution.id := pck_batch_tools.getNewID() ;
        --
        insert into batch_chain_executions (
                                            id,
                                            start_time,
                                            end_time,
                                            comments,
                                            state,
                                            chain_id,
                                            execution_type )
        values (
                chainExecution.id,
                chainExecution.start_time,
                chainExecution.end_time,
                chainExecution.comments,
                chainExecution.state,
                chainExecution.chain_id,
                chainExecution.execution_type ) ;
        --

    else
        --
        update batch_chain_executions
        set
            start_time      = chainExecution.start_time,
            end_time        = chainExecution.end_time,
            comments        = chainExecution.comments,
            state           = chainExecution.state,
            chain_id        = chainExecution.chain_id,
            execution_type  = chainExecution.execution_type
        where
            id = chainExecution.id ;
        --
    end if ;
    --
    commit ;
    --
exception
    when others then
        raise ;
end ;



function activity_execution_register(execution_type in varchar2,
                                     execution_comments in varchar default null,
                                     paramsSimpleJSON in varchar2 default null ) return number   is

activity batch_activities%rowtype ;
activityExecution   batch_activity_executions%rowtype ;

execInfo varchar2(64) ; -- chainExecutionId y processExecutionId separados por comas

execInfoValues  pck_batch_tools.tabMaxV2_type ;

begin
    --
    owa_util.who_called_me(owner, name, lineno, caller_t) ;
    activity := getActivityByCode(getActivityCode(name)) ;
    --
    dbms_application_info.read_client_info(execInfo) ;
    --dbms_application_info.set_client_info
    --
    if (execInfo is not null) then
        --
        activityExecution   := getActivExecById(to_number(execInfo)) ;
        processExecutionId  := activityExecution.process_exec_id ;
        --
    end if ;
    --
    if (activityExecution.id is null) then
        --
        activityExecution.execution_type    := 'autonomus' ;
        --
    end if ;
    --
    if (SIMULATION_MODE) then
        --
        activityExecution.comments := 'EJECUCI�N SIMULADA' ;
        --
    end if ;
    --
    activityExecution.start_time        := systimestamp ;
    activityExecution.execution_state   := 'running' ;
    --
    activityExecution.activity_id       := activity.id ;
    activityExecution.process_exec_id   := processExecutionId ;
    --
    saveActivityExecution(activityExecution) ;
    --
    logger.log('activity ' || activity.name || ' is ' || activityExecution.execution_state, paramsSimpleJSON ) ;
    --
    return activityExecution.id ;
    --
end activity_execution_register ;



procedure activity_exec_end_register( act_exec_id in number,
                                      end_type in varchar2 default 'finished',
                                      end_comments in varchar2 default null ) is
pragma autonomous_transaction ;

act_exec batch_activity_executions%rowtype ;

begin
    --
    act_exec := pck_batch_mgr_activities.getActivityExecutionById(act_exec_id) ;
    --
    if ( act_exec.id is not null
            and act_exec.end_time is null ) then
        --
        update batch_activity_executions
        set execution_state = end_type,
            end_time = systimestamp
        where id = act_exec.id ;
        --
        commit ;
        --
        logger.activity_exec_id := act_exec_id ;
        logger.log( nvl(end_comments, 'execution end') ) ;
        --
    end if ;
    --
end ;






procedure execution_end_register(execution_id in number) is
pragma autonomous_transaction ;
begin
    --
    /*
    update BATCH_PROCESS_EXECUTIONS
    set exec_end_date = systimestamp,
        exec_state = 'E' ;
        */
  --  where exec_id = execution_id ;
    --
    commit ;
    --
exception
    when OTHERS then
        logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end execution_end_register ;




function getChainProcesses(chain in batch_chains%rowtype)  return process_listType is

processList process_listType ;

begin
    --
    select process.* bulk collect into processList
        from batch_chains chn,
             batch_chain_processes chnprc,
             batch_processes process
        where ( 1 = 1 )
          and process.id = chnprc.process_id
          and chnprc.chain_id = chain.id
          and chain.id = chn.id
           order by chnprc.predecessors ;


    --
    return processList ;
    --
exception
    when no_data_found then
        raise CHAIN_WITHOUT_PROCESSES ;
    when others then
        raise ;
end getChainProcesses ;

function getProcActivityCompositeName(processActivity in processActivity_record) return varchar2 is
procActivCompositeName   varchar2(400) ;
begin
    --
    procActivCompositeName := processActivity.activity_name ;
    if (processActivity.proc_activ_name is not null) then
        procActivCompositeName := procActivCompositeName || ' [' || processActivity.proc_activ_name || ']' ;
    end if ;
    return procActivCompositeName ;
    --
end ;



function putProcessToQueue(process in batch_processes%rowtype) return number is
processExecution batch_process_executions%rowtype ;
begin
    --
    processExecution.process_id         := process.id ;
    processExecution.execution_type     := 'by chain' ;
    processExecution.execution_state    := 'queued' ;
    processExecution.chain_exec_id      := chainExecutionId ;
    --
    saveProcessExecution(processExecution) ;
    --
    -- log('* process ' || process.name || ' is queued ') ;
    --
    return processExecution.id ;
    --
end ;


function createProcessExecution(process in batch_processes%rowtype) return batch_process_executions%rowtype is
processExecution batch_process_executions%rowtype ;
begin
    --
    processExecution.process_id         := process.id ;
    processExecution.execution_type     := 'by chain' ;
    processExecution.execution_state    := 'queued' ;
    processExecution.chain_exec_id      := chainExecutionId ;
    --
    saveProcessExecution(processExecution) ;
    --
    -- log('* process ' || process.name || ' is queued ') ;
    --
    return processExecution ;
    --
end ;


procedure report_chainexec_result(p_chain_exec_id in number, recipients in varchar2) is

message clob := DBMS_XslProcessor.read2clob(XSL_DIRECTORY, CHNEXEC_RP_FILE_NAME) ;

subject varchar2(200) := ':environment_name : Resultado ejecucin  ":chain_name" (fecha de ejecucion :execution_date)' ;

type ActivityExecution_info is record(
    id number,
    code varchar2(50),
    name varchar2(500),
    state varchar2(10),
    start_time_string   varchar2(30),
    end_time_string   varchar2(30),
    enlapsed_time   varchar2(30)
) ;
actExecution ActivityExecution_info ;

type ActivityExecutions_list is table of ActivityExecution_info index by binary_integer ;

activExecsList  ActivityExecutions_list ;

activity_exec_line varchar2(2000) := '
<tr>
  <td nowrap align="center" style="padding-left:5px; padding-right:5px" >:activity_exec_id</td>
  <td nowrap align="center" style="padding-left:5px; padding-right:5px"  >:activity_code</td>
  <td nowrap align="left" style="padding-left:5px; padding-right:5px"  >:activity_name</td>
  <td nowrap align="center" style="padding-left:5px; padding-right:5px"  >:activity_state</td>
  <td nowrap align="center" style="padding-left:5px; padding-right:5px"  >:activity_start_time</td>
  <td nowrap align="center" style="padding-left:5px; padding-right:5px"  >:activity_end_time</td>
  <td nowrap align="center" style="padding-left:5px; padding-right:5px"  >:activity_enlapsed_time</td>
</tr>
' ;

aux_line varchar2(32000) ;

exec_id         number ;
chain_code      varchar2(20) ;
chain_name      varchar2(200) ;
state           varchar2(10) ;
start_time      varchar2(30) ;
end_time        varchar2(30) ;
enlapsed_time   varchar2(30)  ;
execution_date  date ;

simulationText varchar2(50) := null ;


indx    binary_integer ;

begin
    --
    begin
        select chnexec.id "exec_id",
                chain.code "chain_code",
                chain.name "chain_name",
                chnexec.state "execution_state",
                to_char(chnexec.start_time,'dd/mm/yyyy hh24:mi:ss') "start_time",
                to_char(chnexec.end_time,'dd/mm/yyyy hh24:mi:ss') "end_time",
                pck_batch_tools.enlapsedTimeString(chnexec.start_time, chnexec.end_time) "enlapsed_time",
                trunc(start_time)
            into exec_id,
                chain_code,
                chain_name,
                state,
                start_time,
                end_time,
                enlapsed_time,
                execution_date
            from BATCH_CHAIN_EXECUTIONS chnexec,
                    BATCH_CHAINS chain
            where ( 1 = 1 )
                and chain.id = chnexec.chain_id
                and chnexec.id = p_chain_exec_id ;
    exception
        when no_data_found then
            null ;
    end ;
    --
    subject := replace(subject, ':chain_name', nvl(chain_name,'<chain name display text>')) ;
    subject := replace(subject, ':execution_date',to_char(execution_date, 'dd-mm-yyyy')) ;
    subject := replace(subject, ':environment_name',ENVIRONMENT_NAME) ;
    --
    if (SIMULATION_MODE) then
        --
        simulationText  := '[[ SIMULADA ]]' ;
        subject         := '[[ SIMULACION ]] ' || subject ;
        --
    end if  ;
    --
    message := replace(message, ':simulate_execution', simulationText) ;
    --
    message := replace(message, ':chain_exec_id', nvl(exec_id,-23087)) ;
 --   message := replace(message, ':chain_name', '******************************') ;
    message := replace(message, ':chain_name', nvl(chain_name,'<chain name display text>')) ;

    message := replace(message, ':chain_code', nvl(chain_code,'<chain_code>') );
    message := replace(message, ':state', nvl(state, 'void') ) ;
    message := replace(message, ':start_time', nvl(start_time,'05/11/2018 0:00:00')) ;
    message := replace(message, ':end_time', nvl(end_time,'05/11/2018 0:00:00')) ;
    message := replace(message, ':enlapsed_time', nvl(enlapsed_time,'??????')) ;
    message := replace(message, ':environment_name', ENVIRONMENT_NAME) ;
    message := replace(message, ':webapp_url', WEBAPP_URL) ;
    -- 25/10/2018 10:51:31	25/10/2018 11:14:22	0:00:22:51

    --
    begin
        --
        select  actexec.id "activ_exec_id",
                activ.code "code",
                activ.name || decode(procactiv.name, null, null, ' (' || procactiv.name || ')') "activity_name",
                actexec.execution_state "execution_state",
                to_char(actexec.start_time,'dd/mm/yyyy hh:mi:ss') "start_time",
                to_char(actexec.end_time,'dd/mm/yyyy hh:mi:ss') "end_time",
                pck_batch_tools.enlapsedTimeString(actexec.start_time, actexec.end_time) "enlapsed_time"
                --
        bulk collect into activExecsList
                --
        from BATCH_ACTIVITY_EXECUTIONS actexec,
                BATCH_ACTIVITIES activ,
                batch_chains chain,
                batch_process_executions procexec,
                batch_chain_executions chainexec,
                batch_process_activities procactiv
        where ( 1 = 1 )
            and chain.id (+) = chainexec.chain_id
            and chainexec.id (+) = procexec.chain_exec_id
            and procexec.id (+) = actexec.process_exec_id
            and activ.id = actexec.activity_id
            and procactiv.id (+) = actexec.process_activity_id
            and chainexec.id = p_chain_exec_id
        order by actexec.start_time asc ;

    end ;
    --
    indx := activExecsList.first() ;
    while (indx is not null) loop
        --
        actExecution := activExecsList(indx) ;
        --
        aux_line := aux_line ||  activity_exec_line ;
        aux_line := replace(aux_line, ':activity_exec_id', actExecution.id) ;
        aux_line := replace(aux_line, ':activity_code', actExecution.code) ;
        aux_line := replace(aux_line, ':activity_name', actExecution.name) ;
        aux_line := replace(aux_line, ':activity_state', actExecution.state) ;
        aux_line := replace(aux_line, ':activity_start_time', actExecution.start_time_string) ;
        aux_line := replace(aux_line, ':activity_end_time', actExecution.end_time_string) ;
        aux_line := replace(aux_line, ':activity_enlapsed_time', actExecution.enlapsed_time) ;
        --
        --
        indx := activExecsList.next(indx) ;
        --
    end loop ;
    --
    message := replace(message, ':activities_executios_tab', aux_line) ;
    --
    logger.log('texto correo finalizacin cadena ' || chain_name || chr(13) || MAILS_SENDER || chr(13) ||  recipients || chr(13) || subject  || chr(13)   , message ) ;
    --
    utl_mail.send(sender      => MAILS_SENDER,
                recipients  => recipients,
                cc          => null, 
                bcc         => null, 
                subject     => subject,
                message     => message,
             --   priority    => 1, -- 1-> Hight
                mime_type   => 'text/html; charset=utf-8') ;
    --            



end ;


procedure report_activity_exec_result(
                                    activity_exec_id in number,
                                    report_success_to in varchar2 default null,
                                    report_fails_to in varchar2 default null ) is


subject varchar2(200) := 'Resultado ejecucin  ":activity_name" - :execution_date ' ;
message clob :=  DBMS_XslProcessor.read2clob(XSL_DIRECTORY, ACTEXEC_RP_FILE_NAME) ;

activity            batch_activities%rowtype ;
activityExecution   batch_activity_executions%rowtype ;

begin
    -- si no existe nadie a quien enviar el reporte este se cancela (return)
    if (report_success_to||report_fails_to is null) then
        return ;
    end if ;
    --
    activityExecution   := pck_batch_mgr_activities.getActivityExecutionById(activity_exec_id) ;
    activity            := pck_batch_mgr_activities.getActivityById(activityExecution.activity_id) ;
    --
    subject := replace(subject, ':activity_name', activity.name) ;
    subject := replace(subject, ':execution_date', to_char(sysdate, 'dd/mm/yyyy [hh24:mi]')) ;
    --
    message := replace(message, ':state', activityExecution.execution_state ) ;
    message := replace(message, ':process_date', activityExecution.execution_state ) ;
    message := replace(message, ':activity_name', activity.name ) ;
    message := replace(message, ':environment_name', ENVIRONMENT_NAME ) ;

    message := replace(message, ':exec_id', activityExecution.id ) ;
    message := replace(message, ':start_time', to_char(activityExecution.start_time,'dd/mm/yyyy hh24:mi:ss') ) ;
    message := replace(message, ':end_time', to_char(activityExecution.end_time,'dd/mm/yyyy hh24:mi:ss') ) ;
    message := replace(message, ':enlapsed_time', pck_batch_tools.enlapsedTimeString(activityExecution.start_time, activityExecution.end_time) ) ;


    --
        utl_mail.send(sender      =>  MAILS_SENDER,
                recipients  => report_success_to,
                cc          => null, 
                bcc         => null, 
                subject     => subject,
                message     => message,
             --   priority    => 1, -- 1-> Hight
                mime_type   => 'text/html; charset=utf-8') ;
exception
    when others then
        if (sqlcode = -29279) then
            logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        else
            raise ;
        end if ;
end report_activity_exec_result ;

function getValueFromDefinition( value_type in varchar2, definition in varchar2 ) return varchar2 is

val varchar2(4000) ;

begin
    --
    --
    if (lower(value_type) in ('char', 'varchar2', 'varchar', 'clob')) then
        execute immediate 'select ' || definition || ' from dual' into val ;
    elsif (lower(value_type) in ('number')) then
        execute immediate 'select to_char(' || definition || ') from dual' into val ;
    elsif (lower(value_type) in ('date')) then
        execute immediate 'select to_char(' || definition || ', ''YYYYMMDD'') from dual' into val ;
    end if ;
    --
    return val ;
    --
exception
    when others then
        return null ;
end ;


function getCompanyParameterByName( companyID in number, parameter_name in varchar2 ) return batch_company_parameters%rowtype is
return_value  batch_company_parameters%rowtype ;

begin
    --
    select comprm.*
        into return_value
    from batch_company_parameters comprm
    where comprm.company_id = companyID
      and comprm.name = parameter_name ;
    --
    return return_value ;
end ;









procedure cleanExecutions(logPoint in number) is
begin
    --
    delete batch_simple_log
        where id > logPoint ;
    --
    delete batch_activity_executions
        where id > logPoint ;
    --
    delete batch_process_executions
        where id > logPoint ;
    --
    delete batch_chain_executions
        where id > logPoint ;
    --
end ;




procedure run_process(process_id in number, paramsJSON in varchar2)  is
begin
    --
    null ;
    --
end ;
procedure run_processActivity(processActivity_id in number, paramsJSON in varchar2)is
begin
    --  
    null ;
    --
end ;




function putProcActivityToQueue(processActivity in processActivity_record) return number is
activityExecution   batch_activity_executions%rowtype ;
procActivName       varchar2(400) ;
begin
    --
    activityExecution.execution_type        := 'by process' ;
    activityExecution.execution_state       := 'queued' ;
    activityExecution.process_activity_id   := processActivity.proc_activ_id ;
    activityExecution.activity_id           := processActivity.activity_id ;
    activityExecution.process_exec_id       := processExecutionId ;
    --
    saveActivityExecution(activityExecution) ;
    --
    activityExecutionId := activityExecution.id ;
    --
    logger.log('encolando "' || processActivity.activity_code || ' - ' ||getProcActivityCompositeName(processActivity) || '" (execId:' || activityExecution.id || ')') ;
    --
    return activityExecution.id ;
    --
end ;

--
procedure run_processActivity(  processActivity in processActivity_record,
                                paramsJSON in varchar2,
                                activityExecId in number)is
--
procActivParametersList     procActivParameter_listType ;
procActivParameter          procActivParameter_record ;
procActivParamsListIndex    binary_integer ;
--
baseCommandString       varchar2(4000) := 'begin <action>(<parameter_list>) ; end ;' ;
commandString           varchar2(4000) ;
parametersStatement     varchar2(4000) ;
valueText   varchar2(500) ;
--
activity            batch_activities%rowtype ;
activityExecution   batch_activity_executions%rowtype ;
chainConfigMap   pck_batch_tools.simpleMap_type ;
--
baseCommandStringPB clob := DBMS_XslProcessor.read2clob(XSL_DIRECTORY, RUNACTIV_PB_FILE_NAME) ;


begin
    --
    activityExecution := pck_batch_mgr_activities.getActivityExecutionById(activityExecId) ;
    if (activityExecution.id is null) then
        --  
        raise_application_error(-20100, 'activity execution not found' );
        --
    end if ;
    --
    activityExecutionId := activityExecution.id ;
    --
    activity := pck_batch_mgr_activities.getActivityById(activityExecution.activity_id) ;
    if (lower(activity.state) not in ('valid')) then
        --
        activityExecution.execution_state   := 'canceled' ;
        activityExecution.comments          := 'ejecucion cancelada, actividad en estado [' || activity.state || ']' ;
        saveActivityExecution(activityExecution) ;
        return ;
        --
    end if ;
    --
    commandString   := replace(baseCommandString, '<action>', processActivity.activity_action) ;
    --
    procActivParametersList := getProcActivParameters(processActivity.proc_activ_id) ;
    procActivParamsListIndex := procActivParametersList.first() ;

    while (procActivParamsListIndex is not null) loop
        --
        procActivParameter := procActivParametersList(procActivParamsListIndex) ;
        --
        if (    procActivParameter.company_prmt_name is not null
                and companyParametersList.exists(procActivParameter.company_prmt_name)  ) then
            --
            valueText := companyParametersList(procActivParameter.company_prmt_name) ;
            --
        else
            --
            valueText := procActivParameter.value ;
            --
        end if ;
        --
        valueText := trim(valueText) ;
        --
        if (valueText is null) then
            valueText := 'null' ;
        elsif (procActivParameter.type like '%CHAR%') then
            valueText := pck_batch_tools.surround( valueText ) ;
        elsif (procActivParameter.type = 'DATE') then
            --
            -- date functions support (add_months, last_day, new_time, next_day, round, sysdate, to_date, trunc) 
            --
            if not( lower(valueText) like 'add_months%' or 
                    lower(valueText) like 'last_day%' or 
                    lower(valueText) like 'new_time%' or 
                    lower(valueText) like 'next_day%' or 
                    lower(valueText) like 'round%' or 
                    lower(valueText) like 'sysdate%' or 
                    lower(valueText) like 'to_date%' or 
                    lower(valueText) like 'trunc%'          ) then
                --
                valueText := 'to_date(''' || valueText || ''', ''YYYYMMDD'')' ;
                --
            end if ;
            --
        end if ;
        --
        parametersStatement := parametersStatement || ',' ||
                                procActivParameter.name || ' => ' || valueText || ' ' ;
        --
        procActivParamsListIndex := procActivParametersList.next(procActivParamsListIndex) ;
        --
    end loop ;
    --
    parametersStatement := trim(leading ',' from parametersStatement) ;
    commandString := replace(commandString, '<parameter_list>', parametersStatement) ;
    --
    logger.log('HORROR!!', commandString) ;
    --
    commandString := getActivityExecutionString( processActivity.proc_activ_id, paramsJSON) ;
    --
    logger.log('HORROR!!', commandString) ;
    --
    activityExecution.start_time := systimestamp ;
    activityExecution.execution_state := 'running' ;
    saveActivityExecution(activityExecution) ;
    --
    logger.log(processActivity.activity_action, commandString) ;
    logger.log('* inicio actividad  "' || getProcActivityCompositeName(processActivity) || '" (execId:' || activityExecution.id || ')') ;
    dbms_application_info.set_client_info(activityExecution.id) ;

    baseCommandStringPB := replace(baseCommandStringPB, ':execute_activity', commandString ) ;
    baseCommandStringPB := replace(baseCommandStringPB, ':exec_id', activityExecutionId ) ;

    --
    chainConfigMap   := pck_batch_tools.getSimpleMapFromSimpleJSON(chain.config) ;
    
    if (chainConfigMap.exists('report_success_to')) then
        baseCommandStringPB := replace(baseCommandStringPB, ':report_success_to', chainConfigMap('report_success_to') ) ;
    else
        baseCommandStringPB := replace(baseCommandStringPB, ':report_success_to', null ) ;
    end if ;
 
    if (chainConfigMap.exists('report_fails_to')) then
        baseCommandStringPB := replace(baseCommandStringPB, ':report_fails_to', chainConfigMap('report_fails_to') ) ;
    else
        baseCommandStringPB := replace(baseCommandStringPB, ':report_fails_to', null ) ;
    end if ;   
    
    

    logger.log(processActivity.activity_action, baseCommandStringPB) ;




    execute immediate baseCommandStringPB ;

--    execute immediate commandString ;



    --
    --
    logger.log('* final actividad "' || getProcActivityCompositeName(processActivity) || '" (execId:' || activityExecution.id || ')') ;
    --
    activityExecution.end_time := systimestamp ;
    activityExecution.execution_state := 'finished' ;
    saveActivityExecution(activityExecution) ;
    --
exception
    when others then
            --
            logger.log(sqlerrm, dbms_utility.format_error_backtrace ) ;
            activityExecution.end_time := systimestamp ;
            activityExecution.execution_state := 'error' ;
            saveActivityExecution(activityExecution) ;

end ;





function getActivityParametersList(activityID in number) return ActivityParametersList_type is

paramsList      ActivityParametersList_type ;
auxParamsList   ActivityParametersList_type ;
--
param   batch_activity_parameters%rowtype ;
--
indx    pls_integer ;

begin
    --
    select param.* bulk collect into auxParamsList
    from BATCH_ACTIVITY_PARAMETERS param
    where param.activity_id = activityID ;
    --
    indx := auxParamsList.first() ;
    while (indx is not null) loop
        --
        paramsList(auxParamsList(indx).id) := auxParamsList(indx) ;
        --
        indx := auxParamsList.next(indx) ;
        --
    end loop ;
    --
    return paramsList ;
    --
exception
    when no_data_found then
        return paramsList ;
end ;

function getActivityParametersList(activity in batch_activities%rowtype) return ActivityParametersList_type is
begin
    --
    return(getActivityParametersList(activity.id)) ;
    --
end ;

function getProcActivParamValuesList(proc_activID in number) return ProcActivParamValuesList_type is

paramValuesList     ProcActivParamValuesList_type ;
aux_paramValuesList ProcActivParamValuesList_type ;

indx pls_integer ;

begin
    --
    select papv.* bulk collect into aux_paramValuesList
    from BATCH_PROC_ACTIV_PARAM_VALUES papv
    where papv.process_activity_id = proc_activID ;
    --
    indx := aux_paramValuesList.first() ;
    while (indx is not null) loop
        --
        paramValuesList(aux_paramValuesList(indx).activity_parameter_id) := aux_paramValuesList(indx) ;
        --
        indx := aux_paramValuesList.next(indx) ;
        --
    end loop ;
    --
    return paramValuesList ;
    --
exception
    when no_data_found then
        return paramValuesList ;
end ;

function getProcActivParamValuesList(proc_activ in batch_process_activities%rowtype) return ProcActivParamValuesList_type is
begin
    --
    return getProcActivParamValuesList(proc_activ.id) ;
    --
end ;

function getCompanyParametersList(companyID in number) return CompanyParametersList_type is

compParamList       CompanyParametersList_type ;
auxCompParamList    CompanyParametersList_type ;
indx                pls_integer ;

begin
    --
    select comp_prmt.* bulk collect into auxCompParamList
    from BATCH_COMPANY_PARAMETERS comp_prmt
    where comp_prmt.company_id = companyID ;
    --
    indx := auxCompParamList.first() ;
    while (indx is not null) loop
        --
        compParamList(auxCompParamList(indx).id) := auxCompParamList(indx) ;
        --
        indx := auxCompParamList.next(indx) ;
        --
    end loop ;
    --
    return compParamList ;
    --
exception
    when no_data_found then
        --
        return compParamList ;
        --
end getCompanyParametersList ;

function getCompanyParametersList(company in batch_companies%rowtype) return CompanyParametersList_type is

begin
    --
    return getCompanyParametersList(company.id) ;
    --
end getCompanyParametersList ;


function getProcessActivityByID( process_activity_id in number ) return batch_process_activities%rowtype is

processActivity batch_process_activities%rowtype ;

begin
    --
    select procActiv.*
        into processActivity
        from    batch_process_activities    procActiv
        where procActiv.id = process_activity_id ;
    --
    return processActivity ;
    --
exception
    --
    when no_data_found then
        --
        return processActivity ;
        --
    when others then
        raise ;
    --
end getProcessActivityByID ;


function isValidValueDefinition(value_type in varchar2, definition in varchar2) return boolean is

achar   varchar2(4000) ;
anumber number ;
adate   date ;

begin
    --

    --
    if (lower(value_type) in ('char', 'varchar2', 'varchar', 'clob')) then
        execute immediate 'select ' || definition || ' from dual' into achar ;
    elsif (lower(value_type) in ('number')) then
        execute immediate 'select ' || definition || ' from dual' into anumber ;
    elsif (lower(value_type) in ('date')) then
        execute immediate 'select ' || definition || ' from dual' into adate ;
    end if ;
    --
    return true ;
    --
exception
    when others then
        return false ;
end ;




function getEvaluatedCompanyParmsJSON(company_fiscalID in varchar2, indexRef in varchar2 default 'name' ) return varchar2 is
-- indexRef : (name|id)
resultJSON clob ;
resultMap pck_batch_tools.simpleMap_type ;
company batch_companies%rowtype ;

companyParamsList   CompanyParametersList_type ;

indx pls_integer ;

indxV2  varchar2(4000) ;

aux_indexRef varchar2(4000) ;

begin
    --
    aux_indexRef := lower(indexRef) ;
    --
    companyParamsList := getCompanyParametersList( getCompanyByFiscalID(company_fiscalID) ) ;
    --
    indx := companyParamsList.first() ;
    while( indx is not null) loop
        --
        if ( aux_indexRef = 'name' ) then
            indxV2 := companyParamsList(indx).name ;
        else
            indxV2 := companyParamsList(indx).id ;
        end if ;
        --
        resultMap(indxV2) := getValueFromDefinition(companyParamsList(indx).type, companyParamsList(indx).default_value) ;
        --
        --
        indx := companyParamsList.next(indx) ;
        --
    end loop ;
    --
    return pck_batch_tools.getJSONFromSimpleMap(resultMap) ;
    --
end ;

procedure saveActivityExecParameters( activityExecution in batch_activity_executions%rowtype,
                                                params  in varchar2 ) is

activityParametersList  ActivityParametersList_type ;
indx    pls_integer ;

begin
    --
    activityParametersList  := getActivityParametersList(activityExecution.activity_id) ;
    --
    indx := activityParametersList.first() ;

end ;


function getActivityExecutionString( ID in number, -- podr�a corresponder a un Activity.id o ProcessActivity.id
                                     evalueatedCompanyParams_SJSON in varchar2 default null, -- par�metros de la compa��a evaluado, en un SimpleJSON {"@ID":"value", "@ID":"value"...     }
                                     parametersValues_SJSON in varchar2 default null )
        return varchar2 is

activity        batch_activities%rowtype ;
processActivity batch_process_activities%rowtype ;

activityParametersList  ActivityParametersList_type ;
paramValuesList         ProcActivParamValuesList_type ;

companyParameters       pck_batch_tools.SimpleMap_type ;
parametersValues       pck_batch_tools.SimpleMap_type ;

indx    pls_integer ;

parameter   batch_activity_parameters%rowtype ;

valueText varchar2(4000) ;



commandString varchar2(4000) := q'[
begin
<register_parameters>
--logger.log('Activity parameters : ', pck_batch_tools.getJSONFromSimpleMap(pck_batch_mgr_activities.getSimpleMapFromTypeValList(paramValuesList)) ) ;
<action>(<parameter_list>) ;
end ;]' ;

parametersStatement varchar2(4000) ;

simulateCommandString varchar2(4000) := '
begin
    <register_parameters>
    dbms_lock.sleep(trunc(dbms_random.value(5,15))) ;
    -- <action>(<parameter_list>) ;
end ;
' ;

regPrmt_stmt varchar2(2000) := q'[   pck_batch_mgr_activities.add_parameterValue(paramValuesList, '<parameter_name>', <parameter_value>) ;]' || chr(13) ;

regParameters_stmt  varchar2(5000) ;


begin
    --

    --
    if ( parametersValues_SJSON is not null ) then
        --
        parametersValues := pck_batch_tools.getSimpleMapFromSimpleJSON(parametersValues_SJSON) ;
        --
    end if ;
    --

    --
    companyParameters := pck_batch_tools.getSimpleMapFromSimpleJSON(evalueatedCompanyParams_SJSON) ;
    --
    activity := getActivityByID(ID, false) ;
    --
    logger.log('activity.name :' || activity.name) ;
    --
    if (activity.id is null) then
        --
        processActivity := getProcessActivityByID(ID) ;
        logger.log('processActivity.id : [' || processActivity.id || ']' ) ;
        --
        if (processActivity.id is not null) then
            --
            activity := getActivityByID(processActivity.activity_id, false) ;
            --
        end if ;
        --
    end if ;
    --
    -- simulation mode
    if ( SIMULATION_MODE ) then
        --
        commandString := simulateCommandString ;
        --
    end if ;

    --
    commandString := replace(commandString, '<action>', activity.action) ;
    --
    activityParametersList  := getActivityParametersList(activity) ;
    paramValuesList         := getProcActivParamValuesList(processActivity) ;
    --
    indx := activityParametersList.first() ;
    --
    while (indx is not null) loop
        --
        parameter := activityParametersList(indx) ;
        parameter.name := upper(parameter.name) ;
        --
        if (parametersValues.exists(parameter.name)) then
            --
            valueText := parametersValues(parameter.name) ;
            --
        elsif (parameter.company_parameter_id is not null
                and companyParameters.exists(parameter.company_parameter_id) ) then
            --
            valueText := companyParameters(parameter.company_parameter_id) ;
            --
        elsif (paramValuesList.exists(parameter.id)) then
            --
            valueText := paramValuesList(parameter.id).value ;
            --
        else
            --
            valueText := parameter.default_value ;
            --
        end if ;
        --
   --     if ( valueText is not null ) then
            --
            if (parameter.type like '%CHAR%') then
                valueText := pck_batch_tools.surround( valueText ) ;
            elsif (parameter.type = 'DATE') then

                --
                -- date functions support (add_months, last_day, new_time, next_day, round, sysdate, to_date, trunc) 
                --
                if not( lower(valueText) like 'add_months%' or 
                        lower(valueText) like 'last_day%' or 
                        lower(valueText) like 'new_time%' or 
                        lower(valueText) like 'next_day%' or 
                        lower(valueText) like 'round%' or 
                        lower(valueText) like 'sysdate%' or 
                        lower(valueText) like 'to_date%' or 
                        lower(valueText) like 'trunc%'          ) then
                    --
                    valueText := 'to_date(''' || valueText || ''', ''YYYYMMDD'')' ;
                    --
                end if ;
                --
            end if ;
            --
            parametersStatement := parametersStatement || ',' ||
                                    parameter.name || ' => ' || nvl(valueText, 'null') || ' ' ;

            regParameters_stmt := regParameters_stmt || replace(
                                                                replace(regPrmt_stmt, '<parameter_name>', parameter.name ),
                                                                '<parameter_value>', nvl(valueText, 'null')) ;                        


            --
    --    end if ;
        --
        indx := activityParametersList.next(indx) ;
        --
    end loop ;
    --
    parametersStatement := trim(leading ',' from parametersStatement) ;
    commandString := replace(commandString, '<parameter_list>', parametersStatement) ;
    commandString := replace(commandString, '<register_parameters>', regParameters_stmt ) ;


    --
    if ( SIMULATION_MODE ) then
        logger.log('ACTIVIDAD SIMULADA ' || activity.action, commandString) ;
    else
        logger.log('ACTIVIDAD EJECUTADA ' || activity.action, commandString) ;
    end if ;
    --
    return commandString ;
    --
end getActivityExecutionString ;



procedure run_activity(
                        company_fiscal_id in varchar2,
                        activity_code in varchar2,
                        params in varchar2 -- SimpleJSON
                        ) is
--
company     batch_companies%rowtype ;
activity    batch_activities%rowtype ;
--
activityArguments   pck_batch_tools.procArgumentsList_type ;
argumentsIndex      binary_integer ;
--
stringsList    pck_batch_tools.tabMaxV2_type ;
--
argument all_arguments%rowtype ;
--
paramsMap pck_batch_tools.simpleMap_type ;


baseCommandString clob := DBMS_XslProcessor.read2clob(XSL_DIRECTORY, RUNACTIV_PB_FILE_NAME) ;



commandString varchar2(4000) ;

parametersStatement varchar2(4000) ;

valueText   varchar2(500) ;

activityExecution   batch_activity_executions%rowtype ;
procActivName       varchar2(400) ;


jobName varchar2(50) ;

begin
    --
    logger.log('BASE', baseCommandString) ;
    --
    paramsMap := pck_batch_tools.getSimpleMapFromSimpleJSON(params) ;
    --
    logger.log('parmetros ejecucin ' , params ) ;
    --
    begin
        --
        select act.*
        into activity
        from batch_activities act,
             batch_companies cmp
          where cmp.fiscal_id = company_fiscal_id
            and act.code = activity_code ;
        --
    exception
        when no_data_found then
            raise_application_error(-20300, 'La actividad [' || company_fiscal_id || ']-[' || activity_code ||'] no existe' ) ;
    end ;
    --
    logger.log('activity_name : ' || activity.name  ) ;
    --
 --   stringsList := pck_batch_tools.split(activity.action, '.' ) ;
   -- logger.log('stringsList.count : ' || stringsList.first) ;
    --
    --commandString   := replace(baseCommandString, '<action>', activity.action) ;
    --
    --activityArguments := pck_batch_tools.getProcedureArguments(stringsList(1), stringsList(2)) ;
    --
    activityExecution.execution_type        := 'by user' ;
    activityExecution.execution_state       := 'running' ;
    activityExecution.activity_id           := activity.id ;
    --
    saveActivityExecution(activityExecution) ;
    --
    activityExecutionId := activityExecution.id ;
    --
 /*   argumentsIndex := activityArguments.first() ;
    --
    while (argumentsIndex is not null) loop
        --
        argument := activityArguments(argumentsIndex) ;
        --
        begin
            --
            valueText := paramsMap(argument.argument_name) ;
            --
            if (valueText is null) then
                valueText := 'null' ;
            elsif (argument.data_type like '%CHAR%') then
                valueText := pck_batch_tools.surround( valueText ) ;
            elsif (argument.data_type = 'DATE') then
                valueText := 'to_date(''' || valueText || ''', ''YYYYMMDD'')' ;
            end if ;
            --
            parametersStatement := parametersStatement || ',' ||
                                    argument.argument_name || ' => ' || valueText || ' ' ;
            --
        exception
            when no_data_found then
                logger.log('not found ' || argument.argument_name) ;
        end ;
        --
        argumentsIndex := activityArguments.next(argumentsIndex) ;
        --
    end loop ;
    --
    parametersStatement := trim(leading ',' from parametersStatement) ;
    commandString := replace(commandString, '<parameter_list>', parametersStatement) ;
    --
    */
    company := getCompanyByID(activity.company_id) ;
    logger.log(params) ;
    commandString := getActivityexecutionString(activity.id, null, params) ;
    --
    baseCommandString := replace(baseCommandString, ':execute_activity', commandString) ;
    baseCommandString := replace(baseCommandString, ':exec_id', activityExecution.id ) ;
    --

    --
    if ( paramsMap.exists('REPORT_SUCCESS_TO') ) then
        --
        baseCommandString := replace(baseCommandString, ':report_success_to', paramsMap('REPORT_SUCCESS_TO') ) ;
        --
    else
        --
        baseCommandString := replace(baseCommandString, ':report_success_to', null ) ;
        --
    end if ;
    --
    --
    if ( paramsMap.exists('REPORT_FAILS_TO') ) then
        --
        baseCommandString := replace(baseCommandString, ':report_fails_to', paramsMap('REPORT_FAILS_TO') ) ;
        --
    else
        --
        baseCommandString := replace(baseCommandString, ':report_fails_to', null ) ;
        --
    end if ;
    --
    jobName := activity.code || '_' || to_char(sysdate, 'YYYYMMDDHH24MI') ;
    --
    logger.log('Job name : ' || jobName, baseCommandString) ;
    --
    dbms_scheduler.create_job(  job_name    => jobName,
                                job_type    => 'PLSQL_BLOCK',
                                job_action  => baseCommandString,
                                auto_drop   => true ) ;
    --
    dbms_scheduler.enable(jobName) ;
    --

    --
exception
    when others then
        logger.error(sqlerrm, dbms_utility.format_error_backtrace) ;

end run_activity ;

procedure run_process(process_ in BATCH_PROCESSES%rowtype, paramsJSON in varchar2, processExecId in number default null)  is
--
processActivity         processActivity_record ;
processActivitiesList   processAtivities_listType ;
procActivListIndex      binary_integer ;
processExecution        batch_process_executions%rowtype ;
--
activityExecution   batch_activity_executions%rowtype ;
--
lastFailedState     varchar2(10) ;
--
begin
    --
    if (processExecId is not null) then
        --
        processExecution                    := pck_batch_mgr_processes.getProcessExecutionById(processExecId) ;
        if (processExecution.id is null) then
            --
            raise_application_error(-20100, 'process execution not found') ;
            --
        end if ;
        --
        processExecutionId                  := processExecId ;
        processExecution.start_time         := systimestamp ;
        processExecution.execution_state    := 'running' ;
        saveProcessExecution(processExecution) ;
        --
        --log('** inicion proceso  "' || process_.name || '"') ;
        --
        processActivitiesList   := getProcessActivities(process_) ;
        procActivListIndex      := processActivitiesList.first() ;
        while (procActivListIndex is not null) loop
            --
            processActivity := processActivitiesList(procActivListIndex) ;
            run_processActivity( processActivity, paramsJSON, procActivExecIdList(processActivity.proc_activ_id) ) ;
            --
            if (processActivity.propagate_failed_state = 'yes') then
                --
                activityExecution := pck_batch_mgr_activities.getActivityExecutionById(procActivExecIdList(processActivity.proc_activ_id)) ;
                -- @todo:implementar validaci�n de activityExecution no encontrado
                if (activityExecution.execution_state != 'finished') then
                    --
                    lastFailedState := activityExecution.execution_state ;
                    --
                end if ;
                --
            end if ;
            --

            --
            procActivListIndex := processActivitiesList.next(procActivListIndex) ;
            --
        end loop ;
        --
        processExecution.end_time         := systimestamp ;
        --
        processExecution.execution_state    := nvl(lastFailedState,'finished') ;
        --
        saveProcessExecution(processExecution) ;
        --process_exec_end_register(processExecutionId, 'finished') ;
        --log('** fin proceso "' || process_.name || '" ') ;
        --
        --
    end if ;
    --
end run_process ;

procedure create_plsql_ChainStep( chain_name in varchar2, step_name in varchar2, plsql_block in varchar2 ) is

programName     varchar2(30) ;

begin
    --
    programName := chain_name || '_' || step_name ;
    pck_batch_dsi.create_program( programName, 'PLSQL_BLOCK', plsql_block ) ;
    pck_batch_dsi.enable( programName ) ;
    pck_batch_dsi.define_chain_step( chain_name, step_name, programName ) ;
    --
exception
    when others then
        raise ;
end ;

procedure createChainEnds( chain_name in varchar2, init_program_plsql_block in varchar2, finish_program_plsql_block in varchar2 ) is


begin
    --
    logger.log('creating chain ends for [' || chain_name || ']') ;
    --
    create_plsql_ChainStep( chain_name, 'INI', init_program_plsql_block ) ;
    create_plsql_ChainStep( chain_name, 'END', finish_program_plsql_block ) ;
    --
exception
    when others then
        raise ;
end ;

procedure run_chain_by_rules(chain_id in number, paramsJSON in varchar2) is

--procedure run_chain(chain_code in varchar2, company in number,  usercode in number, process_date in date) is



process_            batch_processes%rowtype ;
processList         process_listType ;
procListIndex       binary_integer ;
--
processExecution    batch_process_executions%rowtype ;
--
processActivity         processActivity_record ;
processActivitiesList   processAtivities_listType ;
procActivListIndex      binary_integer ;
--
procActivParametersList     procActivParameter_listType ;
procActivParameter          procActivParameter_record ;
procActivParamsListIndex    binary_integer ;
--


baseCommandString clob := DBMS_XslProcessor.read2clob(XSL_DIRECTORY, RUNACTIV_PB_FILE_NAME) ;

programText clob ;

commandString varchar2(4000) ;

parametersStatement varchar2(4000) ;

valueText   varchar2(500) ;


lastFailedState varchar2(10) ;

logger  Batch_Logger := new Batch_Logger() ;


recipients      varchar2(200) ;

subChainName    varchar2(30) ;


programName         varchar2(30) ;



chainName   varchar2(30) ;


rulesList pck_batch_tools.tabMaxV2_type ;

i    binary_integer ;

ruleJSON  pck_batch_tools.SimpleMap_type ;


condition   varchar2(32000) ;

--
init_chain_program_tmpl   varchar2(4000) := '
declare


begin
    --
    PCK_BATCH_MANAGER.startChainExecution( :chain_execution_id ) ;
    PCK_BATCH_MANAGER.reportStartOfChainExecution( :chain_execution_id ) ;
    --
end ;
' ;
--
end_chain_program_tmpl   varchar2(4000) := '
declare


begin
    --
    PCK_BATCH_MANAGER.finishChainExecution( :chain_execution_id ) ;
    PCK_BATCH_MANAGER.reportEndOfChainExecution( :chain_execution_id ) ;
    --
end ;
' ;

--
init_process_program_tmpl   varchar2(4000) := '
declare


begin
    --
    PCK_BATCH_MANAGER.startProcessExecution( :process_execution_id ) ;
    PCK_BATCH_MANAGER.reportStartOfProcessExecution( :process_execution_id ) ;
    --
end ;
' ;
--
end_process_program_tmpl   varchar2(4000) := '
declare


begin
    --
    PCK_BATCH_MANAGER.finishProcessExecution( :process_execution_id ) ;
    PCK_BATCH_MANAGER.reportEndOfProcessExecution( :process_execution_id ) ;
    --
end ;
' ;


--
step_finished_condition_tmpl    varchar2(4000) := '( :step_name SUCCEEDED or :step_name FAILED or :step_name COMPLETED )' ;
--


--
notLaunchedSetpsList    pck_batch_tools.tabMaxV2_type  := pck_batch_tools.tabMaxV2_type() ;
index_                  binary_integer ;
--


chainInitProgramName    varchar2(30) ;
chainInitProgramCode    varchar2(4000) ;
firstChainStepName      varchar2(30) ;
--
chainEndProgramName     varchar2(30) ;
chainEndProgramCode     varchar2(4000) ;
lastChainStepName       varchar2(30) ;



chain_allstep_finished_cond    varchar2(4000) ;
subchain_allstep_finished_cond  varchar2(4000) ;

begin
    --
    logger.log('BASE', baseCommandString) ;
    --


    --
    chain       := pck_batch_mgr_chains.getChainById(chain_id) ;
    companyId   := chain.company_id ;
    --
    chainName := 'CHN_' || chain.code ;

    pck_batch_dsi.create_chain(chainName) ;
    --




    --
    companyParametersList := pck_batch_tools.getSimpleMapFromSimpleJSON(paramsJSON) ;
    if (not companyParametersList.exists('EXECUTION_TYPE')) then
        --
        companyParametersList('EXECUTION_TYPE') := 'by user' ;
        --
    end if ;
    --
    chainExecutionId := chain_execution_register(chain.code, companyParametersList('EXECUTION_TYPE'), SIMULATION_MODE) ;
    logger := new Batch_Logger(chainExecutionId) ;

    --
    createChainEnds( chainName,
                     replace(init_chain_program_tmpl, ':chain_execution_id', chainExecutionId ),
                     replace(end_chain_program_tmpl, ':chain_execution_id', chainExecutionId ) ) ;
    --

    --
    processList := getChainProcesses(chain) ;
    --
    procListIndex   := processList.first() ;
    while (procListIndex is not null) loop
        --
        process_ := processList(procListIndex) ;
        --
        subChainName := 'SCHN_' || process_.code ;
        --

        --
        pck_batch_dsi.create_chain( subChainName ) ;
        pck_batch_dsi.define_chain_step(chainName, process_.code, subChainName ) ;
        --
        chain_allstep_finished_cond := chain_allstep_finished_cond || ' AND ' || replace(step_finished_condition_tmpl, ':step_name', process_.code) ;


        processExecution := createProcessExecution(process_) ;
        processExecutionId := processExecution.id ;
        --
        createChainEnds( subChainName,
                         replace(init_process_program_tmpl, ':process_execution_id', processExecution.id ),
                         replace(end_process_program_tmpl, ':process_execution_id', processExecution.id ) ) ;
        --
        processExecIdList(process_.id) := processExecution.id ; --<<
        --
        processActivitiesList   := getProcessActivities(process_) ; --<<
        --
        procActivListIndex      := processActivitiesList.first() ;
        --
        subchain_allstep_finished_cond := null ;
        --
        while (procActivListIndex is not null) loop
            --
            processActivity := processActivitiesList(procActivListIndex) ;
            --
            procActivExecIdList(processActivity.proc_activ_id) := putProcActivityToQueue(processActivity) ;
            --
            commandString := getActivityExecutionString( processActivity.proc_activ_id, paramsJSON ) ;

            programText := replace(baseCommandString, ':exec_id', procActivExecIdList(processActivity.proc_activ_id) ) ;
            programText := replace(programText, ':execute_activity', commandString ) ;
            --
            programName := 'PRG_' || processActivity.proc_activ_code ;
            pck_batch_dsi.create_program( programName, 'PLSQL_BLOCK', programText ) ;
            pck_batch_dsi.enable( programName ) ;
            --



            --
            --
            logger.log( to_char(programText) ) ;
            --
            pck_batch_dsi.define_chain_step( subChainName, processActivity.proc_activ_code, programName ) ;
            subchain_allstep_finished_cond := subchain_allstep_finished_cond || ' AND ' || replace(step_finished_condition_tmpl, ':step_name', processActivity.proc_activ_code) ;

            --


            --
            procActivListIndex  := processActivitiesList.next(procActivListIndex) ;
            --


            --
        end loop ;
        --
        pck_batch_dsi.enable( subChainName ) ;
        logger.log('enable ' || subChainName) ;
        --
        procListIndex := processList.next(procListIndex) ;
        --

        if ( process_.rules_set is not null ) then
            --
        logger.log('rules set ' || process_.rules_set) ;
        --
        if ( rulesList is not null) then
            rulesList.delete ;
        end if ;
        --
        rulesList := pck_batch_tools.split( process_.rules_set, ';' ) ;
            --
            i := null ;
            i := rulesList.first() ;
            while ( i is not null and rulesList(i) is not null) loop
                --
                ruleJSON := pck_batch_tools.getSimpleMapFromSimpleJSON(rulesList(i)) ;
                --
                condition := trim(upper(ruleJSON('CONDITION'))) ;
                if (condition = 'TRUE') then
                    condition := 'INI SUCCEEDED' ;
                end if ;
                --
                logger.log(rulesList(i)) ;
                --
                pck_batch_dsi.define_chain_rule(subChainName, condition, ruleJSON('ACTION') ) ;
                --
                --
                i := rulesList.next(i) ;
                --
            end loop ;

            --
        end if ;
        --
        subchain_allstep_finished_cond := substr(subchain_allstep_finished_cond, 6) ;

        pck_batch_dsi.define_chain_rule(subChainName, 'TRUE', 'start INI' ) ;
        pck_batch_dsi.define_chain_rule(subChainName, subchain_allstep_finished_cond, 'start END' ) ;
        pck_batch_dsi.define_chain_rule(subChainName, 'END SUCCEEDED', 'end' ) ;
        --
        --
        notLaunchedSetpsList.delete() ;
        --
        begin
            --
            select chnstp.step_name bulk collect into notLaunchedSetpsList
                from USER_SCHEDULER_CHAIN_STEPS chnstp
                where chnstp.chain_name = subChainName
                  and step_name not in ( 'INI', 'END' )
                  and not exists ( select 'x'
                                    from USER_SCHEDULER_CHAIN_RULES chnrls
                                    where chnrls.chain_name = chnstp.chain_name
                                      and chnrls.action like '%' || chnstp.step_name || '%' ) ;
            --
            index_ := notLaunchedSetpsList.first() ;
            --
            while (index_ is not null) loop
                --
                pck_batch_dsi.define_chain_rule(subChainName, 'INI SUCCEEDED', 'start ' || notLaunchedSetpsList(index_) ) ;
                --
                index_ := notLaunchedSetpsList.next(index_) ;
                --
            end loop ;
            --
        exception
            when others then
                raise ;
        end ;


        --
    end loop ;
    --

    --
    if ( chain.rules_set is not null ) then
        --
        rulesList := pck_batch_tools.split( chain.rules_set, ';' ) ;
        --
        i := rulesList.first() ;
        while ( i is not null and trim(rulesList(i)) is not null ) loop
            --
            ruleJSON := pck_batch_tools.getSimpleMapFromSimpleJSON(rulesList(i)) ;
            --
            logger.log('rulesList : {' || rulesList(i) || '}') ;
            --
            condition := trim(upper(ruleJSON('CONDITION'))) ;
            if (condition = 'TRUE') then
                condition := 'INI SUCCEEDED' ;
            end if ;
            --
            pck_batch_dsi.define_chain_rule(chainName, condition, ruleJSON('ACTION') ) ;
            --
            --
            i := rulesList.next(i) ;
            --
        end loop ;
         --
    end if ;

    --
    notLaunchedSetpsList.delete() ;
    --
    begin
        --
        select chnstp.step_name bulk collect into notLaunchedSetpsList
            from USER_SCHEDULER_CHAIN_STEPS chnstp
            where chnstp.chain_name = chainName
              and step_name not in ( 'INI', 'END' )
              and not exists ( select 'x'
                                from USER_SCHEDULER_CHAIN_RULES chnrls
                                where chnrls.chain_name = chnstp.chain_name
                                  and chnrls.action like '%' || chnstp.step_name || '%' ) ;
        --
        index_ := notLaunchedSetpsList.first() ;
        --
        while (index_ is not null) loop
            --
            pck_batch_dsi.define_chain_rule(chainName, 'INI SUCCEEDED', 'start ' || notLaunchedSetpsList(index_) ) ;
            --
            index_ := notLaunchedSetpsList.next(index_) ;
            --
        end loop ;
        --
    exception
        when others then
            raise ;
    end ;









    --
    chain_allstep_finished_cond := substr(chain_allstep_finished_cond, 6) ;
    --
    pck_batch_dsi.define_chain_rule(chainName, 'TRUE', 'start INI' ) ;
    pck_batch_dsi.define_chain_rule(chainName, chain_allstep_finished_cond, 'start END' ) ;
    pck_batch_dsi.define_chain_rule(chainName, 'END SUCCEEDED', 'end' ) ;

    pck_batch_dsi.enable( chainName ) ;
    logger.log('chainName : ' || chainName ) ;
    dbms_scheduler.run_chain( chainName, 'INI' ) ;
    logger.log('POS chainName : ' || chainName ) ;
    --


    --

    --
    --chain_exec_end_register(chainExecutionId,nvl(lastFailedState,'finished'),'end of "' || chain.name || ' ('|| chain.code || ')" chain' ) ;
    --
   -- recipients := pck_batch_tools.getValueFromSimpleJSON(chain.config, 'report_success_to') ;
    --
   -- if (recipients is not null) then
     --   report_chainexec_result(chainExecutionId, recipients ) ;
    --end if ;
    --
exception
    when CHAIN_NOT_EXISTS then
        --
        logger.log('la cadena ' || chain_id || ' no existe ' , sqlerrm || chr(13) || dbms_utility.format_error_backtrace) ;
        --
    when CHAIN_WITHOUT_PROCESSES then
        --
        logger.log('la cadena "' || chain.name || '" no tiene procesos para correr') ;
        --
    when PROCESS_WITHOUT_ACTIVITIES then
        --
        logger.log('el proceso "' || processList(procListIndex).name || '" no tiene actividades para ejecutar') ;

        --
    when others then
        --
        if( chainExecutionId is not null) then
            --
            logger.chain_exec_id := chainExecutionId ;
            logger.log( sqlerrm || chr(13) || dbms_utility.format_error_backtrace ) ;
            --
            chain_exec_end_register(chainExecutionId,
                                                        'error',
                                                        sqlerrm || chr(13) || dbms_utility.format_error_backtrace) ;
            --
        else
            --
            logger.log('chainExecutionId is null ') ;
            logger.log( sqlerrm , dbms_utility.format_error_backtrace) ;
            --
        end if ;
        --
        logger.log( sqlerrm , dbms_utility.format_error_backtrace) ;
        raise ;
        --
end run_chain_by_rules ;




procedure run_chain_by_rules(chain_id in number) is

chain batch_chains%rowtype ;

chainConfigMap pck_batch_tools.simpleMap_type ;

companyParams       pck_batch_tools.simpleMap_type ;
companyParamsJSON   clob ;

chain_default_process_date date ;

indx varchar2(30) ;

company batch_companies%rowtype ;

procDate_prmt batch_company_parameters%rowtype ;

begin
    --
    chain       := pck_batch_mgr_chains.getChainById(chain_id) ;
    company     := getCompanyByID(chain.company_id) ;
    companyId   := chain.company_id ;
    --
    companyParamsJSON := getEvaluatedCompanyParmsJSON(company.fiscal_id, 'id') ;
    --
    companyParams := pck_batch_tools.getSimpleMapFromSimpleJSON(companyParamsJSON) ;
    --
    chainConfigMap := pck_batch_tools.getSimpleMapFromSimpleJSON(chain.config) ;
    --
   -- execute immediate 'select ' || chainConfigMap('AUTO_PROCESS_DATE') || ' from dual' into chain_default_process_date ;
    --
   -- chainConfigMap.delete() ;
    --
   -- companyParams('PROCESS_DATE')      := to_char(chain_default_process_date, 'YYYYMMDD') ;


    procdate_prmt := getCompanyParameterByName(chain.company_id, 'PROCESS_DATE') ;
    companyParams(procDate_prmt.id)      := getValueFromDefinition('date', chainConfigMap('AUTO_PROCESS_DATE')) ;

    companyParams('EXECUTION_TYPE')    := 'by cron' ;
    --
    run_chain_by_rules(chain_id, pck_batch_tools.getJSONFromSimpleMap(companyParams)) ;
    --
    logger.log(chainConfigMap('AUTO_PROCESS_DATE')) ;
    logger.log(getValueFromDefinition('date', chainConfigMap('AUTO_PROCESS_DATE'))) ;


end ;







procedure run_chain(chain_id in number, paramsJSON in varchar2) is

--procedure run_chain(chain_code in varchar2, company in number,  usercode in number, process_date in date) is
chain batch_chains%rowtype ;


process_            batch_processes%rowtype ;
processList         process_listType ;
procListIndex       binary_integer ;
--
processExecution    batch_process_executions%rowtype ;
--
processActivity         processActivity_record ;
processActivitiesList   processAtivities_listType ;
procActivListIndex      binary_integer ;
--
procActivParametersList     procActivParameter_listType ;
procActivParameter          procActivParameter_record ;
procActivParamsListIndex    binary_integer ;
--
baseCommandString varchar2(4000) :=
'begin <action>(<parameter_list>) ; end ;' ;



commandString varchar2(4000) ;

parametersStatement varchar2(4000) ;

valueText   varchar2(500) ;


lastFailedState varchar2(10) ;

logger  Batch_Logger ;


recipients      varchar2(4000) ;


chainConfigEntries  pck_batch_tools.simpleMap_type ;

simulationMode varchar2(1000)  := 'false' ;

begin
    --
    chain       := pck_batch_mgr_chains.getChainById(chain_id) ;

    logger := new Batch_Logger() ;

    companyId   := chain.company_id ;
    --
    companyParametersList := pck_batch_tools.getSimpleMapFromSimpleJSON(paramsJSON) ;
    if (not companyParametersList.exists('EXECUTION_TYPE')) then
        --
        companyParametersList('EXECUTION_TYPE') := 'by user' ;
        --
    end if ;
    --
    chainExecutionId := chain_execution_register(chain.code, companyParametersList('EXECUTION_TYPE'), SIMULATION_MODE) ;
    --
    logger := new Batch_Logger(chainExecutionId) ;
    --

    simulationMode := pck_batch_tools.getValueFromSimpleJSON(chain.config, 'simulation_mode') ;
    if (lower(simulationMode) = 'true') then
        SIMULATION_MODE := true ;
    end if ;

    --
    logger.log('**********     inicio cadena ' || chain.name || '  (execId:' || chainExecutionId || ')     **********') ;
    logger.log('parmetros compaa', pck_batch_tools.getJSONFromSimpleMap(companyParametersList)) ;
    --
    processList := getChainProcesses(chain) ;
    --
    logger.log('procesos para encolar :  ' || processList.count()) ;
    --
    procListIndex   := processList.first() ;
    while (procListIndex is not null) loop
        --
        process_ := processList(procListIndex) ;
        processExecutionId := putProcessToQueue(process_) ;
        processExecIdList(process_.id) := processExecutionId ;
        --
        processActivitiesList   := getProcessActivities(process_) ;
        procActivListIndex      := processActivitiesList.first() ;
        --
        while (procActivListIndex is not null) loop
            --
            processActivity := processActivitiesList(procActivListIndex) ;
            procActivExecIdList(processActivity.proc_activ_id) := putProcActivityToQueue(processActivity) ;
            --
            procActivListIndex  := processActivitiesList.next(procActivListIndex) ;
            --
        end loop ;
        --
        procListIndex := processList.next(procListIndex) ;
        --
    end loop ;
    --
    logger.log('procesos encolados : ' || processList.count()) ;
    --
    procListIndex   := processList.first() ;
    while (procListIndex is not null) loop
        --
        process_ := processList(procListIndex) ;
        run_process(processList(procListIndex), paramsJSON, processExecIdList(process_.id) ) ;
        --
        if (lower(process_.propagate_failed_state) = 'yes') then
            --
            processExecution := pck_batch_mgr_processes.getProcessExecutionById(processExecIdList(process_.id)) ;
            --
            if (processExecution.execution_state not in('finished')) then
                --
                lastFailedState := processExecution.execution_state ;
                --
            end if ;
        end if ;

      --  log( 'final del proceso "' || processList(procListIndex).name || ' (execId:' || processExecutionId || ')"'  ) ;
--        process_exec_end_register(processExecutionId, 'finished') ;
        --
        procListIndex := processList.next(procListIndex) ;
        --
    end loop ;
    --
    chain_exec_end_register(chainExecutionId,nvl(lastFailedState,'finished'),'end of "' || chain.name || ' ('|| chain.code || ')" chain' ) ;
    --
    recipients := pck_batch_tools.getValueFromSimpleJSON(chain.config, 'report_success_to') ;
    --
    logger.log('recipients : ' || recipients ) ;
    --
    if (recipients is not null) then
        report_chainexec_result(chainExecutionId, recipients ) ;
    end if ;
    --
exception
    when CHAIN_NOT_EXISTS then
        --
        logger.log('la cadena ' || chain_id || ' no existe ' , sqlerrm || chr(13) || dbms_utility.format_error_backtrace) ;
        --
    when CHAIN_WITHOUT_PROCESSES then
        --
        logger.log('la cadena "' || chain.name || '" no tiene procesos para correr') ;
        --
    when PROCESS_WITHOUT_ACTIVITIES then
        --
        logger.log('el proceso "' || processList(procListIndex).name || '" no tiene actividades para ejecutar') ;

        --
    when others then
        --
        if( chainExecutionId is not null) then
            --
            logger.chain_exec_id := chainExecutionId ;
            logger.log( sqlerrm || chr(13) || dbms_utility.format_error_backtrace ) ;
            --
            chain_exec_end_register(chainExecutionId,
                                                        'error',
                                                        sqlerrm || chr(13) || dbms_utility.format_error_backtrace) ;
            --
        else
            --
            logger.log('chainExecutionId is null ') ;
            logger.log( sqlerrm , dbms_utility.format_error_backtrace) ;
            --
        end if ;
        --
end run_chain ;










procedure setChainExecutionEndState( chainExecution in out batch_chain_executions%rowtype )  is

statesList  pck_batch_tools.tabMaxV2_type ;
statesMap   pck_batch_tools.simpleMap_type ;

begin
    --
    select distinct lower(execution_state) bulk collect into statesList
        from batch_process_executions prcexec,
                batch_processes procs
        where prcexec.chain_exec_id = chainExecution.id
            and procs.propagate_failed_state = 'yes'
            and procs.id = prcexec.process_id ;
    --
    statesMap := pck_batch_tools.getSimpleMapFromV2List( statesList ) ;
    --
    if ( statesMap.exists('error') ) then
        chainExecution.state := 'error' ;
    elsif  ( statesMap.exists('die') ) then
        chainExecution.state := 'die' ;
    elsif  ( statesMap.exists('killed') ) then
        chainExecution.state := 'killed' ;
    elsif  ( statesMap.exists('canceled') ) then
        chainExecution.state := 'canceled' ;
    elsif  ( statesMap.exists('alert') ) then
        chainExecution.state := 'alert' ;
    else
        chainExecution.state := 'finished' ;
    end if ;
    --
exception
    when others then
        raise ;
end setChainExecutionEndState ;

--
procedure reportStartOfChainExecution( chainExecID in number ) is

chain           batch_chains%rowtype ;

begin
    --
    logger.log('>>> reportStartOfChainExecution not implemented <<<') ;
    --
exception
    when others then
        raise ;
end reportStartOfChainExecution ;
--
procedure reportEndOfChainExecution( chainExecID in number  ) is

chain           batch_chains%rowtype ;

begin
    --
    report_chainexec_result(chainExecID, 'edogt@hotmail.com') ;
    --
exception
    when others then
        raise ;
end reportEndOfChainExecution ;
-------------------------------






procedure startChainExecution( chain_execution_id in number ) is

chainExecution  batch_chain_executions%rowtype ;
chain           batch_chains%rowtype ;

begin
    --
    chainExecution := pck_batch_mgr_chains.getChainExecutionById( chain_execution_id ) ;
    --
    if ( chainExecution.id is null ) then
        raise_application_error(-20200, 'chain execution (' || chain_execution_id || ') not found.' ) ;
    elsif ( chainExecution.end_time is not null) then
        raise_application_error(-20210, 'chain execution (' || chain_execution_id || ') is closed in ' || chainExecution.state || ' state.' ) ;
    end if ;
    --
    chainExecution.state        := 'running' ;
    chainExecution.start_time   := systimestamp ;
    saveChainExecution( chainExecution ) ;
    --
    logger  := new Batch_Logger( chainExecution.id ) ;
    chain   := pck_batch_mgr_chains.getChainById( chainExecution.chain_id ) ;
    logger.log('Inicio ejecucin (' || chainExecution.id || ') de la cadena "' || chain.name || '"') ;
    --
exception
    when others then
        raise ;
end startChainExecution ;

procedure finishChainExecution( chainExecID in number ) is

chainExecution  batch_chain_executions%rowtype ;
chain           batch_chains%rowtype ;

begin
    --
    chainExecution := pck_batch_mgr_chains.getChainExecutionById( chainExecID ) ;
    --
    if ( chainExecution.id is null ) then
        raise_application_error(-20200, 'chain execution (' || chainExecID || ') not found.' ) ;
    elsif ( chainExecution.end_time is not null) then
        raise_application_error(-20210, 'chain execution (' || chainExecID || ') is closed in ' || chainExecution.state || ' state.' ) ;
    end if ;
    --
    setChainExecutionEndState( chainExecution ) ;
    --
    chainExecution.end_time     := systimestamp ;
    saveChainExecution( chainExecution ) ;
    --
    logger  := new Batch_Logger( chainExecution.id ) ;
    chain   := pck_batch_mgr_chains.getChainById( chainExecution.chain_id ) ;
    logger.log('Fin ejecucin (' || chainExecution.id || ') de la cadena "' || chain.name || '"') ;
    --
exception
    when others then
        raise ;
end finishChainExecution ;



procedure startProcessExecution( process_execution_id in number ) is

processExecution    batch_process_executions%rowtype ;
process             batch_processes%rowtype ;

begin
    --
    processExecution := pck_batch_mgr_processes.getProcessExecutionById( process_execution_id ) ;
    --
    if ( processExecution.id is null ) then
        raise_application_error(-20300, 'process execution (' || process_execution_id || ') not found.' ) ;
    elsif ( processExecution.end_time is not null) then
        raise_application_error(-20310, 'process execution (' || process_execution_id || ') is closed in ' || processExecution.execution_state || ' state.' ) ;
    end if ;
    --
    processExecution.execution_state        := 'running' ;
    processExecution.start_time   := systimestamp ;
    saveProcessExecution( processExecution ) ;
    --
    logger  := new Batch_Logger( processExecution.id ) ;
    process   := pck_batch_mgr_processes.getProcessById( processExecution.process_id ) ;
    logger.log('Inicio ejecucin (' || processExecution.id || ') del proceso "' || process.name || '"') ;
    --
exception
    when others then
        raise ;
end startProcessExecution ;



procedure setProcessExecutionEndState( processExecution in out batch_process_executions%rowtype )  is

statesList  pck_batch_tools.tabMaxV2_type ;
statesMap   pck_batch_tools.simpleMap_type ;

begin
    --
    select distinct lower(execution_state) bulk collect into statesList
        from batch_activity_executions actexec,
                batch_activities act
        where actexec.process_exec_id = processExecution.id
            and act.propagate_failed_state = 'yes'
            and act.id = actexec.activity_id ;
    --
    statesMap := pck_batch_tools.getSimpleMapFromV2List( statesList ) ;
    --
    if ( statesMap.exists('error') ) then
        processExecution.execution_state := 'error' ;
    elsif  ( statesMap.exists('die') ) then
        processExecution.execution_state := 'die' ;
    elsif  ( statesMap.exists('killed') ) then
        processExecution.execution_state := 'killed' ;
    elsif  ( statesMap.exists('canceled') ) then
        processExecution.execution_state := 'canceled' ;
    elsif  ( statesMap.exists('alert') ) then
        processExecution.execution_state := 'alert' ;
    else
        processExecution.execution_state := 'finished' ;
    end if ;
    --
exception
    when others then
        raise ;
end setProcessExecutionEndState ;



procedure finishProcessExecution( process_execution_id in number ) is

processExecution    batch_process_executions%rowtype ;
process             batch_processes%rowtype ;

begin
    --
    processExecution := pck_batch_mgr_processes.getProcessExecutionById( process_execution_id ) ;
    --
    if ( processExecution.id is null ) then
        raise_application_error(-20200, 'chain execution (' || process_execution_id || ') not found.' ) ;
    elsif ( processExecution.end_time is not null) then
        raise_application_error(-20210, 'chain execution (' || process_execution_id || ') is closed in ' || processExecution.execution_state || ' state.' ) ;
    end if ;
    --
    setProcessExecutionEndState( processExecution ) ;
    --
    processExecution.end_time     := systimestamp ;
    saveProcessExecution( processExecution ) ;
    --
    logger  := new Batch_Logger( processExecution.id ) ;
    process   := pck_batch_mgr_processes.getProcessById( processExecution.process_id ) ;
    logger.log('Fin ejecucin (' || processExecution.id || ') del proceso "' || process.name || '"') ;
    --
exception
    when others then
        raise ;
end finishProcessExecution ;




procedure reportStartOfProcessExecution( process_execution_id in number ) is

process           batch_processes%rowtype ;

begin
    --
    logger.log('>>> reportStartOfProcessExecution not implemented <<<') ;
    --
exception
    when others then
        raise ;
end reportStartOfProcessExecution ;



procedure reportEndOfProcessExecution( process_execution_id in number ) is

process           batch_processes%rowtype ;

begin
    --
    logger.log('>>> reportEndOfProcessExecution not implemented <<<') ;
    --
exception
    when others then
        raise ;
end reportEndOfProcessExecution ;












procedure run_chain(chain_id in number) is

chain batch_chains%rowtype ;

chainConfigMap pck_batch_tools.simpleMap_type ;

companyParams       pck_batch_tools.simpleMap_type ;
companyParamsJSON   clob ;

chain_default_process_date date ;

indx varchar2(30) ;

company batch_companies%rowtype ;

procDate_prmt batch_company_parameters%rowtype ;

begin
    --
    chain       := pck_batch_mgr_chains.getChainById(chain_id) ;
    --
    if (pck_batch_tools.getValueFromSimpleJSON(chain.config, 'execution_logic') = 'by rules') then
        --
        logger.log('chain executed by rules') ;
        run_chain_by_rules(chain.id) ;
        return ;
        --
    end if ;
    --
    company     := getCompanyByID(chain.company_id) ;
    companyId   := chain.company_id ;
    --
    companyParamsJSON := getEvaluatedCompanyParmsJSON(company.fiscal_id, 'id') ;
    --
    companyParams := pck_batch_tools.getSimpleMapFromSimpleJSON(companyParamsJSON) ;
    --
    chainConfigMap := pck_batch_tools.getSimpleMapFromSimpleJSON(chain.config) ;
    --
   -- execute immediate 'select ' || chainConfigMap('AUTO_PROCESS_DATE') || ' from dual' into chain_default_process_date ;
    --
   -- chainConfigMap.delete() ;
    --
   -- companyParams('PROCESS_DATE')      := to_char(chain_default_process_date, 'YYYYMMDD') ;


    procdate_prmt := getCompanyParameterByName(chain.company_id, 'PROCESS_DATE') ;
    companyParams(procDate_prmt.id)      := getValueFromDefinition('date', chainConfigMap('AUTO_PROCESS_DATE')) ;

    companyParams('EXECUTION_TYPE')    := 'by cron' ;
    --
    run_chain(chain_id, pck_batch_tools.getJSONFromSimpleMap(companyParams)) ;
    --
    logger.log(chainConfigMap('AUTO_PROCESS_DATE')) ;
    logger.log(getValueFromDefinition('date', chainConfigMap('AUTO_PROCESS_DATE'))) ;


end ;




procedure processActivityOutputs( activityExecution in batch_activity_executions%rowtype ) is

activity        batch_activities%rowtype ;
outputsList     pck_batch_mgr_activities.ActivityOutputsList_type ;

code    varchar2(100) ;
move_to varchar2(600) ;
send_to varchar2(600) ;
file_name varchar2(200) ;

begin
    --
    activity := getActivityByID(activityExecution.activity_id) ;
    --
    begin
        select output.* bulk collect into outputsList
        from BATCH_ACTIVITY_OUTPUTS output
        where activity_id = activity.id ;
    end ;
    --
    logger.log('ACTIVITY ' || activity.name || ' ' || activity.id , pck_batch_tools.getValueFromSimpleJSON(activity.config,'output_directory')) ;
    --
    for i in 1..outputsList.count() loop
        --
        code := pck_batch_tools.getValueFromSimpleJSON(outputsList(i).config,'code') ;
        move_to := pck_batch_tools.getValueFromSimpleJSON(outputsList(i).config,'move_to') ;
        send_to := pck_batch_tools.getValueFromSimpleJSON(outputsList(i).config,'send_to') ;
        file_name := outputsList(i).format_file_name ;
        --
        evaluateText(file_name) ;
        evaluateText(move_to) ;
        --
        logger.log('ACTTIVITY OUTPUT ' || file_name || ' to ' || move_to, pck_batch_tools.getValueFromSimpleJSON(outputsList(i).config,'') );
        --
    end loop ;
    --
exception
    when others then
        raise ;
end ;




procedure show_tabMaxV2( list in pck_batch_tools.tabMaxV2_type ) is
begin
    dbms_output.put_line('-- list ------ ('||list.count()||')') ;
    for indx in 1..list.count() loop
        dbms_output.put_line(list(indx)) ;
    end loop ;
end ;

function getBindBlocks(text in varchar2) return pck_batch_tools.tabMaxV2_type is

blocksList    pck_batch_tools.tabMaxV2_type ;

regex   varchar2(256) := '\[([^\[])+\]' ;

begin
    --
    select distinct regexp_substr(text, regex, 1, level) bulk collect into blocksList 
    from dual connect by level <= regexp_count( text, regex ) ;    
    --
    return blocksList ;
    --
exception
    when others then
        dbms_output.put_line(sqlcode ||' : ' || sqlerrm || chr(13) || dbms_utility.format_error_backtrace ) ;
        return null ;
end ;

function getParameters(text in varchar2) return pck_batch_tools.tabMaxV2_type is

paramsList    pck_batch_tools.tabMaxV2_type ;

regex   varchar2(256) := '\:\w+' ;

begin
    --
    select distinct regexp_substr(text, regex, 1, level) bulk collect into paramsList 
    from dual connect by level <= regexp_count( text, regex ) ;    
    --
    return paramsList ;
    --
exception
    when others then
        dbms_output.put_line(sqlcode ||' : ' || sqlerrm || chr(13) || dbms_utility.format_error_backtrace ) ;
        return null ;
end ;




procedure evaluateText(text in out varchar2) is

evaluatedText   varchar2(10240) ;


bindBlocksList  pck_batch_tools.tabMaxV2_type ;
auxList         pck_batch_tools.tabMaxV2_type ;  

bindBlocks_map  pck_batch_tools.simpleMap_type ;



blockEvaluated  varchar2(1024) ;

stmtTag     varchar2(20) := '<stmt>' ;
frmtTag     varchar2(20) := '<frmt>' ;
stmtText    varchar2(4000) := 'select trim('||stmtTag||') from dual' ;
toCharStmt  varchar2(50) := 'to_char(<stmt>,''<frmt>'')' ;
stmt        varchar2(100) ;

begin
    --
    dbms_output.put_line(text) ;
    --
    -- replacePrameters(text) ;
    --
    bindBlocksList := getBindBlocks(text) ; -- show_tabMaxV2(bindBlocksList) ;
    --
    for indx in 1..bindBlocksList.count() loop
        --
        auxList := pck_batch_tools.split(trim(translate(bindBlocksList(indx),'[]','  ')),'|') ; -- show_tabMaxV2(auxList) ;
        --
        if (auxList.count() = 2) then
            stmt := replace(stmtText,stmtTag,toCharStmt) ;
            stmt := replace(stmt,frmtTag,auxList(2)) ;
        end if ;
        --
        stmt := replace(stmt,stmtTag,auxList(1)) ;
        execute immediate stmt into blockEvaluated  ;
        text := replace( text,bindBlocksList(indx),blockEvaluated) ;
        --
    end loop ;
    --
    dbms_output.put_line(text) ;
    --
exception
    when others then
        --
        dbms_output.put_line(sqlcode ||' : ' || sqlerrm || chr(13) || dbms_utility.format_error_backtrace ) ;
       -- logger.log(sqlerrm, dbms_utility.format_error_backtrace ) ;
        -- return(sqlcode || ' : ' || sqlerrm ) ;
        --
end evaluateText ;





begin
    --
    logger := new Batch_Logger() ;
    --


    HomeCompany := pck_batch_companies.getHomeCompany() ;
    environmentMap := pck_batch_tools.getSimpleMapFromSimpleJSON(HomeCompany.config) ;
    --
        --environmentMap := pck_batch_tools.getSimpleMapFromSimpleJSON(
        --                                            DBMS_XslProcessor.read2clob(
        --                                                                XSL_DIRECTORY,
        --                                                                ENVIRONMENT_FILE_NAME)) ;

    --
    MAILS_SENDER            := environmentMap('MAILS_SENDER') ;
    ENVIRONMENT_NAME        := environmentMap('ENVIRONMENT_NAME') ;
    WEBAPP_URL              := environmentMap('WEBAPP_URL') ;
    REPORTSERVER_GATEWAY    := environmentMap('REPORTSERVER_GATEWAY') ;
    --
    logger.log( 'MAILS_SENDER : [' || MAILS_SENDER || ']' ) ;
    logger.log( 'ENVIRONMENT_NAME : [' || ENVIRONMENT_NAME || ']' ) ;
    logger.log( 'WEBAPP_URL : [' || WEBAPP_URL || ']' ) ;
    logger.log( 'REPORTSERVER_GATEWAY : [' || REPORTSERVER_GATEWAY || ']' ) ;
    --
    pck_batch_mgr_report.set_gateway(environmentMap('REPORTSERVER_GATEWAY')) ;
    --
end PCK_BATCH_MANAGER ;

/

  GRANT EXECUTE ON PCK_BATCH_MANAGER TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_MANAGER TO ROLE_HF_BATCH;
