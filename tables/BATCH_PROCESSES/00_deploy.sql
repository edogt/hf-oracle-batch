/**
 * Deploy Script: BATCH_PROCESSES
 * Description: Master deployment script for the table and its associated objects.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * Purpose:
 *   - Deploy the table, constraints, triggers, and indexes in the correct order.
 *   - Ensure a consistent and repeatable deployment process.
 *
 * Usage:
 *   - Execute this script to deploy or redeploy the BATCH_PROCESSES table and related objects.
 */

@01_table.sql
@02_constraints.sql
@03_triggers.sql
@04_indexes.sql 
