-- Deploy Script: BATCH_ACTIVITY_EXECUTIONS
-- Purpose: Orchestrates the creation of the table, constraints, triggers, and indexes in the correct order for BATCH_ACTIVITY_EXECUTIONS.
-- Dependencies:
--   - Requires BATCH_ACTIVITIES and BATCH_CHAIN_EXECUTIONS tables
--   - Must be executed after parent tables and sequences are created
-- Execution Order: Table -> Constraints -> Triggers -> Indexes

@01_table.sql
@02_constraints.sql
@03_triggers.sql
@04_indexes.sql

-- Verification
SELECT table_name, status FROM user_tables WHERE table_name = 'BATCH_ACTIVITY_EXECUTIONS';
SELECT constraint_name, constraint_type FROM user_constraints WHERE table_name = 'BATCH_ACTIVITY_EXECUTIONS';
SELECT trigger_name, status FROM user_triggers WHERE table_name = 'BATCH_ACTIVITY_EXECUTIONS';
SELECT index_name, uniqueness FROM user_indexes WHERE table_name = 'BATCH_ACTIVITY_EXECUTIONS'; 
