CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_COMPANIES as

logger Batch_Logger ;

function getHomeCompany return BATCH_COMPANIES%rowtype  is

homeCompany BATCH_COMPANIES%rowtype ;

begin
    --
    select *
    into homeCompany
    from BATCH_COMPANIES
    where code = 'HOME' ;
    --
    return homeCompany ;
    --
exception
    when others then
        logger.log(sqlerrm, dbms_utility.format_error_backtrace) ;
        raise ;
end getHomeCompany ;


begin
    --
    logger := new Batch_Logger() ;
    --
end pck_batch_companies ;

/
