/**
 * View: V_BATCH_CHAIN_EXECS
 * Description: Simple view of all chain executions for monitoring and reporting.
 *              Provides direct access to chain execution records for analysis,
 *              troubleshooting y auditoría.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Proveer acceso directo a todas las ejecuciones de cadenas
 *   - Soportar análisis de ejecuciones, troubleshooting y reporting
 *   - Permitir auditoría y trazabilidad de ejecuciones
 *   - Facilitar queries simples sobre ejecuciones de cadenas
 *
 * Query Description:
 *   - Acceso directo a BATCH_CHAIN_EXECUTIONS sin joins
 *   - Incluye los campos principales de ejecución de cadena
 *   - Ordena por ID descendente para mostrar las ejecuciones más recientes primero
 *
 * Usage Examples:
 * 
 * -- Obtener todas las ejecuciones de cadenas
 * SELECT * FROM V_BATCH_CHAIN_EXECS;
 *
 * -- Obtener ejecuciones recientes
 * SELECT * FROM V_BATCH_CHAIN_EXECS WHERE START_TIME > SYSTIMESTAMP - INTERVAL '1' DAY;
 *
 * -- Obtener ejecuciones completadas
 * SELECT * FROM V_BATCH_CHAIN_EXECS WHERE STATE = 'COMPLETED';
 *
 * -- Obtener ejecuciones por tipo
 * SELECT EXECUTION_TYPE, COUNT(*) FROM V_BATCH_CHAIN_EXECS GROUP BY EXECUTION_TYPE;
 *
 * -- Obtener comentarios de ejecuciones fallidas
 * SELECT COMMENTS FROM V_BATCH_CHAIN_EXECS WHERE STATE = 'FAILED';
 *
 * Related Objects:
 * - Tables: BATCH_CHAIN_EXECUTIONS
 * - Views: V_BATCH_CHAIN_LAST_EXECS_VIEW, V_BATCH_RUNNING_CHAINS
 * - Packages: PCK_BATCH_MGR_CHAINS
 */

--------------------------------------------------------
--  DDL for View V_BATCH_CHAIN_EXECS
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_CHAIN_EXECS (
    ID,                -- Identificador único de ejecución
    START_TIME,        -- Timestamp de inicio de ejecución
    END_TIME,          -- Timestamp de fin de ejecución
    COMMENTS,          -- Comentarios de la ejecución
    STATE,             -- Estado actual de la ejecución
    CHAIN_ID,          -- Referencia a la cadena ejecutada
    EXECUTION_TYPE     -- Tipo de ejecución (MANUAL, SCHEDULED, etc.)
) AS
select chainexec.id,
       chainexec.start_time,
       chainexec.end_time,
       chainexec.comments,
       chainexec.state,
       chainexec.chain_id,
       chainexec.execution_type
from BATCH_CHAIN_EXECUTIONS chainexec
order by 1 desc
;
GRANT SELECT ON V_BATCH_CHAIN_EXECS TO ROLE_BATCH_MAN;
