CREATE OR REPLACE EDITIONABLE PACKAGE BODY PCK_BATCH_TOOLS AS

XSL_DIRECTORY constant varchar2(30) := 'BATCH_XSL_DIRECTORY' ;

function procXSL(   pxml     in clob, pxslName in varchar2 ) return clob is
  -- Author : edogt (edogt@hotmail.com)

parser       DBMS_XMLParser.parser ;
xslProcessor DBMS_XslProcessor.Processor ;
--
auxClob clob ;
--
domdocument DBMS_XmlDom.DOMDocument ;
rootnode    DBMS_XmlDom.DOMNode ;
--
styleSheet     DBMS_XslProcessor.StyleSheet ;
styleSheetText clob ;

begin
    --
    parser := DBMS_XMLParser.newParser ;
    --
    domdocument := DBMS_XmlDom.newDOMDocument(pxml) ;
    rootnode    := DBMS_XmlDom.makeNode(DBMS_XmlDom.getDocumentElement(domdocument)) ;
    --
    styleSheetText := DBMS_XslProcessor.read2clob(XSL_DIRECTORY, pxslName) ;
    --
    DBMS_XMLParser.parseBuffer(parser, styleSheetText) ;
    styleSheet   := DBMS_XslProcessor.newStylesheet(DBMS_XMLParser.getDocument(parser), '') ;
    xslProcessor := DBMS_XslProcessor.newProcessor() ;
    --
    DBMS_Lob.createtemporary(auxClob, true) ;
    DBMS_XslProcessor.processXSL(p      => xslProcessor
                                ,ss     => styleSheet
                                ,xmldoc => domdocument
                                ,cl     => auxClob) ;
    --
    auxClob := replace(auxClob, ';', '''') ;
    auxClob := replace(auxClob, ';', '>') ;
    auxClob := replace(auxClob, ';', '<') ;
    auxClob := replace(auxClob, ';', '"');
    --
    begin
        --
        DBMS_XmlDom.freeNode(rootnode);
        DBMS_XmlDom.freeDocument(domdocument);
        DBMS_XMLParser.freeParser(parser);
        --
    end;
    --
    return(auxClob);
    --
end procXSL;

function replacePath(path_string in varchar2) return varchar2 is
begin
    --
    return(replace(trim(leading '\' from path_string), '\', '-')) ;

    --
end ;

function enlapsedTimeString(start_time in timestamp, end_time in timestamp) return varchar2 is
interval interval day to second ;
begin
    --
    interval := end_time - start_time ;
    --
    return extract(day from interval) || ':' ||
            lpad(extract(hour from interval),2,'0')  || ':' ||
            lpad(extract(minute from interval),2,'0')  || ':' ||
            lpad(trunc(extract(second from interval)), 2, '0') ;
    --
end ;


function getProcedureFullName(p_owner in varchar2, p_name in varchar2, lineNumber in number) return varchar2 is

text_ varchar2(500) ;
xpos    number ;
begin
    --
    begin
        --
        select upper(text)
        into text_
        from (     select text
                from v_batch_activities_source
                where ( upper(text) like '%PROCEDURE%' or upper(text) like '%FUNCTION%' )
                    and line < lineNumber
                    and owner = upper(p_owner)
                    and name = upper(p_name)
                    and type = 'PACKAGE BODY'
                order by line desc )
        where rownum < 2 ;
        --
    exception
        when others then
            --pck_batch_mgr_log.log(p_owner || '-' || p_name || '-' || lineNumber ) ;

            raise ;
    end ;


    --
  --      return '*' || text_ ;
    --
    text_ := replace(text_, 'FUNCTION', ' ') ;
    text_ := replace(text_, 'PROCEDURE', ' ') ;
    text_ := trim(text_) ;
    --
 --   return text_ ;
    --

    xpos := instr(text_, '(') ;
    if (xpos = 0) then
        xpos := instr(text_, ' ') ;
        if (xpos = 0) then
            xpos := instr(text_, ';') ;
            if (xpos = 0) then
                xpos := instr(text_, chr(10)) ;
                if (xpos = 0) then
                    xpos := instr(text_, chr(10)) ;
                    if (xpos = 0) then
                        return text_ ;
                    end if ;
                end if ;
            end if ;
        end if ;
    end if ;
    --
    return p_name || '.' || trim(substr(text_, 1, xpos-1)) ;
    --
end ;





function split( string in varchar2,
                delimiter in varchar2 default ',',
                trimed in boolean default false -- not implemented
                ) return tabmaxv2_type  as

  string_splitted tabmaxv2_type := tabmaxv2_type();

  pos pls_integer := 0 ;

  list_ varchar2(32767) := string ;

  index_ binary_integer := 0 ;

begin
    --
    loop
        --
        pos := instr(list_, delimiter) ;
        --
        if pos > 0 then

            -- string_splitted(index_) := substr(list_, 1, pos - 1) ;

            string_splitted.extend(1) ;
            string_splitted(string_splitted.last) := substr(list_, 1, pos - 1) ;
            list_ := substr(list_, pos + length(delimiter)) ;
        else

            -- string_splitted(index_) := list_ ;

            string_splitted.extend(1) ;
            string_splitted(string_splitted.last) := list_ ;
            return string_splitted ;
        end if ;
        --
    end loop ;
    --
end split ;

function getNewId return number is

newId number ;

begin
    --
    select BATCH_GLOBAL_ID_SEQ.nextval into newId from dual ;
    return newId ;
    --
end getNewId ;


function surround(text in varchar2, chars in varchar2 default '''') return string is
begin
    --
    return chars || text || chars ;
    --
end ;


procedure addLine(text_var in out varchar2, text varchar2) is
lf char(1) := chr(10) ;
begin
    --
    text_var := text_var || text || lf ;
    --
end ;

function clean(text in varchar2) return varchar2 is
begin
    --
    return replace(replace(replace(text,chr(10),null),chr(13),null),'"',null) ;
    --
end ;


function getJSONFromSimpleMap(simple_map simpleMap_type) return varchar2 is

    return_text varchar2(4000) ;
    lf varchar2(2) := chr(10) || chr(13) ;
    index_ varchar2(100) ;

begin
    --
    addLine(return_text, '{') ;
    --
    index_ := simple_map.first ;
    while (index_ is not null) loop
        --
        addLine(return_text, '"' || index_ || '" : "' || simple_map(index_) || '",' ) ;
        index_ := simple_map.next(index_);
        --
    end loop ;
    --
    return_text := substr(return_text, 1, length(return_text)-2) || lf ;
    --
    addLine(return_text, ' }') ;
    --
    return return_text ;
    --
end ;

function getSimpleMapFromSimpleJSON(simpleJSON in varchar2) return simpleMap_type is
--
string_     varchar2(4000) ;
name_       varchar2(30) ;
value_      varchar2(500) ;
--
simpleMap   simpleMap_type ;
--
keyValuePattern     varchar2(100) := '"[^"]+"\s*:\s*"[^"]+"' ;
keyPattern          varchar2(100) := '"[^"]+"' ;
--
ocurr   number := 1 ;

begin
    --
    string_ := regexp_substr(simpleJSON, keyValuePattern, 1, ocurr) ;
    while (string_ is not null) loop
        --
        name_   := upper(replace(regexp_substr(string_, keyPattern,1,1),'"',null)) ;
        value_  := replace(regexp_substr(string_, keyPattern,1,2),'"',null) ;
        simpleMap(name_) := value_ ;
        --
        ocurr := ocurr + 1 ;
        string_ := regexp_substr(simpleJSON, keyValuePattern, 1, ocurr) ;
        --
    end loop ;
    --
    return simpleMap ;
    --
end ;


function getValueFromSimpleJSON(simpleJSON in varchar2, keyName in varchar2) return varchar2 is
simpleMap simpleMap_type ;
begin
    --
    simpleMap := getSimpleMapFromSimpleJSON(simpleJSON) ;
    return simpleMap(upper(keyname)) ;
    --
exception
    when others then
        return null ;
end ;


function getSimpleMapFromV2List( V2List in pck_batch_tools.TabMaxV2_type ) return pck_batch_tools.SimpleMap_type is

simpleMap pck_batch_tools.SimpleMap_type ;

indx    binary_integer ;

begin
    --
    indx:= V2List.first() ;
    while ( indx is not null ) loop
        --
        simpleMap(V2List(indx)) := V2List(indx) ;
        --
        --
        indx:= V2List.next(indx) ;
        --
    end loop ;
    --
    return simpleMap ;
    --
exception
    when others then
        raise ;
end getSimpleMapFromV2List ;



function getProcedureArguments(p_package_name in varchar2, p_procedure_name in varchar2) return procArgumentsList_type is

argList procArgumentsList_type ;

begin
    --
    select * bulk collect
      into argList
      from all_arguments
     where (1=1)
       and data_level = 0
       and package_name = p_package_name
       and object_name = p_procedure_name ;
    --
    --
    return argList ;
    --
end ;

function getSysContextSimpleMap return simpleMap_type is

contextMap simpleMap_type ;

begin
    --
    contextMap('SESSIONID')       := sys_context('USERENV', 'SESSIONID') ;
    contextMap('SESSION_USER')    := sys_context('USERENV', 'SESSION_USER') ;
    contextMap('DB_NAME')         := sys_context('USERENV', 'DB_NAME')  ;
    contextMap('HOST')            := sys_context('USERENV', 'HOST') ;
    contextMap('IP_ADDRESS')      := sys_context('USERENV', 'IP_ADDRESS') ;
    contextMap('OS_USER')         := sys_context('USERENV', 'OS_USER') ;
    contextMap('SERVER_HOST')     := sys_context('USERENV', 'SERVER_HOST') ;
    --
    return contextMap ;
    --
end ;


function getSysContextJSON return varchar2 is
begin
    --
    return getJSONFromSimpleMap(getSysContextSimpleMap) ;
    --
end ;

end PCK_BATCH_TOOLS ;



/

  GRANT EXECUTE ON PCK_BATCH_TOOLS TO USR_BATCH_EXEC;
  GRANT EXECUTE ON PCK_BATCH_TOOLS TO ROLE_HF_BATCH;
