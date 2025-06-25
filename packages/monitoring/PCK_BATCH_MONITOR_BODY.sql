CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_MONITOR AS

function get_sched_chain_rules return TYP_SCHED_CHAIN_RULES_SET PIPELINED is

  outputObject TYP_SCHED_CHAIN_RULES := TYP_SCHED_CHAIN_RULES(null, null, null, null, null, null) ;

begin
    --
    for rec in (select * from USER_SCHEDULER_CHAIN_RULES) loop
        --
        outputObject.chain_name     := rec.chain_name ;
        outputObject.rule_owner     := rec.rule_owner ;
        outputObject.rule_name      := rec.rule_name ;
        outputObject.condition      := rec.condition ;
        outputObject.action         := rec.action ;
        outputObject.comments       := rec.comments ;
        --
        pipe row(outputObject) ;
        --
    end loop ;
    --
    return ;
    --
end get_sched_chain_rules ; 

function get_sched_chains return TYP_SCHED_CHAINS_SET PIPELINED is

  outputObject TYP_SCHED_CHAINS := TYP_SCHED_CHAINS(null, null, null, null, null, null, null, null, null) ;

begin
    --
    for rec in (select * from USER_SCHEDULER_CHAINS) loop
        --
        outputObject.chain_name             := rec.chain_name ;
        outputObject.rule_set_owner         := rec.rule_set_owner ;
        outputObject.rule_set_name          := rec.rule_set_name ;
        outputObject.number_of_rules        := rec.number_of_rules ;
        outputObject.number_of_steps        := rec.number_of_steps ;
        outputObject.enabled                := rec.enabled ;
        outputObject.evaluation_interval    := rec.evaluation_interval ;
        outputObject.user_rule_set          := rec.user_rule_set ;
        outputObject.comments               := rec.comments ;
        --
        pipe row(outputObject) ;
        --
    end loop ;
    --
    return ;
    --
end get_sched_chains ; 

function get_sched_chain_steps return TYP_SCHED_CHAIN_STEPS_SET PIPELINED is

  outputObject TYP_SCHED_CHAIN_STEPS := TYP_SCHED_CHAIN_STEPS(null, null, null, null, null, null, null, null, null, null, null) ;

begin
    --
    for rec in (select * from USER_SCHEDULER_CHAIN_STEPS) loop
        --
        outputObject.chain_name             := rec.chain_name ;
        outputObject.step_name              := rec.step_name ;
        outputObject.program_owner          := rec.program_owner ;
        outputObject.program_name           := rec.program_name ;
        outputObject.skip                   := rec.skip ;
        outputObject.pause                  := rec.pause ;
        outputObject.pause_before           := rec.pause_before ;
        outputObject.restart_on_recovery    := rec.restart_on_recovery ;
        outputObject.restart_on_failure     := rec.restart_on_failure ;
        outputObject.step_type              := rec.step_type ;
        outputObject.timeout                := rec.timeout ;
        --
        pipe row(outputObject) ;
        --
    end loop ;
    --
    return ;
    --
end get_sched_chain_steps ; 

function get_sched_job_dests return TYP_SCHED_JOB_DESTS_SET PIPELINED is

  outputObject TYP_SCHED_JOB_DESTS := TYP_SCHED_JOB_DESTS(null, null, null, null, null, null, null, null, null, null, null) ;

begin
    --
    for rec in (select * from USER_SCHEDULER_JOB_DESTS) loop
        --
        outputObject.job_name           := rec.job_name ;
        outputObject.job_subname        := rec.job_subname ;
        outputObject.enabled            := rec.enabled ;
        outputObject.refs_enabled       := rec.refs_enabled ;
        outputObject.state              := rec.state ;
        outputObject.next_start_date    := rec.next_start_date ;
        outputObject.run_count          := rec.run_count ;
        outputObject.retry_count        := rec.retry_count ;
        outputObject.failure_count      := rec.failure_count ;
        outputObject.last_start_date    := rec.last_start_date ;
        outputObject.last_end_date      := rec.last_end_date ;
        --
        pipe row(outputObject) ;
        --
    end loop ;
    --
    return ;
    --
end get_sched_job_dests ; 

function get_sched_job_log return TYP_SCHED_JOB_LOG_SET PIPELINED is

  outputObject TYP_SCHED_JOB_LOG := TYP_SCHED_JOB_LOG(null, null, null, null, null, null, null, null, null) ;

begin
    --
    for rec in (select * from USER_SCHEDULER_JOB_LOG) loop
        --
        outputObject.log_id             := rec.log_id ;
        outputObject.log_date           := rec.log_date ;
        outputObject.owner              := rec.owner ;
        outputObject.job_name           := rec.job_name ;
        outputObject.job_subname        := rec.job_subname ;
        outputObject.operation          := rec.operation ;
        outputObject.status             := rec.status ;
        outputObject.user_name          := rec.user_name ;
        outputObject.additional_info    := rec.additional_info ;
        --
        pipe row(outputObject) ;
        --
    end loop ;
    --
    return ;
    --
end get_sched_job_log ; 

function get_sched_job_run_details return TYP_SCHED_JOB_RUN_DETAILS_SET PIPELINED is

  outputObject TYP_SCHED_JOB_RUN_DETAILS := TYP_SCHED_JOB_RUN_DETAILS(null, null, null, null, null, null, null, null, null, null, null) ;

begin
    --
    for rec in (select * from USER_SCHEDULER_JOB_RUN_DETAILS) loop
        --
        outputObject.log_id             := rec.log_id ;
        outputObject.log_date           := rec.log_date ;
        outputObject.owner              := rec.owner ;
        outputObject.job_name           := rec.job_name ;
        outputObject.job_subname        := rec.job_subname ;
        outputObject.status             := rec.status ;
        outputObject.error#             := rec.error#    ;
        outputObject.req_start_date     := rec.req_start_date ;
        outputObject.actual_start_date  := rec.actual_start_date ;
        outputObject.run_duration       := rec.run_duration ;
        outputObject.additional_info    := rec.additional_info ;
        --
        pipe row(outputObject) ;
        --
    end loop ;
    --
    return ;
    --
end get_sched_job_run_details ; 

function get_sched_jobs return TYP_SCHED_JOBS_SET PIPELINED is

  outputObject TYP_SCHED_JOBS := TYP_SCHED_JOBS(null, null, null, null, null, null, null, null, null, null, null, null, null) ;

begin
    --
    for rec in (select * from USER_SCHEDULER_JOBS) loop
        --
        outputObject.job_name               := rec.job_name ;
        outputObject.state                  := rec.state ;
        outputObject.start_date             := rec.start_date ;
        outputObject.last_start_date        := rec.last_start_date ;
        outputObject.last_run_duration      := rec.last_run_duration ;
        outputObject.next_run_date          := rec.next_run_date ;
        outputObject.program_name           := rec.program_name ;
        outputObject.job_type               := rec.job_type ;
        outputObject.repeat_interval        := rec.repeat_interval ;
        outputObject.enabled                := rec.enabled ;
        outputObject.auto_drop              := rec.auto_drop ;
        outputObject.restart_on_recovery    := rec.restart_on_recovery ;
        outputObject.run_count              := rec.run_count ;
        --
        pipe row(outputObject) ;
        --
    end loop ;
    --
    return ;
    --
end get_sched_jobs ; 

function get_sched_programs return TYP_SCHED_PROGRAMS_SET PIPELINED is

  outputObject TYP_SCHED_PROGRAMS := TYP_SCHED_PROGRAMS(null, null, null, null, null, null, null, null, null, null, null) ;

begin
    --
    for rec in (select * from USER_SCHEDULER_PROGRAMS) loop
        --
        outputObject.program_name           := rec.program_name ;
        outputObject.program_type           := rec.program_type ;
        outputObject.program_action         := rec.program_action ;
        outputObject.number_of_arguments    := rec.number_of_arguments ;
        outputObject.enabled                := rec.enabled ;
        outputObject.detached               := rec.detached ;
        outputObject.priority               := rec.priority ;
        outputObject.max_runs               := rec.max_runs ;
        outputObject.max_failures           := rec.max_failures ;
        outputObject.max_run_duration       := rec.max_run_duration ;
        outputObject.comments               := rec.comments ;
        --
        pipe row(outputObject) ;
        --
    end loop ;
    --
    return ;
    --
end get_sched_programs ; 

function get_sched_running_chains return TYP_SCHED_RUNNING_CHAINS_SET PIPELINED is

  outputObject TYP_SCHED_RUNNING_CHAINS := TYP_SCHED_RUNNING_CHAINS(null, null, null, null, null, null, null, null, null, null, null, null, null, null) ;

begin
    --
    for rec in (select * from USER_SCHEDULER_RUNNING_CHAINS) loop
        --
        outputObject.job_name           := rec.job_name ;
        outputObject.job_subname        := rec.job_subname ;
        outputObject.chain_owner        := rec.chain_owner ;
        outputObject.chain_name         := rec.chain_name ;
        outputObject.step_name          := rec.step_name ;
        outputObject.state              := rec.state ;
        outputObject.error_code         := rec.error_code ;
        outputObject.completed          := rec.completed ;
        outputObject.start_date         := rec.start_date ;
        outputObject.end_date           := rec.end_date ;
        outputObject.duration           := rec.duration ;
        outputObject.skip               := rec.skip ;
        outputObject.step_job_subname   := rec.step_job_subname ;
        outputObject.step_job_log_id    := rec.step_job_log_id ;
        --
        pipe row(outputObject) ;
        --
    end loop ;
    --
    return ;
    --
end get_sched_running_chains ; 

function get_sched_running_jobs return TYP_SCHED_RUNNING_JOBS_SET PIPELINED is

  outputObject TYP_SCHED_RUNNING_JOBS := TYP_SCHED_RUNNING_JOBS(null, null, null, null, null, null) ;

begin
    --
    for rec in (select * from USER_SCHEDULER_RUNNING_JOBS) loop
        --
        outputObject.job_name           := rec.job_name ;
        outputObject.job_subname           := rec.job_subname ;
        outputObject.job_style           := rec.job_style ;
        outputObject.detached           := rec.detached ;
        outputObject.session_id           := rec.session_id ;
        outputObject.elapsed_time           := rec.elapsed_time ;
        --
        pipe row(outputObject) ;
        --
    end loop ;
    --
    return ;
    --
end get_sched_running_jobs ; 

end PCK_BATCH_MONITOR ;

GRANT EXECUTE ON PCK_BATCH_MONITOR TO USR_BATCH_EXEC;
GRANT EXECUTE ON PCK_BATCH_MONITOR TO ROLE_BATCH_MAN;

/
