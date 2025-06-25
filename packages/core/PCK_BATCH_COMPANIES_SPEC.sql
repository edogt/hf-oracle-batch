/**
 * Package: PCK_BATCH_COMPANIES
 * Description: Functions for batch company management.
 *
 * Author: Eduardo Gutiérrez Tapia (edogt@hotmail.com)
 *
 * For detailed documentation and usage examples, refer to SYSTEM_ARCHITECTURE.md.
 */

CREATE OR REPLACE EDITIONABLE PACKAGE PCK_BATCH_COMPANIES as 
/**
 * Package: PCK_BATCH_COMPANIES
 * Description: Functions for batch company management.
 *
 * Author: Eduardo Gutiérrez Tapia
 * Contact: edogt@hotmail.com
 *
 * For detailed documentation and usage examples, refer to SYSTEM_ARCHITECTURE.md.
 */


/**
 * Function: getHomeCompany
 * Description: Returns the home company information.
 * Purpose: Used to get the home company information.
 *
 * Example:
 *   BATCH_COMPANIES%rowtype homeCompany := PCK_BATCH_COMPANIES.getHomeCompany();  
 *
 * Returns:
 *   BATCH_COMPANIES%rowtype
 *
 * Notes:
 *   - The home company is the company that is used as the default company.
 **/
function getHomeCompany return BATCH_COMPANIES%rowtype ;

end pck_batch_companies ;

/
