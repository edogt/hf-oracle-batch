CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_SIM AS


logger  Batch_Logger := new Batch_Logger() ;



procedure log(text in varchar2) is
begin
    logger.log(text) ;
    dbms_output.put_line(text) ;
end ;


procedure activity( p_name in varchar2 default 'unknown'
                  ,p_duration in int default 0)  is

duration_ number ;

begin
    --
    duration_ := abs(round(p_duration)) ;
    --
    if (duration_ = 0) then -- random
        duration_ := round( dbms_random.value(MIN_DURATION,MAX_DURATION) ) ;
    elsif (duration_ < MIN_DURATION) then   
        duration_ := MIN_DURATION ;
    elsif (duration_ > MAX_DURATION) then    
        duration_ := MAX_DURATION ;
    end if ;
    --
    logger.log( p_name || '  started (' || duration_ || ' seconds)' ) ;
    dbms_lock.sleep(duration_) ;
    logger.log( p_name || '  ended' ) ;
    --
end activity ;




end pck_batch_sim;

/

GRANT EXECUTE ON PCK_BATCH_SIM TO USR_BATCH_EXEC;
GRANT EXECUTE ON PCK_BATCH_SIM TO ROLE_BATCH_MAN;
