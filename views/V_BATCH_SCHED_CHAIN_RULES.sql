/**
 * View: V_BATCH_SCHED_CHAIN_RULES
 * Description: Oracle Scheduler chain rules monitoring view.
 *              Provides information about chain execution rules including
 *              conditions, actions, and configurations for chain control.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Monitor Oracle Scheduler chain execution rules
 *   - Provide rule-based chain control information
 *   - Support chain rule analysis and troubleshooting
 *   - Enable chain execution flow control analysis
 *
 * Query Description:
 *   - Uses PCK_BATCH_MONITOR.GET_SCHED_CHAIN_RULES function to retrieve chain rules
 *   - Provides rule conditions, actions, and configuration details
 *   - Enables chain execution flow control analysis
 *   - Supports chain rule troubleshooting and optimization
 *
 * Usage Examples:
 * 
 * -- Get all chain rules
 * SELECT * FROM V_BATCH_SCHED_CHAIN_RULES 
 * ORDER BY CHAIN_NAME, RULE_NAME;
 *
 * -- Get rules for a specific chain
 * SELECT * FROM V_BATCH_SCHED_CHAIN_RULES 
 * WHERE CHAIN_NAME = 'DAILY_PROCESSING_CHAIN'
 * ORDER BY RULE_NAME;
 *
 * -- Get rules by action type
 * SELECT ACTION, COUNT(*) as rule_count,
 *        COUNT(DISTINCT CHAIN_NAME) as unique_chains
 * FROM V_BATCH_SCHED_CHAIN_RULES 
 * GROUP BY ACTION
 * ORDER BY rule_count DESC;
 *
 * -- Get chains with many rules (> 3 rules)
 * SELECT CHAIN_NAME, COUNT(*) as rule_count
 * FROM V_BATCH_SCHED_CHAIN_RULES 
 * GROUP BY CHAIN_NAME
 * HAVING COUNT(*) > 3
 * ORDER BY rule_count DESC;
 *
 * -- Get rules with specific conditions
 * SELECT * FROM V_BATCH_SCHED_CHAIN_RULES 
 * WHERE CONDITION LIKE '%SUCCESS%'
 * ORDER BY CHAIN_NAME, RULE_NAME;
 *
 * -- Get rule owner analysis
 * SELECT RULE_OWNER, COUNT(*) as rule_count,
 *        COUNT(DISTINCT CHAIN_NAME) as unique_chains
 * FROM V_BATCH_SCHED_CHAIN_RULES 
 * GROUP BY RULE_OWNER
 * ORDER BY rule_count DESC;
 *
 * Related Objects:
 * - Packages: PCK_BATCH_MONITOR (GET_SCHED_CHAIN_RULES function)
 * - Types: TYP_SCHED_CHAIN_RULES, TYP_SCHED_CHAIN_RULES_SET
 * - Views: V_BATCH_SCHED_CHAINS, V_BATCH_SCHED_CHAIN_STEPS
 * - Tables: BATCH_SCHED_CHAIN_RULES, BATCH_SCHEDULER_JOBS
 */

--------------------------------------------------------
--  DDL for View V_BATCH_SCHED_CHAIN_RULES
--------------------------------------------------------

CREATE OR REPLACE FORCE EDITIONABLE VIEW V_BATCH_SCHED_CHAIN_RULES (
    CHAIN_NAME,            -- Oracle Scheduler chain name
    RULE_OWNER,            -- Owner of the rule
    RULE_NAME,             -- Name of the rule
    CONDITION,             -- Rule condition expression
    ACTION,                -- Action to take when condition is met
    COMMENTS               -- Additional comments and notes
) AS
select CHAIN_NAME, RULE_OWNER, RULE_NAME, CONDITION, ACTION, COMMENTS 
from table(PCK_BATCH_MONITOR.get_sched_chain_rules)
;
GRANT SELECT ON V_BATCH_SCHED_CHAIN_RULES TO ROLE_BATCH_MAN;
