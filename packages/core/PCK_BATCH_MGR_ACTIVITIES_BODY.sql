CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_MGR_ACTIVITIES as

function getActivityById(activity_id in varchar2) return BATCH_ACTIVITIES%rowtype is

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
    when others then
        pck_batch_mgr_log.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end ;

function getActivityExecutionById(execution_id in number) return batch_activity_executions%rowtype is
activityExecution batch_activity_executions%rowtype ;
begin
    --
    select act_exec.*
    into activityExecution
    from BATCH_ACTIVITY_EXECUTIONS act_exec
    where (1=1)
      and id = execution_id ;
    --
    return activityExecution ;
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


procedure add_parameterValue(param_list in out ActionParamTypedValList_type, param_name in varchar2, param_value in number ) is

val ActionParamTypedValue_type ;


begin
    --
    val.number_value := param_value ;
    param_list(param_name) := val ;
    --
end ;

--type ActionParamTypedValue_type is record (
--number_value    number,
--v2_value        varchar2(5000),
--date_value      date
--) ;



procedure add_parameterValue(param_list in out ActionParamTypedValList_type, param_name in varchar2, param_value in varchar2 ) is

val ActionParamTypedValue_type ;


begin
    --
    val.v2_value := param_value ;
    param_list(param_name) := val ;
    --
end ;

procedure add_parameterValue(param_list in out ActionParamTypedValList_type, param_name in varchar2, param_value in date ) is

val ActionParamTypedValue_type ;


begin
    --
    val.date_value := param_value ;
    param_list(param_name) := val ;
    --
end ;

procedure processActivityOutputs(activityExecution in  batch_activity_executions%rowtype ) is

begin
    --
    null ;
    --
exception
    when others then
        raise ;
end ;


function getSimpleMapFromTypedValList(typedList ActionParamTypedValList_type) return pck_batch_tools.simpleMap_type is

mapList pck_batch_tools.simpleMap_type ;
val     varchar2(500) ;

begin
    --
    for indx in typedList.first..typedList.last loop
        --
        if ((typedList(indx).number_value is not null) or (typedList(indx).v2_value is not null)) then
            val := nvl(typedList(indx).number_value, typedList(indx).v2_value) ;
        else
            val := to_char(typedList(indx).date_value, 'YYYYMMDD') ;
        end if ;
        --
        mapList(indx) := val ;
        --
    end loop ;
    --
    return mapList ;
    --
exception
    when others then
        raise ;
end ;


END PCK_BATCH_MGR_ACTIVITIES;

/

GRANT EXECUTE ON PCK_BATCH_MGR_ACTIVITIES TO ROLE_HF_BATCH;
