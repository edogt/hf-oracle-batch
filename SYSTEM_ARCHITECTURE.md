# System Architecture Documentation

## Copyright Notice

This system architecture documentation and the associated codebase are provided for demonstration purposes only, showcasing the author's software engineering skills and expertise in building complex batch processing systems for enterprise applications.

### Author Information
- **Name:** Eduardo Gutiérrez Tapia
- **Email:** edogt@hotmail.com
- **LinkedIn:** [Eduardo Gutiérrez](https://www.linkedin.com/in/%E2%98%86-eduardo-guti%C3%A9rrez-6706778/)
- **GitHub:** [@edogt](https://github.com/edogt)

> **Note:** Eduardo Gutiérrez Tapia was the sole designer and developer of the PL/SQL core system. A separate .NET presentation layer, based on default forms, was implemented by another developer.

### Purpose
- To demonstrate software engineering capabilities
- To showcase system design and architecture skills
- To serve as a portfolio piece
- To illustrate best practices in batch processing system design
- To demonstrate expertise in enterprise application development

### Usage Restrictions
- This documentation and associated code are NOT authorized for commercial use
- This documentation and associated code are NOT authorized for production deployment
- This documentation and associated code are NOT authorized for redistribution
- This documentation and associated code are NOT authorized for modification without explicit permission

### Intellectual Property
All rights reserved. This documentation and the associated codebase are the intellectual property of Eduardo Gutiérrez Tapia and are protected by copyright law.

**Intellectual Property Disclaimer:**  
This system was developed by Eduardo Gutiérrez Tapia as part of a project for a client company. Intellectual property rights and usage permissions may belong to that company according to applicable contractual agreements. This document and the associated code are presented solely for demonstration and professional portfolio purposes.

---

## Overview
This document provides a comprehensive view of the Batch Management System architecture, including all system objects, their dependencies, and relationships.

## System Components

### 1. Core Types
1. TYP_SCHED_CHAIN_RULES
   - Purpose: Defines rules for chain execution
   - No dependencies

2. TYP_SCHED_CHAIN_STEPS
   - Purpose: Defines steps within a chain
   - No dependencies

3. TYP_SCHED_RUNNING_JOBS
   - Purpose: Tracks running jobs
   - No dependencies

4. TYP_SCHED_RUNNING_JOBS_SET
   - Purpose: Collection of running jobs
   - Depends on: TYP_SCHED_RUNNING_JOBS

5. BATCH_LOGGER
   - Purpose: System-wide logging functionality
   - No dependencies

### 2. Sequences
1. BATCH_GLOBAL_ID_SEQ
   - Purpose: Global ID generation for all system objects
   - Used by: All tables for ID generation

### 3. Core Tables
1. BATCH_COMPANIES
   - Purpose: Company management
   - No dependencies
   - Referenced by:
     - BATCH_CHAINS (company_id)
     - BATCH_PROCESSES (company_id)

2. BATCH_CHAINS
   - Purpose: Chain definitions
   - Depends on: BATCH_COMPANIES
   - Referenced by:
     - BATCH_ACTIVITIES (chain_id)
     - BATCH_CHAIN_EXECUTIONS (chain_id)

3. BATCH_PROCESSES
   - Purpose: Process definitions
   - Depends on: BATCH_COMPANIES
   - Referenced by:
     - BATCH_PROCESS_ACTIVITIES (process_id)
     - BATCH_PROCESS_EXECUTIONS (process_id)

4. BATCH_ACTIVITIES
   - Purpose: Activity definitions
   - Depends on: BATCH_CHAINS
   - Referenced by:
     - BATCH_ACTIVITY_EXECUTIONS (activity_id)

### 4. Execution Tables
1. BATCH_CHAIN_EXECUTIONS
   - Purpose: Tracks chain executions
   - Depends on: BATCH_CHAINS
   - Referenced by:
     - BATCH_PROCESS_EXECUTIONS (chain_exec_id)

2. BATCH_PROCESS_EXECUTIONS
   - Purpose: Tracks process executions
   - Depends on: 
     - BATCH_PROCESSES
     - BATCH_CHAIN_EXECUTIONS
   - Referenced by:
     - BATCH_ACTIVITY_EXECUTIONS (process_exec_id)

3. BATCH_ACTIVITY_EXECUTIONS
   - Purpose: Tracks activity executions
   - Depends on:
     - BATCH_ACTIVITIES
     - BATCH_PROCESS_EXECUTIONS
     - BATCH_PROCESS_ACTIVITIES

4. BATCH_SIMPLE_LOG
   - Purpose: System-wide logging
   - Depends on:
     - BATCH_ACTIVITY_EXECUTIONS
     - BATCH_PROCESS_EXECUTIONS
     - BATCH_CHAIN_EXECUTIONS
     - BATCH_COMPANIES

### 5. Configuration Tables
1. BATCH_ACTIVITY_PARAMETERS
   - Purpose: Activity parameter definitions
   - Depends on: BATCH_ACTIVITIES

2. BATCH_COMPANY_PARAMETERS
   - Purpose: Company-specific parameters
   - Depends on: BATCH_COMPANIES

3. BATCH_PROC_ACTIV_PARAM_VALUES
   - Purpose: Process activity parameter values
   - Depends on:
     - BATCH_PROCESS_ACTIVITIES
     - BATCH_ACTIVITY_PARAMETERS

4. BATCH_ACTIVITY_OUTPUTS
   - Purpose: Activity output definitions
   - Depends on: BATCH_ACTIVITIES

### 6. Core Packages
1. PCK_BATCH_MANAGER
   - Purpose: Main execution management
   - Main dependencies:
     - All execution tables
     - All configuration tables
     - BATCH_COMPANIES
   - Functionality: 
     - Chain execution management
     - Process execution management
     - Activity execution management
     - System-wide logging

2. PCK_BATCH_MONITOR
   - Purpose: System monitoring
   - Main dependencies:
     - All scheduling types
     - Execution tables
   - Functionality:
     - Job monitoring
     - Chain monitoring
     - Process monitoring
     - Activity monitoring

3. PCK_BATCH_TOOLS
   - Purpose: Utility functions
   - Main dependencies:
     - BATCH_GLOBAL_ID_SEQ
     - Core tables
   - Functionality:
     - ID generation
     - JSON handling
     - Common utilities

4. PCK_BATCH_UTILS
   - Purpose: System utilities
   - Main dependencies:
     - Core tables
     - Configuration tables
   - Functionality:
     - Chain creation
     - Process creation
     - Activity creation
     - Parameter management

### 7. Simulation Packages
1. PCK_BATCH_SIM_PROC1_1 to PCK_BATCH_SIM_PROC6_1
   - Purpose: Process simulation
   - Main dependencies:
     - PCK_BATCH_MANAGER
     - BATCH_PROCESSES
     - BATCH_ACTIVITIES
   - Functionality:
     - Process simulation
     - Activity simulation
     - Execution simulation

### 8. Monitoring Views
1. Execution Views
   - V_BATCH_ACTIVITY_EXECUTIONS
   - V_BATCH_CHAIN_EXECUTIONS
   - V_BATCH_PROCESS_EXECUTIONS
   - Purpose: Monitor execution status

2. Last Execution Views
   - V_BATCH_ACTIVS_LAST_EXECS
   - V_BATCH_CHAIN_LAST_EXECS_VIEW
   - V_BATCH_PROCS_LAST_EXECS
   - Purpose: Track latest executions

3. Running Status Views
   - V_BATCH_RUNNING_ACTIVITIES
   - V_BATCH_RUNNING_CHAINS
   - V_BATCH_RUNNING_PROCESSES
   - Purpose: Monitor current executions

4. Scheduling Views
   - V_BATCH_SCHED_CHAINS
   - V_BATCH_SCHED_JOBS
   - V_BATCH_SCHED_PROGRAMS
   - Purpose: Monitor scheduled tasks

### 9. Security
1. Roles
   - ROLE_BATCH_MAN
     - Created in: 00_MASTER_SCRIPT.sql
     - Granted to: USR_BATCH_EXEC
     - Permissions:
       - SELECT on all views
       - EXECUTE on all packages

## System Flow
1. Chain Execution
   - Chain is created/defined
   - Processes are added to chain
   - Activities are added to processes
   - Chain is executed
   - Processes are executed in order
   - Activities are executed within processes

2. Process Execution
   - Process is created/defined
   - Activities are added to process
   - Process is executed
   - Activities are executed in order
   - Results are logged

3. Activity Execution
   - Activity is created/defined
   - Parameters are configured
   - Activity is executed
   - Results are logged
   - Outputs are processed 

## Opportunities for Improvement

1. **Advanced handling of stuck chains:**  
   Implement mechanisms to detect and manage stuck or blocked chains, including the ability to stop, restart, resume, or exclude specific processes or activities. This would increase system resilience and provide operators with better tools for real-time incident management.

2. **Automated testing:**  
   Implement automated tests for PL/SQL packages and database logic to ensure reliability and facilitate future changes.

3. **Leverage JSON capabilities of recent Oracle versions:**  
   Consider upgrading to a more recent version of Oracle Database to use advanced JSON handling features (e.g., JSON_TABLE, native JSON data types, improved indexing), which can simplify code and improve performance.

4. **Enhanced logging and monitoring:**  
   Expand logging capabilities and integrate with modern monitoring tools for better observability.

5. **Security hardening:**  
   Review and improve security practices, such as least-privilege access and auditing.

6. **Continuous Integration and Deployment (CI/CD):**  
   Integrate database scripts into a CI/CD pipeline for automated deployments and version control. 