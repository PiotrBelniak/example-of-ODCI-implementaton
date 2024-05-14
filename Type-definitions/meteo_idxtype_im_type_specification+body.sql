CREATE OR REPLACE EDITIONABLE TYPE "C##METEO"."METEO_IDXTYPE_IM" IS OBJECT
(curnum NUMBER
,processed_rows NUMBER
,static function ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList) return number
,static function ODCIIndexCreate(ia sys.ODCIIndexInfo,parms VARCHAR2, env sys.ODCIEnv) return number
,static function ODCIIndexDrop(ia sys.ODCIIndexInfo,env sys.ODCIEnv) return number
,static function ODCIIndexInsert(ia sys.ODCIIndexInfo, rid VARCHAR2, newval METEO_T, env sys.ODCIEnv) return number
,static function ODCIIndexInsert(ia sys.ODCIIndexInfo, ridlist sys.ODCIRidList, newvallist METEO_T_VARR, env sys.ODCIEnv) return number
,static function ODCIIndexUpdate(ia sys.ODCIIndexInfo, rid VARCHAR2, oldval METEO_T, newval METEO_T, env sys.ODCIEnv) return number
,static function ODCIIndexDelete(ia sys.ODCIIndexInfo, rid VARCHAR2, oldval METEO_T, env sys.ODCIEnv) return number
,static function ODCIIndexStart(sctx IN OUT meteo_idxtype_im, ia sys.ODCIIndexInfo, pi sys.ODCIPredInfo, qi sys.ODCIQueryInfo, strt NUMBER, stop NUMBER, predval NUMBER, paramval VARCHAR2, startdate TIMESTAMP, enddate TIMESTAMP, env sys.ODCIEnv) return number
,static function ODCIIndexStart(sctx IN OUT meteo_idxtype_im, ia sys.ODCIIndexInfo, pi sys.ODCIPredInfo, qi sys.ODCIQueryInfo, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, predval NUMBER, paramval VARCHAR2, startdate TIMESTAMP, enddate TIMESTAMP, env sys.ODCIEnv) return number
,static function ODCIIndexStart(sctx IN OUT meteo_idxtype_im, ia sys.ODCIIndexInfo, pi sys.ODCIPredInfo, qi sys.ODCIQueryInfo, strt NUMBER, stop NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, startdate TIMESTAMP, enddate TIMESTAMP, env sys.ODCIEnv) return number
,static function ODCIIndexStart(sctx IN OUT meteo_idxtype_im, ia sys.ODCIIndexInfo, pi sys.ODCIPredInfo, qi sys.ODCIQueryInfo, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, startdate TIMESTAMP, enddate TIMESTAMP, env sys.ODCIEnv) return number
,member function ODCIIndexFetch(SELF IN OUT meteo_idxtype_im,nrows IN NUMBER, rids OUT sys.ODCIRidList, env sys.ODCIEnv) return number
,member function ODCIIndexClose(env sys.ODCIEnv) return number
);
/
CREATE OR REPLACE EDITIONABLE TYPE BODY "C##METEO"."METEO_IDXTYPE_IM" IS

    static function ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList) return number
    IS
    BEGIN
        ifclist:=sys.ODCIObjectList(sys.ODCIObject('SYS','ODCIINDEX2'));
        return ODCICOnst.Success;
    END ODCIGetInterfaces;

    static function ODCIIndexCreate(ia sys.ODCIIndexInfo,parms VARCHAR2, env sys.ODCIEnv) return number
    IS
        /*insert_coll meteo_support_types_pack.meteo_index_insert_ntt:=meteo_support_types_pack.meteo_index_insert_ntt();
        temp_coll meteo_support_types_pack.meteo_index_insert_ntt;temporary collection used to append results of bulk collect
        list_of_parameters meteo_support_types_pack.parameters_aat;*/
        readingtimelist meteo_support_types_pack.timestamp_v32767t;
        ridlist sys.ODCIRidList;
        sql_stmt1 VARCHAR2(2000);
        sql_stmt2 VARCHAR2(2000);
    BEGIN
        /*create index table*/
        sql_stmt1:='CREATE TABLE ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab(r ROWID, readingtime TIMESTAMP, position NUMBER, temperature NUMBER(3,1)
                    ,rain_amount NUMBER(3,1),pressure NUMBER(6,2),avg_wind NUMBER(3,1))';
        EXECUTE IMMEDIATE sql_stmt1;

        sql_stmt1:='INSERT INTO ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab SELECT :RR, :RT, ROWNUM, temperature, rain_amount, pressure, avg_wind FROM TABLE(SELECT CAST(P.' || ia.IndexCols(1).ColName || '.Zonereadings AS METEO_REGIONREADINGS_NTT) FROM ' || 
                    ia.IndexCols(1).TableSchema || '.' || ia.IndexCols(1).TableName || ' P WHERE P.ROWID = :RR)';
        sql_stmt2:='SELECT ROWID, tb.reading.readingtime FROM ' || ia.IndexCols(1).TableSchema || '.' || ia.IndexCols(1).TableName || ' tb';
        /*list_of_parameters:=parameter_parser(parms);
        insert_statement_prepare(list_of_parameters,ia,sql_stmt1,sql_stmt2);*/
        EXECUTE IMMEDIATE sql_stmt2 BULK COLLECT INTO ridlist,readingtimelist;

        FOR indx IN ridlist.FIRST..ridlist.LAST LOOP
            EXECUTE IMMEDIATE sql_stmt1 USING ridlist(indx),readingtimelist(indx),ridlist(indx);
        END LOOP;

        return ODCIConst.Success;
    END ODCIIndexCreate;

    static function ODCIIndexDrop(ia sys.ODCIIndexInfo,env sys.ODCIEnv) return number
    IS
        sql_stmt VARCHAR2(2000);
    BEGIN
        sql_stmt:='DROP TABLE ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab';
        EXECUTE IMMEDIATE sql_stmt;
        return ODCIConst.Success;
    END ODCIIndexDrop;

    static function ODCIIndexInsert(ia sys.ODCIIndexInfo, rid VARCHAR2, newval METEO_T, env sys.ODCIEnv) return number
    IS
        sql_stmt VARCHAR2(2000);
        insert_coll meteo_support_types_pack.meteo_index_insert_ntt:=meteo_support_types_pack.meteo_index_insert_ntt();
    BEGIN
        insert_coll.EXTEND(newval.ZoneReadings.COUNT);
        FOR i IN newval.ZoneReadings.FIRST..newval.ZoneReadings.LAST LOOP
            insert_coll(i).r:=rid;
            insert_coll(i).readingtime:=newval.readingtime;
            insert_coll(i).position:=i;
            insert_coll(i).temperature:=newval.ZoneReadings(i).temperature;
            insert_coll(i).rain_amount:=newval.ZoneReadings(i).rain_amount;
            insert_coll(i).pressure:=newval.ZoneReadings(i).pressure;
            insert_coll(i).avg_wind:=newval.ZoneReadings(i).avg_wind;
        END LOOP;
        sql_stmt:='DECLARE insert_coll meteo_support_types_pack.meteo_index_insert_ntt  := :kolekcja;
                    BEGIN
                        FORALL indx IN insert_coll.FIRST..insert_coll.LAST     
                            INSERT INTO ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab VALUES insert_coll(indx);
                    END';
        EXECUTE IMMEDIATE sql_stmt USING insert_coll;        
        return ODCIConst.Success;
    END ODCIIndexInsert;

    static function ODCIIndexInsert(ia sys.ODCIIndexInfo, ridlist sys.ODCIRidList, newvallist METEO_T_VARR, env sys.ODCIEnv) return number
    IS
        sql_stmt VARCHAR2(2000);
        insert_coll meteo_support_types_pack.meteo_index_insert_ntt:=meteo_support_types_pack.meteo_index_insert_ntt();
        temp_coll meteo_support_types_pack.meteo_index_insert_ntt:=meteo_support_types_pack.meteo_index_insert_ntt();
    BEGIN

        FOR varr_indx IN newvallist.FIRST..newvallist.LAST LOOP
            temp_coll.EXTEND(newvallist(varr_indx).ZoneReadings.COUNT);
            FOR i IN newvallist(varr_indx).ZoneReadings.FIRST..newvallist(varr_indx).ZoneReadings.LAST LOOP
                temp_coll(i).r:=ridlist(varr_indx);
                temp_coll(i).readingtime:=newvallist(varr_indx).readingtime;
                temp_coll(i).position:=i;
                temp_coll(i).temperature:=newvallist(varr_indx).ZoneReadings(i).temperature;
                temp_coll(i).rain_amount:=newvallist(varr_indx).ZoneReadings(i).rain_amount;
                temp_coll(i).pressure:=newvallist(varr_indx).ZoneReadings(i).pressure;
                temp_coll(i).avg_wind:=newvallist(varr_indx).ZoneReadings(i).avg_wind;
            END LOOP;
            insert_coll:=insert_coll MULTISET UNION temp_coll;
        END LOOP;
        sql_stmt:='DECLARE insert_coll meteo_support_types_pack.meteo_index_insert_ntt  := :kolekcja;
                    BEGIN
                        FORALL indx IN insert_coll.FIRST..insert_coll.LAST     
                            INSERT INTO ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab VALUES insert_coll(indx);
                    END';
        EXECUTE IMMEDIATE sql_stmt USING insert_coll;        
        return ODCIConst.Success;
    END ODCIIndexInsert;

    static function ODCIIndexUpdate(ia sys.ODCIIndexInfo, rid VARCHAR2, oldval METEO_T, newval METEO_T, env sys.ODCIEnv) return number
    IS
        sql_stmt VARCHAR2(2000);
        insert_coll meteo_support_types_pack.meteo_index_insert_ntt:=meteo_support_types_pack.meteo_index_insert_ntt();
    BEGIN

        sql_stmt:='DELETE FROM ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab WHERE r=:RR';
        EXECUTE IMMEDIATE sql_stmt USING rid;

        insert_coll.EXTEND(newval.ZoneReadings.COUNT);
        FOR i IN newval.ZoneReadings.FIRST..newval.ZoneReadings.LAST LOOP
            insert_coll(i).r:=rid;
            insert_coll(i).readingtime:=newval.readingtime;
            insert_coll(i).position:=i;
            insert_coll(i).temperature:=newval.ZoneReadings(i).temperature;
            insert_coll(i).rain_amount:=newval.ZoneReadings(i).rain_amount;
            insert_coll(i).pressure:=newval.ZoneReadings(i).pressure;
            insert_coll(i).avg_wind:=newval.ZoneReadings(i).avg_wind;
        END LOOP;
        sql_stmt:='DECLARE insert_coll meteo_support_types_pack.meteo_index_insert_ntt  := :kolekcja;
                    BEGIN
                        FORALL indx IN insert_coll.FIRST..insert_coll.LAST     
                            INSERT INTO ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab VALUES insert_coll(indx);
                    END';
        EXECUTE IMMEDIATE sql_stmt USING insert_coll;       
        return ODCIConst.Success;
    END ODCIIndexUpdate;

    static function ODCIIndexDelete(ia sys.ODCIIndexInfo, rid VARCHAR2, oldval METEO_T, env sys.ODCIEnv) return number
    IS
        sql_stmt VARCHAR2(2000);
    BEGIN
        sql_stmt:='DELETE FROM ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab WHERE r=:RR';
        EXECUTE IMMEDIATE sql_stmt USING rid;
        return ODCIConst.Success;
    END ODCIIndexDelete;

    static function ODCIIndexStart(sctx IN OUT meteo_idxtype_im, ia sys.ODCIIndexInfo, pi sys.ODCIPredInfo, qi sys.ODCIQueryInfo, strt NUMBER, stop NUMBER, predval NUMBER, paramval VARCHAR2, startdate TIMESTAMP, enddate TIMESTAMP,env sys.ODCIEnv) return number
    IS
        curnum INTEGER;
        sql_stmt VARCHAR2(2000);
        relop VARCHAR2(2);
    BEGIN
        IF (strt!=1 AND strt!=0) THEN
            RAISE_APPLICATION_ERROR(-20190,'Operators predicate is incorrect');
        END IF;
        IF (stop!=1 AND stop!=0) THEN
            RAISE_APPLICATION_ERROR(-20190,'Operators predicate is incorrect');
        END IF;      
        case pi.ObjectName
            WHEN 'METEO_EQUALS_ONE_PARAM_ANY' THEN
                relop:='=';
            WHEN 'METEO_GREATERTHAN_ONE_PARAM_ANY' THEN
                relop:='>';
            WHEN 'METEO_LESSTHAN_ONE_PARAM_ANY' THEN
                relop:='<';
        END CASE;
        
        sql_stmt:= ' select distinct r from ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab where ' || paramval || ' ' || relop || '  :value';
        IF strt = 0 THEN
            sql_stmt:= ' select distinct r from ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab minus ' || sql_stmt;
        END IF;  
        
        /*CASE 
            WHEN startdate IS NULL AND enddate IS NULL THEN
                sql_stmt:=REPLACE(REPLACE(sql_stmt,' timing_pred1'),' timing_pred2');
            WHEN startdate IS NOT NULL AND enddate IS NULL THEN
                sql_stmt:=REPLACE(REPLACE(sql_stmt,' timing_pred1',' AND readingtime>= TO_TIMESTAMP(''' || startdate || ''')'),' timing_pred2',' WHERE readingtime>= TO_TIMESTAMP(''' || startdate || ''')');
            WHEN startdate IS NULL AND enddate IS NOT NULL THEN
                sql_stmt:=REPLACE(REPLACE(sql_stmt,' timing_pred1',' AND readingtime<= TO_TIMESTAMP(''' || enddate || ''')'),' timing_pred2',' WHERE readingtime<= TO_TIMESTAMP(''' || enddate || ''')');
            WHEN startdate IS NOT NULL AND enddate IS NOT NULL THEN
                sql_stmt:=REPLACE(REPLACE(sql_stmt,' timing_pred1',' AND readingtime BETWEEN TO_TIMESTAMP(''' || startdate || ''') AND TO_TIMESTAMP(''' || enddate || ''')'),' timing_pred2',' WHERE readingtime BETWEEN TO_TIMESTAMP(''' || startdate || ''') AND TO_TIMESTAMP(''' || enddate || ''')');
        END CASE;   */ 
        
        curnum:=dbms_sql.open_cursor;
        dbms_sql.parse(curnum, sql_stmt, dbms_sql.native);
        dbms_sql.bind_variable(curnum, ':value' , predval);
        sctx:=meteo_idxtype_im(curnum,0);
        return ODCIConst.Success;
    END ODCIIndexStart;
    
    static function ODCIIndexStart(sctx IN OUT meteo_idxtype_im, ia sys.ODCIIndexInfo, pi sys.ODCIPredInfo, qi sys.ODCIQueryInfo, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, predval NUMBER, paramval VARCHAR2, startdate TIMESTAMP, enddate TIMESTAMP, env sys.ODCIEnv) return number
    IS
        komorka NUMBER;
        curnum INTEGER;
        sql_stmt VARCHAR2(2000);
        relop VARCHAR2(2);
    BEGIN
        IF (strt!=1 AND strt!=0) THEN
            RAISE_APPLICATION_ERROR(-20190,'Operators predicate is incorrect');
        END IF;
        IF (stop!=1 AND stop!=0) THEN
            RAISE_APPLICATION_ERROR(-20190,'Operators predicate is incorrect');
        END IF;      
        case pi.ObjectName
            WHEN 'METEO_EQUALS_ONE_PARAM_SPEC' THEN
                IF strt = 1 THEN
                    relop:='=';
                ELSE
                    relop:='!=';
                END If;
            WHEN 'METEO_GREATERTHAN_ONE_PARAM_SPEC' THEN
                IF strt = 1 THEN
                    relop:='>';
                ELSE
                    relop:='<=';
                END IF;
            WHEN 'METEO_LESSTHAN_ONE_PARAM_SPEC' THEN
                IF strt = 1 THEN
                    relop:='<';
                ELSE
                    relop:='>=';
                END IF;
        END CASE;
        komorka:=x_cord*10-(10-y_cord);
        sql_stmt:= ' select r from ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab where position = :pozycja and ' || paramval || ' ' || relop || '  :value';
        
        /*CASE 
            WHEN startdate IS NULL AND enddate IS NULL THEN
                sql_stmt:=REPLACE(sql_stmt,' timing_pred1');
            WHEN startdate IS NOT NULL AND enddate IS NULL THEN
                sql_stmt:=REPLACE(sql_stmt,' timing_pred1',' AND readingtime>= TO_TIMESTAMP(''' || startdate || ''')');
            WHEN startdate IS NULL AND enddate IS NOT NULL THEN
                sql_stmt:=REPLACE(sql_stmt,' timing_pred1',' AND readingtime<= TO_TIMESTAMP(''' || enddate || ''')');
            WHEN startdate IS NOT NULL AND enddate IS NOT NULL THEN
                sql_stmt:=REPLACE(sql_stmt,' timing_pred1',' AND readingtime BETWEEN TO_TIMESTAMP(''' || startdate || ''') AND TO_TIMESTAMP(''' || enddate || ''')');
        END CASE; */   
        
        curnum:=dbms_sql.open_cursor;
        dbms_sql.parse(curnum, sql_stmt, dbms_sql.native);
        dbms_sql.bind_variable(curnum, ':value' , predval);
        dbms_sql.bind_variable(curnum, ':pozycja' , komorka);
        sctx:=meteo_idxtype_im(curnum,0);
        return ODCIConst.Success;
    END ODCIIndexStart;
    
    static function ODCIIndexStart(sctx IN OUT meteo_idxtype_im, ia sys.ODCIIndexInfo, pi sys.ODCIPredInfo, qi sys.ODCIQueryInfo, strt NUMBER, stop NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, startdate TIMESTAMP, enddate TIMESTAMP, env sys.ODCIEnv) return number
    IS
        curnum INTEGER;
        sql_stmt VARCHAR2(2000);
        relop VARCHAR2(2);
    BEGIN
        IF (strt!=1 AND strt!=0) THEN
            RAISE_APPLICATION_ERROR(-20190,'Operators predicate is incorrect');
        END IF;
        IF (stop!=1 AND stop!=0) THEN
            RAISE_APPLICATION_ERROR(-20190,'Operators predicate is incorrect');
        END IF;      
        case pi.ObjectName
            WHEN 'METEO_EQUALS_TWO_PARAM_ANY' THEN
                relop:='=';
            WHEN 'METEO_GREATERTHAN_TWO_PARAM_ANY' THEN
                relop:='>';
            WHEN 'METEO_LESSTHAN_TWO_PARAM_ANY' THEN
                relop:='<';
        END CASE;

        sql_stmt:= ' select distinct r from ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab where ' || paramval1 || ' ' || relop ||  '  :value1 AND ' || paramval2 || ' ' || relop ||  '  :value2';
        IF strt = 0 THEN
            sql_stmt:= ' select distinct r from ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab minus ' || sql_stmt;
        END IF;
        
        /*CASE 
            WHEN startdate IS NULL AND enddate IS NULL THEN
                sql_stmt:=REPLACE(REPLACE(sql_stmt,' timing_pred1'),' timing_pred2');
            WHEN startdate IS NOT NULL AND enddate IS NULL THEN
                sql_stmt:=REPLACE(REPLACE(sql_stmt,' timing_pred1',' AND readingtime>= TO_TIMESTAMP(''' || startdate || ''')'),' timing_pred2',' WHERE readingtime>= TO_TIMESTAMP(''' || startdate || ''')');
            WHEN startdate IS NULL AND enddate IS NOT NULL THEN
                sql_stmt:=REPLACE(REPLACE(sql_stmt,' timing_pred1',' AND readingtime<= TO_TIMESTAMP(''' || enddate || ''')'),' timing_pred2',' WHERE readingtime<= TO_TIMESTAMP(''' || enddate || ''')');
            WHEN startdate IS NOT NULL AND enddate IS NOT NULL THEN
                sql_stmt:=REPLACE(REPLACE(sql_stmt,' timing_pred1',' AND readingtime BETWEEN TO_TIMESTAMP(''' || startdate || ''') AND TO_TIMESTAMP(''' || enddate || ''')'),' timing_pred2',' WHERE readingtime BETWEEN TO_TIMESTAMP(''' || startdate || ''') AND TO_TIMESTAMP(''' || enddate || ''')');
        END CASE;  */
        
        curnum:=dbms_sql.open_cursor;
        dbms_sql.parse(curnum, sql_stmt, dbms_sql.native);
        dbms_sql.bind_variable(curnum, ':value1' , predval1);
        dbms_sql.bind_variable(curnum, ':value2' , predval2);
        sctx:=meteo_idxtype_im(curnum,0);
        return ODCIConst.Success;
    END ODCIIndexStart;
    
    static function ODCIIndexStart(sctx IN OUT meteo_idxtype_im, ia sys.ODCIIndexInfo, pi sys.ODCIPredInfo, qi sys.ODCIQueryInfo, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, startdate TIMESTAMP, enddate TIMESTAMP, env sys.ODCIEnv) return number
    IS
        komorka NUMBER;
        curnum INTEGER;
        sql_stmt VARCHAR2(2000);
        relop VARCHAR2(2);
    BEGIN
        IF (strt!=1 AND strt!=0) THEN
            RAISE_APPLICATION_ERROR(-20190,'Operators predicate is incorrect');
        END IF;
        IF (stop!=1 AND stop!=0) THEN
            RAISE_APPLICATION_ERROR(-20190,'Operators predicate is incorrect');
        END IF;      
        case pi.ObjectName
            WHEN 'METEO_EQUALS_TWO_PARAM_SPEC' THEN
                IF strt = 1 THEN
                    relop:='=';
                ELSE
                    relop:='!=';
                END If;
            WHEN 'METEO_GREATERTHAN_TWO_PARAM_SPEC' THEN
                IF strt = 1 THEN
                    relop:='>';
                ELSE
                    relop:='<=';
                END IF;
            WHEN 'METEO_LESSTHAN_TWO_PARAM_SPEC' THEN
                IF strt = 1 THEN
                    relop:='<';
                ELSE
                    relop:='>=';
                END IF;
        END CASE;
        komorka:=x_cord*10-(10-y_cord);
        sql_stmt:= ' select distinct r from ' || ia.IndexSchema || '.' || ia.IndexName || '_indx_tab where position = :pozycja and ' || paramval1 || ' ' || relop ||  '  :value1 AND ' || paramval2 || ' ' || relop ||  '  :value2';
        
        /*CASE 
            WHEN startdate IS NULL AND enddate IS NULL THEN
                sql_stmt:=REPLACE(sql_stmt,' timing_pred1');
            WHEN startdate IS NOT NULL AND enddate IS NULL THEN
                sql_stmt:=REPLACE(sql_stmt,' timing_pred1',' AND readingtime>= TO_TIMESTAMP(''' || startdate || ''')');
            WHEN startdate IS NULL AND enddate IS NOT NULL THEN
                sql_stmt:=REPLACE(sql_stmt,' timing_pred1',' AND readingtime<= TO_TIMESTAMP(''' || enddate || ''')');
            WHEN startdate IS NOT NULL AND enddate IS NOT NULL THEN
                sql_stmt:=REPLACE(sql_stmt,' timing_pred1',' AND readingtime BETWEEN TO_TIMESTAMP(''' || startdate || ''') AND TO_TIMESTAMP(''' || enddate || ''')');
        END CASE;     */
        
        curnum:=dbms_sql.open_cursor;
        dbms_sql.parse(curnum, sql_stmt, dbms_sql.native);
        dbms_sql.bind_variable(curnum, ':value1' , predval1);
        dbms_sql.bind_variable(curnum, ':value2' , predval2);
        sctx:=meteo_idxtype_im(curnum,0);
        return ODCIConst.Success;
    END ODCIIndexStart;
    
    member function ODCIIndexFetch(SELF IN OUT meteo_idxtype_im, nrows IN NUMBER, rids OUT sys.ODCIRidList, env sys.ODCIEnv) return number
    IS
        d INTEGER;
        curnum INTEGER;
        rid_tab DBMS_SQL.VARCHAR2_TABLE;
        rlist SYS.ODCIRIDLIST := SYS.ODCIRIDLIST();
    BEGIN
        curnum:=SELF.curnum;
        IF self.processed_rows = 0 THEN
            dbms_sql.define_array(curnum, 1, rid_tab, nrows, 1);
            d := DBMS_SQL.EXECUTE(curnum);
        END IF;
        d := DBMS_SQL.FETCH_ROWS(curnum);
        rlist.extend(nrows);
        DBMS_SQL.COLUMN_VALUE(curnum, 1, rid_tab);
        for i in 1..d loop
            rlist(i) := rid_tab(i+SELF.processed_rows);
        end loop;
        SELF.processed_rows := SELF.processed_rows + d;
        rids := rlist;
        RETURN ODCICONST.SUCCESS;
    END ODCIIndexFetch;
    
    member function ODCIIndexClose(env sys.ODCIEnv) return number
    IS
        curnum NUMBER;
    BEGIN
        curnum:=SELF.CURNUM;
        dbms_sql.close_cursor(curnum);
        return ODCIConst.Success;
    END ODCIIndexClose;
    
END meteo_idxtype_im;

/
