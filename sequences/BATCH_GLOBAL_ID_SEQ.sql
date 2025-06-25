/**
 * Sequence: BATCH_GLOBAL_ID_SEQ
 * Description: Global identifier sequence for all entities in the HF Oracle Batch system.
 *              Provides a centralized, chronologically ordered source of unique identifiers
 *              for all batch management entities including chains, processes, activities,
 *              executions, and log entries.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Single source of truth for all entity identifiers across the system
 *   - Natural chronological ordering of entities for audit and tracking
 *   - Ensures uniqueness across all batch management tables
 *   - Supports distributed and concurrent batch operations
 *
 * Usage Examples:
 * 
 * -- Get next sequence value for new entity
 * SELECT BATCH_GLOBAL_ID_SEQ.NEXTVAL FROM DUAL;
 *
 * -- Use in INSERT statements
 * INSERT INTO BATCH_CHAINS (id, code, name) 
 * VALUES (BATCH_GLOBAL_ID_SEQ.NEXTVAL, 'CHAIN001', 'Daily Processing');
 *
 * -- Use in PL/SQL for new entities
 * DECLARE
 *   new_id NUMBER;
 * BEGIN
 *   new_id := BATCH_GLOBAL_ID_SEQ.NEXTVAL;
 *   INSERT INTO BATCH_PROCESSES (id, code, name) 
 *   VALUES (new_id, 'PROC001', 'Data Extraction');
 * END;
 *
 * -- Check current sequence value
 * SELECT BATCH_GLOBAL_ID_SEQ.CURRVAL FROM DUAL;
 *
 * Related Objects:
 * - Tables: All BATCH_* tables use this sequence for ID generation
 * - Packages: PCK_BATCH_TOOLS.GETNEWID function uses this sequence
 * - Views: All views reference entities with IDs from this sequence
 */

--------------------------------------------------------
--  DDL for Sequence BATCH_GLOBAL_ID_SEQ
--------------------------------------------------------

CREATE SEQUENCE BATCH_GLOBAL_ID_SEQ 
MINVALUE 1 
MAXVALUE 999999999999999999999999999 
INCREMENT BY 1 
START WITH 2790346 
CACHE 20 
NOORDER 
NOCYCLE;

-- Grant access to batch management role
GRANT SELECT ON BATCH_GLOBAL_ID_SEQ TO "ROLE_BATCH_MAN";
