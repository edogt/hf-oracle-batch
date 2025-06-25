CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_MGR_REPORT AS

reportserver_gateway varchar2(100) := 'http://192.168.51.36/cgi-bin/rwcgi60.exe/runp' ;

XSL_DIRECTORY           constant varchar2(30) := 'BATCH_XSL_DIRECTORY' ;
ENVIRONMENT_FILE_NAME   constant varchar2(30) := 'environment.json' ;
--

RS_STRINGCONNECTION       varchar2(50) :=  'timedev/timedes1@basedatos' ;


--

environmentMap      pck_batch_tools.simpleMap_type ;

procedure set_gateway(gateway in varchar2) is
begin
    --
    reportserver_gateway := gateway ;

end ;

function get_new_report_param_list( p_report_name in varchar2,
                                    p_desname in varchar2,
                                    p_destype in varchar2 default 'FILE',
                                    p_desformat in varchar2 default 'PDF') return srw_paramlist as

parameterList srw_paramlist ;

begin
    --
    parameterList := srw_paramlist(srw_parameter('','')) ;
    --
    srw.add_parameter(parameterList,'GATEWAY',pck_batch_manager.REPORTSERVER_GATEWAY) ;

    --srw.add_parameter(parameterList,'SERVER','Rep60_ROBOT2') ;
    srw.add_parameter(parameterList,'REPORT',p_report_name) ;
    srw.add_parameter(parameterList,'DESNAME',p_desname) ;
    srw.add_parameter(parameterList,'DESTYPE',p_destype) ;
    srw.add_parameter(parameterList,'DESFORMAT',p_desformat) ;

    srw.add_parameter(parameterList,'USERID',RS_STRINGCONNECTION) ;
    --
    return parameterList ;
    --
end get_new_report_param_list ;


function run_report(    parametersList in srw_paramlist, -- parametros que definen la ejecuci�n del reporte
                        exec_id in number default null, -- id de la ejecuci�n desde la que est� siendo invocado
                        message in varchar2 default null -- mensaje para incluir como referencia en BATCH_SIMPLE_LOG (ej. titulo)
                    ) return srw.job_ident is
jobIdent srw.job_ident ;
logger Batch_Logger ;
begin
    --
    logger := new Batch_Logger(exec_id) ;
    --
    logger.log(' generando archivo ' || message || ' (' || srw.getParameterValue(parametersList,'DESNAME') || ') generado' ) ;
    jobIdent := srw.run_report(parametersList) ;
    logger.log('archivo ' || message || ' (' || srw.getParameterValue(parametersList,'DESNAME') || ') generado' ) ;
    return jobIdent ;
    --
exception
    when others then
        --
        if ( sqlcode != -31011) then
            logger.log('ERROR :' || sqlcode || ' : ' || sqlerrm, dbms_utility.format_error_backtrace) ;
            raise ;
        end if ;
        --
        logger.log('archivo ' || message || ' (' || srw.getParameterValue(parametersList,'DESNAME') || ') generado' ) ;
        return null ;
        --
end run_report ;



function getTimestampedName( p_desname in varchar2, p_destype in varchar2 default 'pdf' ) return varchar2 is
begin
    --
    return p_desname || to_char(sysdate, '.yyyy-mm-dd_hh24-mi-ss.') || p_destype ;
    --
end ;


begin
    --
    environmentMap := pck_batch_tools.getSimpleMapFromSimpleJSON(
                                            DBMS_XslProcessor.read2clob(
                                                                XSL_DIRECTORY,
                                                                ENVIRONMENT_FILE_NAME)) ;
    --
    RS_STRINGCONNECTION := environmentMap('RS_STRINGCONNECTION') ;
    --
end  ;


/

  GRANT EXECUTE ON PCK_BATCH_MGR_REPORT TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_MGR_REPORT TO ROLE_BATCH_MAN;
