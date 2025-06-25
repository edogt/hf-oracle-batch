CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_DSI as


type ChainStepsList_type is table of USER_SCHEDULER_CHAIN_STEPS%rowtype index by pls_integer ;
type ChainRulesList_type is table of USER_SCHEDULER_CHAIN_RULES%rowtype index by pls_integer ;



procedure create_chain( chain_name            in varchar2,
                              rule_set_name         in varchar2 default null,
                              evaluation_interval   in interval day to second default null,
                              comments              in varchar2 default null ) is
begin
    --
    dbms_scheduler.create_chain(chain_name, rule_set_name, evaluation_interval, comments) ;
    --
exception
    when others then
        --
        if ( sqlcode != -27477) then -- -27477: ORA-27477: chain already exists
            raise ;
        end if ;
        --
        drop_chain( chain_name, true, true ) ;
        create_chain( chain_name, rule_set_name, evaluation_interval, comments) ;
        --
end ;

procedure drop_chain_steps( chainName in varchar2 ) is

chainStepsList  ChainStepsList_type ;
indx            pls_integer ;

begin
    --
    select * bulk collect into chainStepsList
      from USER_SCHEDULER_CHAIN_STEPS steps
     where steps.chain_name = chainName ;
    --
    indx:= chainStepsList.first() ;
    while ( indx is not null ) loop
        --
        drop_chain_step( chainName, chainStepsList(indx).step_name ) ;
        --
        --
        indx:= chainStepsList.next(indx) ;
        --
    end loop ;
    --
exception
    when others then
        raise ;
end ;


procedure drop_chain_rules( chainName in varchar2 ) is

chainRulesList  ChainRulesList_type ;
indx            pls_integer ;

begin
    --
    select * bulk collect into chainRulesList
      from USER_SCHEDULER_CHAIN_RULES rules
     where rules.chain_name = chainName ;
    --
    indx:= chainRulesList.first() ;
    while ( indx is not null ) loop
        --
        drop_chain_rule( chainName, chainRulesList(indx).rule_name ) ;
        --
        --
        indx:= chainRulesList.next(indx) ;
        --
    end loop ;
    --
exception
    when others then
        raise ;
end ;



procedure drop_chain( chain_name  in varchar2, ignore_no_found boolean default true, force in boolean default false ) is

begin
    --
    drop_chain_rules( chain_name ) ;
    drop_chain_steps( chain_name ) ;
    --
    dbms_scheduler.drop_chain(chain_name, force) ;
    --
exception
    when others then
        --
        if ( sqlcode != -23308) then
            raise ;
        end if ;
        --
end ;


procedure create_program ( program_name         in varchar2,
                           program_type         in varchar2,
                           program_action       in varchar2,
                           number_of_arguments  in pls_integer default 0,
                           enabled              in boolean default false,
                           comments             in varchar2 default null ) is
begin
    --
    dbms_scheduler.create_program( program_name, program_type, program_action, number_of_arguments, enabled, comments ) ;
    --
exception
    when others then
        --
        if ( sqlcode != -27477) then
            raise ;
        end if ;
        --
        drop_program( program_name, true ) ;
        create_program( program_name, program_type, program_action, number_of_arguments, enabled, comments ) ;
        --
end ;

procedure drop_program( program_name    in varchar2,
                        force           in boolean default false) is
begin
    --
    dbms_scheduler.drop_program( program_name, force ) ;
    --
exception
    when others then
        if ( sqlcode != -27476) then
            raise ; 
        end if ;
        --
        drop_program( program_name, true ) ;
        --
end ;

procedure define_chain_step ( chain_name    in varchar2,
                              step_name     in varchar2,
                              program_name  in varchar2) is

begin
    --
    dbms_scheduler.define_chain_step(chain_name, step_name, program_name) ;
    --
exception
    when others then
        raise ;
end ;

procedure drop_chain_step ( chain_name  in varchar2,
                            step_name   in varchar2,
                            force       in boolean default false) is
begin
    --
    dbms_scheduler.drop_chain_step( chain_name, step_name, force ) ;
    --
exception
    when others then
        raise ;
end ;

procedure define_chain_rule( chain_name in varchar2,
                             condition  in varchar2,
                             action     in varchar2,
                             rule_name  in varchar2 default null,
                             comments   in varchar2 default null ) is
begin
    --
    dbms_scheduler.define_chain_rule( chain_name, condition, action, rule_name, comments ) ;
    --
exception
    when others then
        raise ;
end ;

procedure drop_chain_rule( chain_name   in varchar2,
                           rule_name    in varchar2,
                           force        in boolean default false ) is
begin
    --
    dbms_scheduler.drop_chain_rule( chain_name, rule_name, force ) ;
    --
exception
    when others then
        raise ;
end ;



--
-- enable : <:description>
procedure enable( name  in varchar2 )  is

begin
    --
    dbms_scheduler.enable( name ) ;
    --
end enable ;


procedure create_job( job_name             in varchar2,
                      job_type             in varchar2,
                      job_action           in varchar2,
                      start_date           in timestamp with time zone default null,
                      repeat_interval      in varchar2                 default null,
                      end_date             in timestamp with time zone default null,
                      enabled              in boolean                  default true,
                      auto_drop            in boolean                  default false,
                      comments             in varchar2                 default null ) is
begin
    --
    dbms_scheduler.create_job(  job_name           => job_name,
                                job_type           => job_type,
                                job_action         => job_action,
                                start_date         => start_date,
                                repeat_interval    => repeat_interval,
                                end_date           => end_date,
                                enabled            => enabled,
                                auto_drop          => auto_drop,
                                comments           => comments ) ;
    --
exception
    when others then
        raise ;
end ;   
   
   
   
                

procedure drop_job( job_name    in varchar2,
                    force       in boolean default false,
                    defer       in boolean default false ) is

begin
    --
    dbms_scheduler.drop_job( job_name => job_name ) ;
    --
exception
    when others then
        if ( sqlcode != -27475) then
            raise ; 
        end if ;

end ;








end PCK_BATCH_DSI ;

/
