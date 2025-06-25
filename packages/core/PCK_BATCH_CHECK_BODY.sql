CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_CHECK 

logger  Batch_Logger := new Batch_Logger() ;

procedure process( p_name in varchar2
                  ,p_duration in int default 0)  is

duration_ number ;

begin
    --
    duration_ := abs(p_duration) ;
    --
    if (duration_ = 0) then -- random
        duration_ := round( dbms_random.value(30,120) ) ;
    end if ;
    --
    logger.log( p_name || '  started (' || duration_ || ' seconds)' ) ;
    dbms_lock.sleep(duration_) ;
    logger.log( p_name || '  ended' ) ;
    --
end process ;

end pck_batch_check;

/

GRANT EXECUTE ON PCK_BATCH_CHECK TO USR_BATCH_EXEC;
GRANT EXECUTE ON PCK_BATCH_CHECK TO ROLE_BATCH_MAN;
