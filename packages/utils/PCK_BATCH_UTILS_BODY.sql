CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_UTILS AS


logger batch_logger := new Batch_Logger() ;

ignoreDuplicateActivity boolean := false ;

DUPLICATE_CHAIN_CODE exception ;
PRAGMA exception_init(DUPLICATE_CHAIN_CODE, -56545);

aChain BATCH_CHAINS%rowtype ;



type ArgumentsList is table of ALL_ARGUMENTS%ROWTYPE index by pls_integer ; 


type ActivityParametersList is table of BATCH_ACTIVITY_PARAMETERS%ROWTYPE index by pls_integer ; 


procedure ignore_duplicate_activity( ignore boolean default true ) is
begin
    --
    ignoreDuplicateActivity := ignore ;
    --
end ;

function getActivityByCode( p_code in varchar2 ) return BATCH_ACTIVITIES%rowtype is

returnValue     BATCH_ACTIVITIES%rowtype ;

begin
    --
    select *
    into returnValue
    from BATCH_ACTIVITIES act
    where act.code = p_code ;
    --
    return returnValue ;
    --
exception
    when no_data_found then
        raise_application_error(-20101, 'La Actividad [code=' || p_code || '] no existe.  ' || sqlerrm || ' '  || dbms_utility.format_error_backtrace )  ;
    when too_many_rows then
        raise_application_error(-20101, 'Existe ms de una actividad [code=' || p_code || '].' )  ;
    when others then
        raise ;
end getActivityByCode ;


function getCompanyByCode(p_code in varchar2) return BATCH_COMPANIES%rowtype is

company     BATCH_COMPANIES%rowtype ;

begin
    --
    select *
        into company
    from BATCH_COMPANIES
    where code = p_code ;
    --
    return company ;
    --
exception
    when no_data_found then
        raise_application_error(-20101, 'La Compaa [code=' || p_code || '] no existe.' )  ;
    when too_many_rows then
        raise_application_error(-20101, 'Existe ms de una compaa [code=' || p_code || '].' )  ;
    when others then
        raise ;
end ;




function getHomeCompanyID return BATCH_COMPANIES.id%type is

company BATCH_COMPANIES%rowtype ;

begin
    --
    company := getCompanyByCode('HOME') ;
    --
    return getCompanyByCode('HOME').id ;
    --
exception
    when others then
        raise ;
end ;


--
-- CHAINS
--







function existsChainCode( p_code in varchar2 ) return boolean is 

codeExists boolean ;

found varchar2(5) ;

begin
    --
    begin
        -- 
        select 'found' into found -- old school :)
        from BATCH_CHAINS chain
        where chain.code = p_code ;
        --
        codeExists := true ;
        --
    exception
        when no_data_found then
            codeExists := false ;
            --
        when too_many_rows then
            codeExists := true ;
            --
        when others then
            raise ;
            --
    end ;    
    --
    return codeExists ;
    --
end ;

procedure saveChain( chain in out BATCH_CHAINS%ROWTYPE ) is

begin
    -- 
    if (chain.id is null) then
        --
        chain.id := pck_batch_tools.getNewId() ;
        --
        insert into BATCH_CHAINS (  id,
                                    name,
                                    code,
                                    description,
                                    config,
                                    company_id,
                                    rules_set
        ) values (  chain.id,
                    chain.name,
                    chain.code,
                    chain.description,
                    chain.config,
                    chain.company_id,
                    chain.rules_set
        ) ;
        --
    else
        --
        update BATCH_CHAINS
        set name        = chain.name,
            -- code        = chain.code,
            description = chain.description,
            config      = chain.config,
            rules_set   = chain.rules_set
        where id = chain.id ;
        --
    end if ;
    --
exception
    when others then
        raise ;
end ;

procedure validateNewChainCode( code in BATCH_CHAINS.code%type ) is

begin
    -- 
    if ( code is null ) then
        --
        raise_application_error(-20101, 'ERROR : El cdigo de Cadena no puede ser nulo. ' ) ;
        --
    elsif ( existsChainCode(code) ) then
        --
        raise_application_error(-20101, 'ERROR : El cdigo de Cadena (' || code || ') ya existe. ' );
        --
    end if ;
    --
end ;

function createChain(   chain_code          in BATCH_CHAINS.code%type,
                        chain_name          in BATCH_CHAINS.name%type,
                        chain_description   in BATCH_CHAINS.description%type default null,
                        chain_config        in BATCH_CHAINS.config%type default '{}',
                        chain_rules_set     in BATCH_CHAINS.rules_set%type default null,
                        chain_company_id    in BATCH_CHAINS.config%type default null  ) return BATCH_CHAINS%rowtype is

newChain  BATCH_CHAINS%ROWTYPE ;

begin
    --
    validateNewChainCode( chain_code ) ;
    --
    newChain.id             := null ; -- new chain
    newChain.code           := chain_code ;
    newChain.name           := chain_name ;
    newChain.description    := chain_description ;
    newChain.config         := chain_config ;
    newChain.rules_set      := chain_rules_set ;
    newChain.company_id     := nvl( chain_company_id, getHomeCompanyID ) ; -- 1 => home company
    --
    saveChain( newChain ) ;
    --
    dbms_output.put_line(' ') ;
    dbms_output.put_line('Cadena : [' || newChain.code || '] ' || newChain.name ) ;
    dbms_output.put_line('creada correctamente') ;
    dbms_output.put_line(' ') ;
    --
    return newChain ;
    --
exception
    when others then
        raise ;
end ;

procedure createChain(  chain_code          in BATCH_CHAINS.code%type,
                        chain_name          in BATCH_CHAINS.name%type,
                        chain_description   in BATCH_CHAINS.description%type default null,
                        chain_config        in BATCH_CHAINS.config%type default '{}',
                        chain_rules_set     in BATCH_CHAINS.rules_set%type default null,
                        chain_company_id    in BATCH_CHAINS.config%type default null  ) is

newChain  BATCH_CHAINS%ROWTYPE ;

begin
    --
    newChain := createChain( chain_code,
                             chain_name,
                             chain_description,
                             chain_config,
                             chain_rules_set,
                             chain_company_id ) ;
    --
exception
    when others then
        raise ;
end ;



--
-- PROCESSES
--

function existsProcessCode( p_code in varchar2 ) return boolean is 

codeExists boolean ;

found varchar2(5) ;

begin
    --
    begin
        -- 
        select 'found' into found -- old school :)
        from BATCH_PROCESSES proc
        where proc.code = p_code ;
        --
        codeExists := true ;
        --
    exception
        when no_data_found then
            codeExists := false ;
            --
        when too_many_rows then
            codeExists := true ;
            --
        when others then
            raise ;
            --
    end ;    
    --
    return codeExists ;
    --
end ;

procedure validateNewProcessCode( code in BATCH_PROCESSES.code%type ) is

begin
    --
    if ( code is null ) then
        --
        raise_application_error(-20101, 'ERROR : El cdigo de Proceso no puede ser nulo. ' );
        --
    elsif ( existsProcessCode(code) ) then
        --
        raise_application_error(-20101, 'ERROR : El cdigo de Proceso (' || code || ') ya existe. ' );
        --
    end if ;
    --
end ;

procedure saveProcess( process in out BATCH_PROCESSES%ROWTYPE ) is

begin
    -- 
    if (process.id is null) then
        --
        validateNewProcessCode( process.code ) ;
        --
        process.id          := pck_batch_tools.getNewId() ;
        process.company_id  := nvl( process.company_id, getHomeCompanyID ) ; -- home company 
        --
        insert into BATCH_PROCESSES (   id,
                                        name,
                                        code,
                                        description,
                                        config,
                                        company_id,
                                        rules_set,
                                        propagate_failed_state
        ) values (  process.id,
                    process.name,
                    process.code,
                    process.description,
                    process.config,
                    process.company_id,
                    process.rules_set,
                    process.propagate_failed_state
        ) ;
        --
    else
        --
        update BATCH_PROCESSES
        set name                    = process.name,
            description             = process.description,
            config                  = process.config,
            rules_set               = process.rules_set,
            propagate_failed_state  = process.propagate_failed_state
        where id = process.id ;
        --
    end if ;
    --
exception
    when others then
        raise ;
end ;

function createProcess( code                    in BATCH_PROCESSES.code%type,
                        name                    in BATCH_PROCESSES.name%type,
                        description             in BATCH_PROCESSES.description%type default null,
                        config                  in BATCH_PROCESSES.config%type default '{}',
                        rules_set               in BATCH_PROCESSES.rules_set%type default null,
                        propagate_failed_state  in BATCH_PROCESSES.propagate_failed_state%type default 'NO',
                        company_id              in BATCH_PROCESSES.config%type default null  ) return BATCH_PROCESSES%rowtype is

newProcess  BATCH_PROCESSES%ROWTYPE ;

begin
    --
    validateNewChainCode( code ) ;
    --
    newProcess.id                       := null ; -- new process
    newProcess.code                     := code ;
    newProcess.name                     := name ;
    newProcess.description              := description ;
    newProcess.config                   := config ;
    newProcess.rules_set                := rules_set ;
    newProcess.company_id               := nvl( company_id, getHomeCompanyID ) ; -- code='HOME' => home company
    newProcess.propagate_failed_state   := propagate_failed_state ;
    --
    saveProcess( newProcess ) ;
    --
    dbms_output.put_line(' ') ;
    dbms_output.put_line('Proceso : [' || newProcess.code || '] ' || newProcess.name ) ;
    dbms_output.put_line('creado correctamente') ;
    dbms_output.put_line(' ') ;
    --
    return newProcess ;
    --
exception
    when others then
        raise ;
end ;

procedure createProcess(    code                    in BATCH_PROCESSES.code%type,
                            name                    in BATCH_PROCESSES.name%type,
                            description             in BATCH_PROCESSES.description%type default null,
                            config                  in BATCH_PROCESSES.config%type default '{}',
                            rules_set               in BATCH_PROCESSES.rules_set%type default null,
                            propagate_failed_state  in BATCH_PROCESSES.propagate_failed_state%type default 'NO',
                            company_id              in BATCH_PROCESSES.config%type default null  ) is

newProcess  BATCH_PROCESSES%ROWTYPE ;

begin
    --
    newProcess := createProcess(    code,
                                    name,
                                    description,
                                    config,
                                    rules_set,
                                    propagate_failed_state,
                                    company_id ) ;
    --
exception
    when others then
        raise ;
end ;


--
-- Activities
--


procedure validateExistsProcedure( prc_owner in varchar2, prc_package in varchar2, prc_name in varchar2 ) is

ownerN  varchar2(30) ;

begin
    -- 
    select owner
    into ownerN
    from ALL_PROCEDURES
    where ( 1 = 1 )
        and ( prc_owner is null or owner = prc_owner )
        and ( prc_package is null or object_name = prc_package )
        and procedure_name = prc_name ;
    --
exception
    when no_data_found then
        raise_application_error(-20101, 'El procedimiento ' || prc_package || '.' || prc_name || ' no existe o el usuario ' || user || ' no tiene acceso al mismo.' )  ;
    when too_many_rows then
        raise_application_error(-20101, 'El procedimiento ' || prc_package || '.' || prc_name || ' existe ms de una vez, se debe incluir el owner del mismo (NO IMPLEMENTADO).' )  ;
    when others then
        raise ;
end ;



function existsActivityCode( p_code in varchar2 ) return boolean is 

codeExists boolean ;

found varchar2(5) ;

begin
    --
    begin
        -- 
        select 'found' into found -- old school :)
        from BATCH_ACTIVITIES act
        where act.code = p_code ;
        --
        codeExists := true ;
        --
    exception
        when no_data_found then
            codeExists := false ;
            --
        when too_many_rows then
            codeExists := true ;
            --
        when others then
            raise ;
            --
    end ;    
    --
    return codeExists ;
    --
end ;

procedure validateNewActivityCode( code in BATCH_ACTIVITIES.code%type ) is

begin
    --
    if ( code is null ) then
        --
        raise_application_error(-20101, 'ERROR : El cdigo de Actividad no puede ser nulo. ' );
        --
    elsif ( existsActivityCode(code) ) then
        --
        raise_application_error(-20102, 'ERROR : El cdigo de Actividad (' || code || ') ya existe. ' );
        --
    end if ;
    --
end ;

procedure saveActivity( activity in out BATCH_ACTIVITIES%ROWTYPE ) is

begin
    -- 
    if (activity.id is null) then
        --
        validateNewActivityCode( activity.code ) ;
        --
        activity.id          := pck_batch_tools.getNewId() ;
        activity.company_id  := nvl( activity.company_id, getHomeCompanyID ) ; -- home company 
        --
        insert into BATCH_ACTIVITIES (  id,
                                        name,
                                        code,
                                        description,
                                        action,
                                        config,
                                        propagate_failed_state,
                                        company_id,
                                        state
        ) values (  activity.id,
                    activity.name,
                    activity.code,
                    activity.description,
                    activity.action,
                    activity.config,
                    activity.propagate_failed_state,
                    activity.company_id,
                    activity.state
        ) ;
        --
    else
        --
        update BATCH_ACTIVITIES
        set name                    = activity.name,
            description             = activity.description,
            config                  = activity.config,
            propagate_failed_state  = activity.propagate_failed_state
        where id = activity.id ;
        --
    end if ;
    --
exception
    when others then
        raise ;
end ;

procedure createActivityParameter(  activity_id in BATCH_ACTIVITIES.id%type,
                                    parameter_name in varchar2,
                                    parameter_type in varchar2,
                                    parameter_position in varchar2 ) is

activityParameter BATCH_ACTIVITY_PARAMETERS%rowtype ;


begin
    -- 
    activityParameter.id            := pck_batch_tools.getNewId() ;
    activityParameter.activity_id   := activity_id ;
    activityParameter.name          := parameter_name ;
    activityParameter.type          := parameter_type ;
    activityParameter.position      := parameter_position ;
    --
    begin
        -- 
        insert into BATCH_ACTIVITY_PARAMETERS (
            id,
            activity_id,
            name,
            type,
            position,
            description,
            default_value,
            company_parameter_id
        ) VALUES (
            activityParameter.id,
            activityParameter.activity_id,
            activityParameter.name,
            activityParameter.type,
            activityParameter.position,
            activityParameter.description,
            activityParameter.default_value,
            activityParameter.company_parameter_id
        ) ;
        --
    exception
        when others then
            raise ;
    end ;
    --
exception
    when others then
        raise ;
end ;                                

procedure addActivityParameters(activity BATCH_ACTIVITIES%rowtype) is

splittedAction PCK_BATCH_TOOLS.tabMaxV2_type ;

ownerName       varchar2(30) ;
packageName     varchar2(30) ;
procedureName   varchar2(30) ;

argList ArgumentsList ;


begin
    --
    splittedAction := pck_batch_tools.split(activity.action,'.') ;
    -- 
    case splittedAction.count() 
        --
        when 1 then 
            --
            procedureName := splittedAction(1) ;
            --
        when 2 then 
            --
            packageName     := splittedAction(1) ;
            procedureName   := splittedAction(2) ;
            --
        else 
            raise_application_error(-20101, 'La accin asociada a la Actividad [' || activity.code || '] no tiene el formato correcto [package_name].[procedure_name] ej: PCK_BATCH_FAGL002.MAIN' )  ;
            --
    end case ;
    --    
    validateExistsProcedure( ownerName, packageName, procedureName ) ; 
    --
    begin
        -- 
        select * 
            bulk collect into argList
        from ALL_ARGUMENTS
        where ( 1 = 1 )
            and ( ownerName is null or owner = ownerName )
            and ( packageName is null or package_name = packageName )
            and object_name = procedureName 
        order by position ;
        --
        dbms_output.put_line('Parmetros') ;
        --
        for i in 1..argList.count() loop
            --
            createActivityParameter( activity.id, argList(i).argument_name, argList(i).data_type, argList(i).position ) ;
            --
            dbms_output.put_line( lpad(' ',20,' ') || rpad(argList(i).argument_name,30,' ') || ' ' || argList(i).data_type ) ;
            --            
            --
        end loop ;


        --
    exception
        when others then
            raise ;
    end ;    

exception
    when others then
        raise ;
end ;

function createActivity(    code                    in BATCH_ACTIVITIES.code%type,
                            name                    in BATCH_ACTIVITIES.name%type,
                            action                  in BATCH_ACTIVITIES.action%type,
                            description             in BATCH_ACTIVITIES.description%type default null,
                            config                  in BATCH_ACTIVITIES.config%type default '{}',
                            propagate_failed_state  in BATCH_ACTIVITIES.propagate_failed_state%type default 'NO',
                            company_id              in BATCH_ACTIVITIES.config%type default null  ) return BATCH_ACTIVITIES%rowtype is

newActivity  BATCH_ACTIVITIES%ROWTYPE ;

begin
    --
    validateNewActivityCode( code ) ;
    --
    newActivity.id                      := null ; -- new process
    newActivity.code                    := code ;
    newActivity.name                    := name ;
    newActivity.action                  := action ;
    newActivity.description             := description ;
    newActivity.config                  := config ;
    newActivity.company_id              := nvl( company_id, getHomeCompanyID ) ; -- 1 => home company
    newActivity.propagate_failed_state  := propagate_failed_state ;
    --
    saveActivity( newActivity ) ;
    --
    dbms_output.put_line(' ') ;
    dbms_output.put_line('Actividad [' || newActivity.code || '] {' || newActivity.action || '} ' || newActivity.name ) ;
    --
    addActivityParameters( newActivity ) ;
    --
    dbms_output.put_line('creada correctamente') ;
    dbms_output.put_line(' ') ;
    --
    return newActivity ;
    --
exception
    when others then
        --
        if sqlcode = -20102 then
            return getActivityByCode( newActivity.code ) ;
        end if ;
        --
        raise ;
        --
end ;

procedure createActivity(   code                    in BATCH_ACTIVITIES.code%type,
                            name                    in BATCH_ACTIVITIES.name%type,
                            action                  in BATCH_ACTIVITIES.action%type,
                            description             in BATCH_ACTIVITIES.description%type default null,
                            config                  in BATCH_ACTIVITIES.config%type default '{}',
                            propagate_failed_state  in BATCH_ACTIVITIES.propagate_failed_state%type default 'NO',
                            company_id              in BATCH_ACTIVITIES.config%type default null  ) is

newActivity  BATCH_ACTIVITIES%ROWTYPE ;

begin
    --
    newActivity := createActivity(  code,
                                    name,
                                    action,
                                    description,
                                    config,
                                    propagate_failed_state,
                                    company_id ) ;
    --
exception
    when others then
        raise ;
end ;







function getProcessByCode( p_code in varchar2 ) return BATCH_PROCESSES%rowtype is

returnValue     BATCH_PROCESSES%rowtype ;

begin
    --
    select *
    into returnValue
    from BATCH_PROCESSES proc
    where proc.code = p_code ;
    --
    return returnValue ;
    --
exception
    when no_data_found then
        raise_application_error(-20101, 'El Proceso [code=' || p_code || '] no existe.' )  ;
    when too_many_rows then
        raise_application_error(-20101, 'Existe ms de un proceso [code=' || p_code || '].' )  ;
    when others then
        raise ;
end getProcessByCode ;


function getChainByCode( p_code in varchar2 ) return BATCH_CHAINS%rowtype is

returnValue     BATCH_CHAINS%rowtype ;

begin
    --
    select *
    into returnValue
    from BATCH_CHAINS chn
    where chn.code = p_code ;
    --
    return returnValue ;
    --
exception
    when no_data_found then
        raise_application_error(-20101, 'La Cadena [code=' || p_code || '] no existe.' )  ;
    when too_many_rows then
        raise_application_error(-20101, 'Existe ms de una cadena [code=' || p_code || '].' )  ;
    when others then
        raise ;
end getChainByCode ;




function getActivityParametersList(p_activity_id in number) return activityParametersList is

paramList   ActivityParametersList ;

begin
    --
    select *
        bulk collect into paramList
    from BATCH_ACTIVITY_PARAMETERS
    where activity_id = p_activity_id ;
    --
    return paramList ;
    --
exception
    when others then
        raise ;
end ;




function createProcessActivity( p_process_id in number, 
                                p_activity_id in number,  
                                p_activity_code_on_process in varchar2,
                                p_activity_name_on_process in varchar2,
                                p_predecessors in varchar2 ) return BATCH_PROCESS_ACTIVITIES%rowtype is

processActivity     BATCH_PROCESS_ACTIVITIES%rowtype ;

begin
    --
    processActivity.id          := pck_batch_tools.getNewId() ;
    processActivity.process_id  := p_process_id ;
    processActivity.activity_id := p_activity_id ;
    processActivity.name        := p_activity_name_on_process ;
    processActivity.code        := p_activity_code_on_process ;
    --
    insert into BATCH_PROCESS_ACTIVITIES (
        id,
        process_id,
        name,
        activity_id,
        predecessors,
        config,
        code
    ) values (
        processActivity.id,
        processActivity.process_id,
        processActivity.name,
        processActivity.activity_id,
        processActivity.predecessors,
        processActivity.config,
        processActivity.code
    ) ;
    --
    return processActivity ;
    --
exception
    when others then
        raise ;
end ;



procedure createProcActivityParameter(  p_proc_activ_id in number, 
                                        p_activ_param_id in number,
                                        p_param_value in varchar2 ) is


newProcActivityParameter BATCH_PROC_ACTIV_PARAM_VALUES%rowtype ;

begin
    --
    newProcActivityParameter.id                     := pck_batch_tools.getNewId() ;
    newProcActivityParameter.process_activity_id    := p_proc_activ_id ;
    newProcActivityParameter.activity_parameter_id  := p_activ_param_id ;
    newProcActivityParameter.value                  := p_param_value ;
    --
    insert into BATCH_PROC_ACTIV_PARAM_VALUES (
        id,
        process_activity_id,
        activity_parameter_id,
        value
    ) values (
        newProcActivityParameter.id ,
        newProcActivityParameter.process_activity_id,
        newProcActivityParameter.activity_parameter_id,
        newProcActivityParameter.value
    ) ;
    --
exception
    when others then
        raise ;
end ;                                        


procedure createChainProcess(p_chain_id in number, p_process_id in number,  p_predecessors in varchar2 ) is

chainProcess     BATCH_CHAIN_PROCESSES%rowtype ;

begin
    --
    chainProcess.id             := pck_batch_tools.getNewId() ;
    chainProcess.process_id     := p_process_id ;
    chainProcess.chain_id       := p_chain_id ;
    chainProcess.predecessors   := p_predecessors ;
    --
    insert into BATCH_CHAIN_PROCESSES (
        id,
        chain_id,
        process_id,
        predecessors
    ) VALUES (
        chainProcess.id,
        chainProcess.chain_id,
        chainProcess.process_id,
        chainProcess.predecessors
    ) ;
    --
exception
    when others then
        raise ;
end ;                                        



procedure addActivityToProcess( p_activity_code in varchar2, 
                                p_process_code in varchar2, 
                                p_activity_code_on_process in varchar2 default null, 
                                p_activity_name_on_process in varchar2 default null,
                                p_predecessors in varchar2 default null ) is

activity    BATCH_ACTIVITIES%rowtype ;
process     BATCH_PROCESSES%rowtype ;
--
actParamList   ActivityParametersList ;


processActivity BATCH_PROCESS_ACTIVITIES%rowtype ; 


begin
    -- 
    activity    := getActivityByCode( p_activity_code )  ;
    process     := getProcessByCode( p_process_code ) ;
    --
    processActivity := createProcessActivity( process.id, 
                                              activity.id, 
                                              nvl( p_activity_code_on_process, activity.code ),  
                                              nvl( p_activity_name_on_process, activity.name), 
                                              p_predecessors );
    --
    actParamList    := getActivityParametersList( activity.id ) ;
    --
    for i in 1..actParamList.count() loop
        --
        createProcActivityParameter( processActivity.id, actParamList(i).id, '{value}') ;
        --
    end loop ;
    --
    dbms_output.put_line('') ;
    dbms_output.put_line('Actividad "' || activity.name || '"' ) ;
    dbms_output.put_line('    agregada correctamente al proceso "' || process.name || '"' ) ;
    dbms_output.put_line('') ;    
    --
exception
    when others then
        raise ;
end addActivityToProcess ;


procedure addProcessToChain( p_process_code in varchar2,
                             p_chain_code in varchar2,
                             p_predecessors in varchar2 )  is

chain       BATCH_CHAINS%rowtype ;
process     BATCH_PROCESSES%rowtype ;

begin
    -- 
    chain   := getChainByCode( p_chain_code )  ;
    process := getProcessByCode( p_process_code ) ;    
    --
    createChainProcess( chain.id, process.id, p_predecessors ) ;
    dbms_output.put_line('') ;
    dbms_output.put_line('Proceso "' || process.name || '"' ) ;
    dbms_output.put_line('    agregado correctamente a la cadena "' || chain.name || '"' ) ;
    dbms_output.put_line('') ;
    --
exception
    when others then
        raise ;
end ;



end PCK_BATCH_UTILS ;


/

  GRANT EXECUTE ON PCK_BATCH_UTILS TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_UTILS TO ROLE_HF_BATCH;
