/**
 * View: V_BATCH_DEFINITION_HIERARCHY
 * Description: Hierarchical view of batch system definition structure.
 *              Provides a tree-like representation of the batch system hierarchy
 *              from companies down to activities for navigation and reporting purposes.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Display hierarchical structure of batch system components
 *   - Provide navigation tree for batch system management
 *   - Support hierarchical reporting and analysis
 *   - Enable parent-child relationship visualization
 *
 * Query Description:
 *   - Uses UNION to combine four hierarchical levels: Companies, Chains, Processes, Activities
 *   - Each level includes parent-child relationships and company context
 *   - Provides formatted names for each hierarchy level
 *   - Enables tree navigation and hierarchical queries
 *
 * Usage Examples:
 * 
 * -- Get complete hierarchy tree
 * SELECT * FROM V_BATCH_DEFINITION_HIERARCHY 
 * ORDER BY COMPANY_ID, PARENTID, NOMBRE;
 *
 * -- Get hierarchy for a specific company
 * SELECT * FROM V_BATCH_DEFINITION_HIERARCHY 
 * WHERE COMPANY_ID = 1
 * ORDER BY PARENTID, NOMBRE;
 *
 * -- Get all chains (level 2)
 * SELECT * FROM V_BATCH_DEFINITION_HIERARCHY 
 * WHERE PARENTID IS NOT NULL 
 * AND NOMBRE LIKE 'CHAIN%'
 * ORDER BY NOMBRE;
 *
 * -- Get all processes for a specific chain
 * SELECT * FROM V_BATCH_DEFINITION_HIERARCHY 
 * WHERE PARENTID = (SELECT ID FROM BATCH_CHAINS WHERE CODE = 'CHAIN001')
 * AND NOMBRE LIKE 'PROCESS%'
 * ORDER BY NOMBRE;
 *
 * -- Get hierarchy depth analysis
 * SELECT 
 *   CASE 
 *     WHEN PARENTID IS NULL THEN 'Company'
 *     WHEN NOMBRE LIKE 'CHAIN%' THEN 'Chain'
 *     WHEN NOMBRE LIKE 'PROCESS%' THEN 'Process'
 *     WHEN NOMBRE LIKE 'ACTIVITY%' THEN 'Activity'
 *   END as level_type,
 *   COUNT(*) as count
 * FROM V_BATCH_DEFINITION_HIERARCHY 
 * GROUP BY 
 *   CASE 
 *     WHEN PARENTID IS NULL THEN 'Company'
 *     WHEN NOMBRE LIKE 'CHAIN%' THEN 'Chain'
 *     WHEN NOMBRE LIKE 'PROCESS%' THEN 'Process'
 *     WHEN NOMBRE LIKE 'ACTIVITY%' THEN 'Activity'
 *   END
 * ORDER BY 
 *   CASE level_type
 *     WHEN 'Company' THEN 1
 *     WHEN 'Chain' THEN 2
 *     WHEN 'Process' THEN 3
 *     WHEN 'Activity' THEN 4
 *   END;
 *
 * -- Get activities with their full path
 * SELECT 
 *   h1.NOMBRE as company_name,
 *   h2.NOMBRE as chain_name,
 *   h3.NOMBRE as process_name,
 *   h4.NOMBRE as activity_name
 * FROM V_BATCH_DEFINITION_HIERARCHY h1
 * LEFT JOIN V_BATCH_DEFINITION_HIERARCHY h2 ON h2.PARENTID = h1.ID
 * LEFT JOIN V_BATCH_DEFINITION_HIERARCHY h3 ON h3.PARENTID = h2.ID
 * LEFT JOIN V_BATCH_DEFINITION_HIERARCHY h4 ON h4.PARENTID = h3.ID
 * WHERE h1.PARENTID IS NULL
 * AND h4.NOMBRE LIKE 'ACTIVITY%'
 * ORDER BY h1.NOMBRE, h2.NOMBRE, h3.NOMBRE, h4.NOMBRE;
 *
 * Related Objects:
 * - Tables: BATCH_COMPANIES, BATCH_CHAINS, BATCH_CHAIN_PROCESSES
 * - Tables: BATCH_PROCESSES, BATCH_PROCESS_ACTIVITIES, BATCH_ACTIVITIES
 * - Views: V_BATCH_ACTIVITY_EXECUTIONS, V_BATCH_PROCESS_EXECUTIONS
 * - Packages: PCK_BATCH_MGR_CHAINS, PCK_BATCH_MGR_PROCESSES, PCK_BATCH_MGR_ACTIVITIES
 */

--------------------------------------------------------
--  DDL for View V_BATCH_DEFINITION_HIERARCHY
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_DEFINITION_HIERARCHY (
    ID,                    -- Unique identifier for each hierarchy node
    PARENTID,              -- Parent node identifier (null for root level)
    NOMBRE,                -- Formatted name for display and navigation
    COMPANY_ID             -- Company identifier for filtering and grouping
) AS
select
    id,
    null as parentId,
    'CIA ' || name as Nombre,
    id as company_id
from
    batch_companies
union
select
    id,
    company_id parentId,
    'CHAIN ' || name as Nombre,
    company_id
from
    batch_chains
union
select
    cp.id,
    cp.chain_id as parentId,
    'PROCESS ' || p.name as Nombre,
    p.company_id
from
    batch_chain_processes cp
    join batch_processes p on cp.process_id = p.id
union
select
    pa.id*100000+cp.id as Id,
    cp.id as parentId,
    'ACTIVITY ' || a.code||' - '||a.name||'('||pa.name||')' as Nombre,
    a.company_id
from
    batch_process_activities pa
    join batch_chain_processes cp on pa.process_id = cp.process_id
    join batch_activities a on pa.activity_id = a.id
;

GRANT SELECT ON V_BATCH_DEFINITION_HIERARCHY TO ROLE_BATCH_MAN;
