-- =============================================================================
-- HF Oracle Batch - Master Deployment Script
-- =============================================================================
-- 
-- Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
-- Date: 2024
-- Version: 1.0
-- 
-- Description: 
--   Master script that creates all system objects in the correct dependency order.
--   This script orchestrates the complete deployment of the HF Oracle Batch system.
--
-- Prerequisites:
--   - Oracle Database 12c or higher
--   - Appropriate database privileges (CREATE TABLE, CREATE SEQUENCE, CREATE VIEW, etc.)
--   - PL/SQL development environment
--
-- Execution Order:
--   1. Types (PL/SQL type definitions)
--   2. Sequences (for ID generation)
--   3. Tables (in dependency order)
--   4. Packages (PL/SQL packages)
--   5. Views (monitoring and reporting views)
--   6. Functions (standalone functions)
--   7. Roles and permissions
--
-- Dependencies:
--   - Tables with foreign keys are created after their referenced tables
--   - Views are created after all tables and packages
--   - Packages are created after types and sequences
--
-- =============================================================================

-- Initial configuration
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;
SET PAGESIZE 1000;
SET TRIMSPOOL ON;
SET FEEDBACK ON;
SET ECHO ON;
SET TIMING ON;

-- Start deployment
PROMPT =============================================================================
PROMPT HF Oracle Batch - Starting System Deployment
PROMPT =============================================================================
PROMPT

-- =============================================================================
-- STEP 1: Types Creation
-- =============================================================================
PROMPT Creating PL/SQL types...

@types/TYP_SCHED_CHAIN_RULES.sql
@types/TYP_SCHED_CHAIN_RULES_SET.sql
@types/TYP_SCHED_CHAIN_STEPS.sql
@types/TYP_SCHED_CHAIN_STEPS_SET.sql
@types/TYP_SCHED_CHAINS.sql
@types/TYP_SCHED_CHAINS_SET.sql
@types/TYP_SCHED_JOBS.sql
@types/TYP_SCHED_JOBS_SET.sql
@types/TYP_SCHED_JOB_DESTS.sql
@types/TYP_SCHED_JOB_DESTS_SET.sql
@types/TYP_SCHED_JOB_LOG.sql
@types/TYP_SCHED_JOB_LOG_SET.sql
@types/TYP_SCHED_JOB_RUN_DETAILS.sql
@types/TYP_SCHED_JOB_RUN_DETAILS_SET.sql
@types/TYP_SCHED_PROGRAMS.sql
@types/TYP_SCHED_PROGRAMS_SET.sql
@types/TYP_SCHED_RUNNING_CHAINS.sql
@types/TYP_SCHED_RUNNING_CHAINS_SET.sql
@types/TYP_SCHED_RUNNING_JOBS.sql
@types/TYP_SCHED_RUNNING_JOBS_SET.sql
@types/BATCH_LOGGER.sql

PROMPT Types creation completed.
PROMPT

-- =============================================================================
-- STEP 2: Sequences Creation
-- =============================================================================
PROMPT Creating sequences...

@sequences/BATCH_GLOBAL_ID_SEQ.sql

PROMPT Sequences creation completed.
PROMPT

-- =============================================================================
-- STEP 3: Tables Creation (in dependency order)
-- =============================================================================
PROMPT Creating tables in dependency order...

-- Base tables (no foreign key dependencies)
PROMPT Creating base tables...
@tables/BATCH_COMPANIES/00_deploy.sql

-- Tables with foreign key to BATCH_COMPANIES
PROMPT Creating company-dependent tables...
@tables/BATCH_CHAINS/00_deploy.sql
@tables/BATCH_PROCESSES/00_deploy.sql
@tables/BATCH_ACTIVITIES/00_deploy.sql
@tables/BATCH_COMPANY_PARAMETERS/00_deploy.sql

-- Tables with foreign key to BATCH_CHAINS
PROMPT Creating chain-dependent tables...
@tables/BATCH_CHAIN_PROCESSES/00_deploy.sql
@tables/BATCH_CHAIN_EXECUTIONS/00_deploy.sql

-- Tables with foreign key to BATCH_PROCESSES
PROMPT Creating process-dependent tables...
@tables/BATCH_PROCESS_ACTIVITIES/00_deploy.sql
@tables/BATCH_PROCESS_EXECUTIONS/00_deploy.sql

-- Tables with foreign key to BATCH_ACTIVITIES
PROMPT Creating activity-dependent tables...
@tables/BATCH_ACTIVITY_PARAMETERS/00_deploy.sql

-- Tables with foreign key to BATCH_PROCESS_ACTIVITIES
PROMPT Creating process-activity-dependent tables...
@tables/BATCH_PROC_ACTIV_PARAM_VALUES/00_deploy.sql

-- Tables with foreign key to BATCH_PROCESS_EXECUTIONS and BATCH_ACTIVITIES
PROMPT Creating execution-dependent tables...
@tables/BATCH_ACTIVITY_EXECUTIONS/00_deploy.sql

-- Tables with foreign key to BATCH_ACTIVITY_EXECUTIONS
PROMPT Creating activity-execution-dependent tables...
@tables/BATCH_ACTIV_EXEC_PARAM_VALUES/00_deploy.sql
@tables/BATCH_ACTIVITY_OUTPUTS/00_deploy.sql

-- Log table (depends on all execution tables)
PROMPT Creating logging table...
@tables/BATCH_SIMPLE_LOG/00_deploy.sql

PROMPT Tables creation completed.
PROMPT

-- =============================================================================
-- STEP 4: Packages Creation
-- =============================================================================
PROMPT Creating PL/SQL packages...

-- Core packages
PROMPT Creating core packages...
@packages/core/PCK_BATCH_MANAGER_SPEC.sql
@packages/core/PCK_BATCH_MANAGER_BODY.sql
@packages/core/PCK_BATCH_MGR_CHAINS_SPEC.sql
@packages/core/PCK_BATCH_MGR_CHAINS_BODY.sql
@packages/core/PCK_BATCH_MGR_PROCESSES_SPEC.sql
@packages/core/PCK_BATCH_MGR_PROCESSES_BODY.sql
@packages/core/PCK_BATCH_MGR_ACTIVITIES_SPEC.sql
@packages/core/PCK_BATCH_MGR_ACTIVITIES_BODY.sql
@packages/core/PCK_BATCH_MGR_LOG_SPEC.sql
@packages/core/PCK_BATCH_MGR_LOG_BODY.sql
@packages/core/PCK_BATCH_MGR_REPORT_SPEC.sql
@packages/core/PCK_BATCH_MGR_REPORT_BODY.sql
@packages/core/PCK_BATCH_COMPANIES_SPEC.sql
@packages/core/PCK_BATCH_COMPANIES_BODY.sql
@packages/core/PCK_BATCH_CHECK_SPEC.sql
@packages/core/PCK_BATCH_CHECK_BODY.sql
@packages/core/PCK_BATCH_DSI_SPEC.sql
@packages/core/PCK_BATCH_DSI_BODY.sql

-- Monitoring packages
PROMPT Creating monitoring packages...
@packages/monitoring/PCK_BATCH_MONITOR_SPEC.sql
@packages/monitoring/PCK_BATCH_MONITOR_BODY.sql

-- Utility packages
PROMPT Creating utility packages...
@packages/utils/PCK_BATCH_TOOLS_SPEC.sql
@packages/utils/PCK_BATCH_TOOLS_BODY.sql
@packages/utils/PCK_BATCH_UTILS_SPEC.sql
@packages/utils/PCK_BATCH_UTILS_BODY.sql

PROMPT Packages creation completed.
PROMPT

-- =============================================================================
-- STEP 5: Views Creation
-- =============================================================================
PROMPT Creating monitoring and reporting views...

@views/V_BATCH_ACTIVITY_EXECUTIONS.sql
@views/V_BATCH_ACTIVS_LAST_EXECS.sql
@views/V_BATCH_CHAIN_EXECS.sql
@views/V_BATCH_CHAIN_EXECUTIONS.sql
@views/V_BATCH_CHAIN_LAST_EXECS_VIEW.sql
@views/V_BATCH_DEFINITION_HIERARCHY.sql
@views/V_BATCH_LAST_SIMPLE_LOG.sql
@views/V_BATCH_PROCESS_EXECUTIONS.sql
@views/V_BATCH_PROCS_LAST_EXECS.sql
@views/V_BATCH_RUNNING_ACTIVITIES.sql
@views/V_BATCH_RUNNING_CHAINS.sql
@views/V_BATCH_RUNNING_CHAINS2.sql
@views/V_BATCH_RUNNING_PROCESSES.sql
@views/V_BATCH_SCHED_CHAINS.sql
@views/V_BATCH_SCHED_CHAIN_RULES.sql
@views/V_BATCH_SCHED_CHAIN_STEPS.sql
@views/V_BATCH_SCHED_JOBS.sql
@views/V_BATCH_SCHED_JOB_DESTS.sql
@views/V_BATCH_SCHED_JOB_LOG.sql
@views/V_BATCH_SCHED_JOB_RUN_DETAILS.sql
@views/V_BATCH_SCHED_PROGRAMS.sql
@views/V_BATCH_SCHED_RUNNING_CHAINS.sql
@views/V_BATCH_SCHED_RUNNING_JOBS.sql
@views/V_BATCH_SIMPLE_LOG.sql

PROMPT Views creation completed.
PROMPT

-- =============================================================================
-- STEP 6: Functions Creation
-- =============================================================================
PROMPT Creating standalone functions...

@functions/GETJOBSDESTS.sql

PROMPT Functions creation completed.
PROMPT

-- =============================================================================
-- STEP 7: Roles and Permissions Creation
-- =============================================================================
PROMPT Creating roles and permissions...

-- Create HF Oracle Batch user role (for end users)
CREATE ROLE HFOBATCH_USER;

-- Create HF Oracle Batch developer role (for developers)
CREATE ROLE HFOBATCH_DEVELOPER;

-- Grant execute permissions on all batch packages to USER role
GRANT EXECUTE ON PCK_BATCH_MANAGER TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_MGR_CHAINS TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_MGR_PROCESSES TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_MGR_ACTIVITIES TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_MGR_LOG TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_MGR_REPORT TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_COMPANIES TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_CHECK TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_DSI TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_MONITOR TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_TOOLS TO HFOBATCH_USER;
GRANT EXECUTE ON PCK_BATCH_UTILS TO HFOBATCH_USER;

-- Grant execute permissions on all batch packages to DEVELOPER role
GRANT EXECUTE ON PCK_BATCH_MANAGER TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_MGR_CHAINS TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_MGR_PROCESSES TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_MGR_ACTIVITIES TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_MGR_LOG TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_MGR_REPORT TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_COMPANIES TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_CHECK TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_DSI TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_MONITOR TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_TOOLS TO HFOBATCH_DEVELOPER;
GRANT EXECUTE ON PCK_BATCH_UTILS TO HFOBATCH_DEVELOPER;

-- Grant select permissions on all batch views to USER role
GRANT SELECT ON V_BATCH_ACTIVITY_EXECUTIONS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_ACTIVS_LAST_EXECS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_CHAIN_EXECS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_CHAIN_EXECUTIONS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_CHAIN_LAST_EXECS_VIEW TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_DEFINITION_HIERARCHY TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_LAST_SIMPLE_LOG TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_PROCESS_EXECUTIONS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_PROCS_LAST_EXECS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_RUNNING_ACTIVITIES TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_RUNNING_CHAINS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_RUNNING_CHAINS2 TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_RUNNING_PROCESSES TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SCHED_CHAINS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SCHED_CHAIN_RULES TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SCHED_CHAIN_STEPS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SCHED_JOBS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SCHED_JOB_DESTS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SCHED_JOB_LOG TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SCHED_JOB_RUN_DETAILS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SCHED_PROGRAMS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SCHED_RUNNING_CHAINS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SCHED_RUNNING_JOBS TO HFOBATCH_USER;
GRANT SELECT ON V_BATCH_SIMPLE_LOG TO HFOBATCH_USER;

-- Grant select permissions on all batch views to DEVELOPER role
GRANT SELECT ON V_BATCH_ACTIVITY_EXECUTIONS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_ACTIVS_LAST_EXECS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_CHAIN_EXECS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_CHAIN_EXECUTIONS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_CHAIN_LAST_EXECS_VIEW TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_DEFINITION_HIERARCHY TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_LAST_SIMPLE_LOG TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_PROCESS_EXECUTIONS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_PROCS_LAST_EXECS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_RUNNING_ACTIVITIES TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_RUNNING_CHAINS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_RUNNING_CHAINS2 TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_RUNNING_PROCESSES TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SCHED_CHAINS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SCHED_CHAIN_RULES TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SCHED_CHAIN_STEPS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SCHED_JOBS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SCHED_JOB_DESTS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SCHED_JOB_LOG TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SCHED_JOB_RUN_DETAILS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SCHED_PROGRAMS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SCHED_RUNNING_CHAINS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SCHED_RUNNING_JOBS TO HFOBATCH_DEVELOPER;
GRANT SELECT ON V_BATCH_SIMPLE_LOG TO HFOBATCH_DEVELOPER;

-- Grant select permissions on all batch tables to USER role
GRANT SELECT ON BATCH_COMPANIES TO HFOBATCH_USER;
GRANT SELECT ON BATCH_CHAINS TO HFOBATCH_USER;
GRANT SELECT ON BATCH_PROCESSES TO HFOBATCH_USER;
GRANT SELECT ON BATCH_ACTIVITIES TO HFOBATCH_USER;
GRANT SELECT ON BATCH_CHAIN_PROCESSES TO HFOBATCH_USER;
GRANT SELECT ON BATCH_PROCESS_ACTIVITIES TO HFOBATCH_USER;
GRANT SELECT ON BATCH_CHAIN_EXECUTIONS TO HFOBATCH_USER;
GRANT SELECT ON BATCH_PROCESS_EXECUTIONS TO HFOBATCH_USER;
GRANT SELECT ON BATCH_ACTIVITY_EXECUTIONS TO HFOBATCH_USER;
GRANT SELECT ON BATCH_ACTIVITY_PARAMETERS TO HFOBATCH_USER;
GRANT SELECT ON BATCH_ACTIV_EXEC_PARAM_VALUES TO HFOBATCH_USER;
GRANT SELECT ON BATCH_PROC_ACTIV_PARAM_VALUES TO HFOBATCH_USER;
GRANT SELECT ON BATCH_ACTIVITY_OUTPUTS TO HFOBATCH_USER;
GRANT SELECT ON BATCH_COMPANY_PARAMETERS TO HFOBATCH_USER;
GRANT SELECT ON BATCH_SIMPLE_LOG TO HFOBATCH_USER;

-- Grant ALL permissions on all batch tables to DEVELOPER role
GRANT ALL ON BATCH_COMPANIES TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_CHAINS TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_PROCESSES TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_ACTIVITIES TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_CHAIN_PROCESSES TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_PROCESS_ACTIVITIES TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_CHAIN_EXECUTIONS TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_PROCESS_EXECUTIONS TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_ACTIVITY_EXECUTIONS TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_ACTIVITY_PARAMETERS TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_ACTIV_EXEC_PARAM_VALUES TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_PROC_ACTIV_PARAM_VALUES TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_ACTIVITY_OUTPUTS TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_COMPANY_PARAMETERS TO HFOBATCH_DEVELOPER;
GRANT ALL ON BATCH_SIMPLE_LOG TO HFOBATCH_DEVELOPER;

-- Grant insert/update permissions for execution tracking to USER role
GRANT INSERT, UPDATE ON BATCH_CHAIN_EXECUTIONS TO HFOBATCH_USER;
GRANT INSERT, UPDATE ON BATCH_PROCESS_EXECUTIONS TO HFOBATCH_USER;
GRANT INSERT, UPDATE ON BATCH_ACTIVITY_EXECUTIONS TO HFOBATCH_USER;
GRANT INSERT, UPDATE ON BATCH_ACTIV_EXEC_PARAM_VALUES TO HFOBATCH_USER;
GRANT INSERT, UPDATE ON BATCH_ACTIVITY_OUTPUTS TO HFOBATCH_USER;
GRANT INSERT ON BATCH_SIMPLE_LOG TO HFOBATCH_USER;

-- Grant sequence usage to both roles
GRANT SELECT ON BATCH_GLOBAL_ID_SEQ TO HFOBATCH_USER;
GRANT SELECT ON BATCH_GLOBAL_ID_SEQ TO HFOBATCH_DEVELOPER;

-- Grant additional development privileges to DEVELOPER role
GRANT CREATE TABLE TO HFOBATCH_DEVELOPER;
GRANT CREATE VIEW TO HFOBATCH_DEVELOPER;
GRANT CREATE SEQUENCE TO HFOBATCH_DEVELOPER;
GRANT CREATE PROCEDURE TO HFOBATCH_DEVELOPER;
GRANT CREATE TRIGGER TO HFOBATCH_DEVELOPER;
GRANT CREATE ANY DIRECTORY TO HFOBATCH_DEVELOPER;
GRANT SELECT ANY DICTIONARY TO HFOBATCH_DEVELOPER;
GRANT SELECT ANY TABLE TO HFOBATCH_DEVELOPER;
GRANT INSERT ANY TABLE TO HFOBATCH_DEVELOPER;
GRANT UPDATE ANY TABLE TO HFOBATCH_DEVELOPER;
GRANT DELETE ANY TABLE TO HFOBATCH_DEVELOPER;

PROMPT Roles and permissions creation completed.
PROMPT

-- =============================================================================
-- DEPLOYMENT COMPLETION
-- =============================================================================
PROMPT =============================================================================
PROMPT HF Oracle Batch - System Deployment Completed Successfully
PROMPT =============================================================================
PROMPT
PROMPT Summary of created objects:
PROMPT - Types: 21 PL/SQL type definitions
PROMPT - Sequences: 1 sequence for ID generation
PROMPT - Tables: 15 tables with constraints, triggers, and indexes
PROMPT - Packages: 12 PL/SQL packages (specifications and bodies)
PROMPT - Views: 24 monitoring and reporting views
PROMPT - Functions: 1 standalone function
PROMPT - Roles: 2 batch management roles
PROMPT
PROMPT Next steps:
PROMPT 1. Configure company parameters in BATCH_COMPANIES
PROMPT 2. Create initial chains, processes, and activities
PROMPT 3. Set up monitoring and reporting
PROMPT 4. Test the system with sample data
PROMPT
PROMPT For detailed documentation, see README.md and SYSTEM_ARCHITECTURE.md
PROMPT ============================================================================= 
