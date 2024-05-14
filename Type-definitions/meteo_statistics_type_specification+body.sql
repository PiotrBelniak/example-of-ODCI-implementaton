CREATE OR REPLACE EDITIONABLE TYPE "C##METEO"."METEO_STATS_IM" IS OBJECT
(curnum INTEGER
,static function ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList) return number
,static function ODCIStatsCollect(kolumna sys.ODCIColInfo, opcje sys.ODCIStatsOptions, stats OUT RAW, env sys.ODCIEnv) return number
,static function ODCIStatsCollect(ia sys.ODCIIndexInfo, opcje sys.ODCIStatsOptions, stats OUT RAW, env sys.ODCIEnv) return number
,static function ODCIStatsDelete(kolumna sys.ODCIColInfo, stats OUT RAW, env sys.ODCIEnv) return number
,static function ODCIStatsDelete(ia sys.ODCIIndexInfo, stats OUT RAW, env sys.ODCIEnv) return number
,static function ODCIStatsSelectivity(pi sys.ODCIPredInfo, sel OUT NUMBER, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, obiekt METEO_T,predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
,static function ODCIStatsSelectivity(pi sys.ODCIPredInfo, sel OUT NUMBER, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, obiekt METEO_T,x_cord NUMBER, y_cord NUMBER, predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
,static function ODCIStatsSelectivity(pi sys.ODCIPredInfo, sel OUT NUMBER, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, obiekt METEO_T,paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
,static function ODCIStatsSelectivity(pi sys.ODCIPredInfo, sel OUT NUMBER, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, obiekt METEO_T,x_cord NUMBER, y_cord NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
,static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo, sel NUMBER, koszt OUT sys.ODCICost, qi sys.ODCIQueryInfo, pi sys.ODCIPredInfo, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
,static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo, sel NUMBER, koszt OUT sys.ODCICost, qi sys.ODCIQueryInfo, pi sys.ODCIPredInfo, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
,static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo, sel NUMBER, koszt OUT sys.ODCICost, qi sys.ODCIQueryInfo, pi sys.ODCIPredInfo, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
,static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo, sel NUMBER, koszt OUT sys.ODCICost, qi sys.ODCIQueryInfo, pi sys.ODCIPredInfo, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
,static function ODCIStatsFunctionCost(funkcja sys.ODCIFuncInfo, koszt OUT sys.ODCICost, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
,static function ODCIStatsFunctionCost(funkcja sys.ODCIFuncInfo, koszt OUT sys.ODCICost, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
,static function ODCIStatsFunctionCost(funkcja sys.ODCIFuncInfo, koszt OUT sys.ODCICost, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
,static function ODCIStatsFunctionCost(funkcja sys.ODCIFuncInfo, koszt OUT sys.ODCICost, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
);
/

CREATE OR REPLACE EDITIONABLE TYPE BODY "C##METEO"."METEO_STATS_IM" IS
    static function ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList) return number
    IS
    BEGIN
        ifclist:=sys.ODCIObjectList(sys.ODCIObject('SYS','ODCISTATS2'));
        return ODCIConst.Success;
    END ODCIGetInterfaces;

    static function ODCIStatsCollect(kolumna sys.ODCIColInfo, opcje sys.ODCIStatsOptions, stats OUT RAW, env sys.ODCIEnv) return number
    IS
        nrows_varr meteo_support_types_pack.meteo_v100t:=meteo_support_types_pack.meteo_v100t();
        regional_varr meteo_support_types_pack.region_values_v100t_all_zones :=meteo_support_types_pack.region_values_v100t_all_zones();
        allregional_varr meteo_support_types_pack.region_values_v100t_one_zone:=meteo_support_types_pack.region_values_v100t_one_zone();
        parameter_names_varr meteo_support_types_pack.varchar2_v4t :=meteo_support_types_pack.varchar2_v4t('temperature','rain_amount','pressure','avg_wind');
        CURSOR c1(tab_name VARCHAR2, col_name VARCHAR2) IS SELECT * FROM METEO_STATISTICS_TBL_POSITIONAL WHERE tabela=tab_name AND kolumna=col_name;
        source_data_varr meteo_t_varr:=meteo_t_varr();
        readings_cur_var SYS_REFCURSOR;
        sql_stmt VARCHAR2(1000);
        collector_sql_stmt VARCHAR(32767);/*sql stmt responsible for filling nrows_varr, minimum_varr, maximum_varr, regional_varr*/
        colname VARCHAR2(30):=rtrim(ltrim(kolumna.colName,'"'),'"');
        statsexistence BOOLEAN:=FALSE;
    BEGIN
        IF (kolumna.TableSchema IS NULL OR kolumna.TableName IS NULL OR kolumna.ColName IS NULL ) THEN
            RETURN ODCIConst.Error;
        END IF;
        FOR user_stats IN c1(kolumna.TableName, colname) LOOP
            statsexistence:=TRUE;
            EXIT;
        END LOOP;
        IF statsexistence THEN
            sql_stmt:='DELETE FROM METEO_STATISTICS_TBL_POSITIONAL WHERE tabela= :tab_name AND kolumna= :col_name';
            EXECUTE IMMEDIATE sql_stmt USING kolumna.TableName, colname;

            sql_stmt:='DELETE FROM METEO_STATISTICS_TBL_OVERALL WHERE tabela= :tab_name AND kolumna= :col_name';
            EXECUTE IMMEDIATE sql_stmt USING kolumna.TableName, colname;
        END IF;
        /*initialize necessary structures*/
        meteo_stats_initialize_collections(nrows_varr,allregional_varr,regional_varr);

        OPEN readings_cur_var FOR 'SELECT ' || colname || ' FROM ' || kolumna.TableName;

        collector_sql_stmt:=meteo_stats_prepare_dynamic_collection_statement(8760);
        EXECUTE IMMEDIATE collector_sql_stmt USING readings_cur_var, IN OUT nrows_varr,IN OUT allregional_varr,IN OUT regional_varr;

        CLOSE readings_cur_var;

        FORALL indx IN INDICES OF allregional_varr(1)
            INSERT INTO METEO_STATISTICS_TBL_OVERALL VALUES(kolumna.TableName, colname, nrows_varr(1).temperature, 'temperature',  allregional_varr(1)(indx).wartosc,allregional_varr(1)(indx).wystapienia);

        FORALL indx IN INDICES OF allregional_varr(2)
            INSERT INTO METEO_STATISTICS_TBL_OVERALL VALUES(kolumna.TableName, colname, nrows_varr(1).rain_amount, 'rain amount',  allregional_varr(2)(indx).wartosc,allregional_varr(2)(indx).wystapienia);

        FORALL indx IN INDICES OF allregional_varr(3)
            INSERT INTO METEO_STATISTICS_TBL_OVERALL VALUES(kolumna.TableName, colname, nrows_varr(1).pressure, 'pressure',  allregional_varr(3)(indx).wartosc,allregional_varr(3)(indx).wystapienia);

        FORALL indx IN INDICES OF allregional_varr(4)
            INSERT INTO METEO_STATISTICS_TBL_OVERALL VALUES(kolumna.TableName, colname, nrows_varr(1).avg_wind, 'avg_wind',  allregional_varr(4)(indx).wartosc,allregional_varr(4)(indx).wystapienia);                


        FOR region IN 1..100 LOOP

            FORALL indx IN INDICES OF regional_varr(region)(1)
                INSERT INTO METEO_STATISTICS_TBL_POSITIONAL VALUES(kolumna.TableName, colname, region, nrows_varr(region).temperature, 'temperature',  regional_varr(region)(1)(indx).wartosc,regional_varr(region)(1)(indx).wystapienia);

            FORALL indx IN INDICES OF regional_varr(region)(2)
                INSERT INTO METEO_STATISTICS_TBL_POSITIONAL VALUES(kolumna.TableName, colname, region, nrows_varr(region).rain_amount, 'rain amount',  regional_varr(region)(2)(indx).wartosc,regional_varr(region)(2)(indx).wystapienia);

            FORALL indx IN INDICES OF regional_varr(region)(3)
                INSERT INTO METEO_STATISTICS_TBL_POSITIONAL VALUES(kolumna.TableName, colname, region, nrows_varr(region).pressure, 'pressure',  regional_varr(region)(3)(indx).wartosc,regional_varr(region)(3)(indx).wystapienia);

            FORALL indx IN INDICES OF regional_varr(region)(4)
                INSERT INTO METEO_STATISTICS_TBL_POSITIONAL VALUES(kolumna.TableName, colname, region, nrows_varr(region).avg_wind, 'avg_wind',  regional_varr(region)(4)(indx).wartosc,regional_varr(region)(4)(indx).wystapienia);                
        END LOOP;
        return ODCIConst.Success;
    EXCEPTION
        WHEN OTHERS THEN CLOSE readings_cur_var;
    END ODCIStatsCollect;

    static function ODCIStatsCollect(ia sys.ODCIIndexInfo, opcje sys.ODCIStatsOptions, stats OUT RAW, env sys.ODCIEnv) return number
    IS
        parameter_names_varr meteo_support_types_pack.varchar2_v4t :=meteo_support_types_pack.varchar2_v4t();
        sql_stmt VARCHAR2(1000);
        all_rows NUMBER;
        CURSOR c1(tab_name VARCHAR2) IS SELECT * FROM METEO_STATISTICS_TBL_POSITIONAL WHERE tabela=tab_name AND kolumna=tab_name;
        tablename VARCHAR2(100):=ia.IndexSchema || '.' || ia.IndexName || '_indx_tab';
        statsexistence BOOLEAN:=FALSE;
    BEGIN
        IF (ia.IndexSchema IS NULL OR ia.IndexName IS NULL) THEN
            RETURN ODCIConst.Error;
        END IF;
        FOR user_stats IN c1(tablename) LOOP
            statsexistence:=TRUE;
            EXIT;
        END LOOP;
        IF statsexistence THEN
            sql_stmt:='DELETE FROM METEO_STATISTICS_TBL_POSITIONAL WHERE tabela= :tab_name AND kolumna= :col_name';
            EXECUTE IMMEDIATE sql_stmt USING tablename, tablename;

            sql_stmt:='DELETE FROM METEO_STATISTICS_TBL_OVERALL WHERE tabela= :tab_name AND kolumna= :col_name';
            EXECUTE IMMEDIATE sql_stmt USING tablename, tablename;
        END IF;   

        SELECT column_name BULK COLLECT INTO parameter_names_varr FROM all_tab_columns WHERE owner=ia.IndexSchema AND table_name=UPPER(ia.IndexName || '_indx_tab') AND column_name NOT IN ('R','POSITION');
        EXECUTE IMMEDIATE 'SELECT COUNT(DISTINCT r) FROM ' || tablename  INTO all_rows;
        FOR indx IN parameter_names_varr.FIRST..parameter_names_varr.LAST LOOP
            sql_stmt:='INSERT INTO METEO_STATISTICS_TBL_POSITIONAL select ''' || tablename || ''',''' || tablename || ''',position, ' || all_rows || ',''' || parameter_names_varr(indx) || ''',ROUND(' || parameter_names_varr(indx) || '),count(*) from ' || tablename || ' group by position,ROUND(' || parameter_names_varr(indx) || ')';
            EXECUTE IMMEDIATE sql_stmt;
            sql_stmt:='INSERT INTO METEO_STATISTICS_TBL_OVERALL select ''' || tablename || ''',''' || tablename || ''',' || all_rows || ',''' || parameter_names_varr(indx) || ''',ROUND(' || parameter_names_varr(indx) || '),count( distinct r) from ' || tablename || ' group by ROUND(' || parameter_names_varr(indx) || ')';
            EXECUTE IMMEDIATE sql_stmt;
        END LOOP;
        
        return ODCIConst.Success;
    END ODCIStatsCollect;

    static function ODCIStatsDelete(kolumna sys.ODCIColInfo, stats OUT RAW, env sys.ODCIEnv) return number
    IS
        CURSOR c1(tab_name VARCHAR2, col_name VARCHAR2) IS SELECT * FROM METEO_STATISTICS_TBL_POSITIONAL WHERE tabela=tab_name AND kolumna=col_name;
        sql_stmt VARCHAR2(1000);
        colname VARCHAR2(30):=rtrim(ltrim(kolumna.colName,'"'),'"');
        statsexistence BOOLEAN:=FALSE;
    BEGIN
        IF (kolumna.TableSchema IS NULL OR kolumna.TableName IS NULL OR kolumna.ColName IS NULL ) THEN
            RETURN ODCIConst.Error;
        END IF;
        FOR user_stats IN c1(kolumna.TableName, colname) LOOP
            statsexistence:=TRUE;
            EXIT;
        END LOOP;
        IF statsexistence THEN
            sql_stmt:='DELETE FROM METEO_STATISTICS_TBL_POSITIONAL WHERE tabela= :tab_name AND kolumna= :col_name';
            EXECUTE IMMEDIATE sql_stmt USING kolumna.TableName, colname;

            sql_stmt:='DELETE FROM METEO_STATISTICS_TBL_OVERALL WHERE tabela= :tab_name AND kolumna= :col_name';
            EXECUTE IMMEDIATE sql_stmt USING kolumna.TableName, colname;
        END IF;
        return ODCIConst.Success;
    END ODCIStatsDelete;

    static function ODCIStatsDelete(ia sys.ODCIIndexInfo, stats OUT RAW, env sys.ODCIEnv) return number
    IS
        CURSOR c1(tab_name VARCHAR2) IS SELECT * FROM METEO_STATISTICS_TBL_POSITIONAL WHERE tabela=tab_name AND kolumna=tab_name;
        sql_stmt VARCHAR2(1000);
        statsexistence BOOLEAN:=FALSE;
        table_name VARCHAR2(100):=ia.IndexName || '_indx_tab';
    BEGIN
        IF (ia.IndexSchema IS NULL OR ia.IndexName IS NULL) THEN
            RETURN ODCIConst.Error;
        END IF;
        FOR user_stats IN c1(table_name) LOOP
            statsexistence:=TRUE;
            EXIT;
        END LOOP;
        IF statsexistence THEN
            sql_stmt:='DELETE FROM METEO_STATISTICS_TBL_POSITIONAL WHERE tabela= :tab_name AND kolumna= :col_name';
            EXECUTE IMMEDIATE sql_stmt USING table_name, table_name;

            sql_stmt:='DELETE FROM METEO_STATISTICS_TBL_OVERALL WHERE tabela= :tab_name AND kolumna= :col_name';
            EXECUTE IMMEDIATE sql_stmt USING table_name, table_name;
        END IF;
        return ODCIConst.Success;
    END ODCIStatsDelete;

    static function ODCIStatsSelectivity(pi sys.ODCIPredInfo, sel OUT NUMBER, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, obiekt METEO_T,predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
IS
        fname VARCHAR2(30);
        relop VARCHAR2(2);
        nrows INTEGER;
        allrows INTEGER;
        colname VARCHAR2(30);
        statsexistence BOOLEAN:=FALSE;
        sql_stmt VARCHAR2(2000);
        sql_stmt2 VARCHAR2(2000);
    BEGIN
        /*check validity of arguments*/
        IF arguments(1).ArgType!=ODCIConst.ArgLit AND arguments(1).ArgType!=ODCIConst.ArgNull THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(2).ArgType!=ODCIConst.ArgLit AND arguments(1).ArgType!=ODCIConst.ArgNull THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(3).ArgType!=ODCIConst.ArgCol THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(4).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(5).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;        
        IF arguments(6).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(7).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;  
        IF (stop=0 AND bitand(pi.Flags, ODCIConst.PredIncludeStop)=0) THEN
            sel:=0;
            RETURN ODCIConst.Success;
        END IF;

        IF (strt=1 AND bitand(pi.Flags, ODCIConst.PredIncludeStart)=0) THEN
            sel:=0;
            RETURN ODCIConst.Success;
        END IF;

        IF (strt=0 AND bitand(pi.Flags, ODCIConst.PredExactMatch) = 0 AND bitand(pi.Flags, ODCIConst.PredIncludeStart)>0) THEN
            sel:=100;
            RETURN ODCIConst.Success;
        END IF;

        IF (stop=1 AND bitand(pi.Flags, ODCIConst.PredExactMatch) = 0 AND bitand(pi.Flags, ODCIConst.PredIncludeStop)>0) THEN
            sel:=100;
            RETURN ODCIConst.Success;
        END IF;        

        IF bitand(pi.Flags,ODCICOnst.PredObjectFunc)>0 THEN
            fname:=pi.ObjectName;
        ELSE
            fname:=pi.MethodName;
        END IF;

        IF fname LIKE UPPER('meteo_equals%') THEN
            relop:='=';
        ELSIF fname LIKE UPPER('meteo_lessthan%') THEN
            relop:='<';
        ELSIF fname LIKE UPPER('meteo_greaterthan%') THEN
            relop:='>';   
        ELSE
            RETURN ODCIConst.Error;
        END IF;

        colname:=rtrim(ltrim(arguments(3).colName,'"'),'"');
        sql_stmt:='SELECT max(ilosc_wystapien) from METEO_STATISTICS_TBL_OVERALL WHERE tabela = :tab_name AND kolumna = :col_name AND parametr = :predicate AND wartosc ' || relop || ' ROUND( :predicateval )';    
        sql_stmt2:='SELECT DISTINCT all_rows from METEO_STATISTICS_TBL_OVERALL WHERE tabela = :tab_name AND kolumna = :col_name AND parametr = :predicate';        

        IF arguments(3).TableName LIKE '%_indx_tab' THEN
            EXECUTE IMMEDIATE sql_stmt INTO nrows USING arguments(3).TableName,arguments(3).TableName, paramval, predval;
            EXECUTE IMMEDIATE sql_stmt2 INTO allrows USING arguments(3).TableName,arguments(3).TableName, paramval;
        ELSE
            EXECUTE IMMEDIATE sql_stmt INTO nrows USING arguments(3).TableName,colname, paramval, predval;
            EXECUTE IMMEDIATE sql_stmt2 INTO allrows USING arguments(3).TableName,colname, paramval;   
        END IF;

        IF nrows IS NULL OR allrows IS NULL THEN
            RETURN ODCIConst.Error;
        END IF;            

        IF stop = 0 AND relop='=' THEN
            IF paramval='pressure' THEN
                sel:=100-nrows/allrows*2;
            ELSE
                sel:=100-nrows/allrows*50;
            END IF;
        ELSIF strt = 1 AND relop='=' THEN
            IF paramval='pressure' THEN
                sel:=nrows/allrows*2;
            ELSE
                sel:=nrows/allrows*50;
            END IF;
        ELSIF stop = 0 AND relop!='=' THEN
            sel:=(1-nrows/allrows)*100;
        ELSIF strt = 1 AND relop!='=' THEN
            sel:=nrows/allrows*100;
        END IF;

        return ODCIConst.Success;
    END ODCIStatsSelectivity;

    static function ODCIStatsSelectivity(pi sys.ODCIPredInfo, sel OUT NUMBER, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, obiekt METEO_T,x_cord NUMBER, y_cord NUMBER, predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
    IS
        fname VARCHAR2(30);
        relop VARCHAR2(2);
        nrows INTEGER;
        allrows INTEGER;
        colname VARCHAR2(30);
        komorka INTEGER;
        statsexistence BOOLEAN:=FALSE;
        sql_stmt VARCHAR2(2000);
        sql_stmt2 VARCHAR2(2000);
    BEGIN
        /*check validity of arguments*/
        IF arguments(1).ArgType!=ODCIConst.ArgLit AND arguments(1).ArgType!=ODCIConst.ArgNull THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(2).ArgType!=ODCIConst.ArgLit AND arguments(1).ArgType!=ODCIConst.ArgNull THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(3).ArgType!=ODCIConst.ArgCol THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(4).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(5).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;        
        IF arguments(6).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(7).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;  
        IF (stop=0 AND bitand(pi.Flags, ODCIConst.PredIncludeStop)=0) THEN
            sel:=0;
            RETURN ODCIConst.Success;
        END IF;

        IF (strt=1 AND bitand(pi.Flags, ODCIConst.PredIncludeStart)=0) THEN
            sel:=0;
            RETURN ODCIConst.Success;
        END IF;

        IF (strt=0 AND bitand(pi.Flags, ODCIConst.PredExactMatch) = 0 AND bitand(pi.Flags, ODCIConst.PredIncludeStart)>0) THEN
            sel:=100;
            RETURN ODCIConst.Success;
        END IF;

        IF (stop=1 AND bitand(pi.Flags, ODCIConst.PredExactMatch) = 0 AND bitand(pi.Flags, ODCIConst.PredIncludeStop)>0) THEN
            sel:=100;
            RETURN ODCIConst.Success;
        END IF;        

        IF bitand(pi.Flags,ODCICOnst.PredObjectFunc)>0 THEN
            fname:=pi.ObjectName;
        ELSE
            fname:=pi.MethodName;
        END IF;

        IF fname LIKE UPPER('meteo_equals%') THEN
            relop:='=';
        ELSIF fname LIKE UPPER('meteo_lessthan%') THEN
            relop:='<';
        ELSIF fname LIKE UPPER('meteo_greaterthan%') THEN
            relop:='>';   
        ELSE
            RETURN ODCIConst.Error;
        END IF;

        komorka:=x_cord*10-(10-y_cord);
        colname:=rtrim(ltrim(arguments(3).colName,'"'),'"');
        sql_stmt:='SELECT sum(ilosc_wystapien) from METEO_STATISTICS_TBL_POSITIONAL WHERE tabela = :tab_name AND kolumna = :col_name AND pozycja = : position AND parametr = :predicate AND wartosc ' || relop || ' ROUND( :predicateval )';
        sql_stmt2:='SELECT DISTINCT all_rows from METEO_STATISTICS_TBL_POSITIONAL WHERE tabela = :tab_name AND kolumna = :col_name AND pozycja = : position AND parametr = :predicate';        

        IF arguments(3).TableName LIKE '%_indx_tab' THEN
            EXECUTE IMMEDIATE sql_stmt INTO nrows USING arguments(3).TableName,arguments(3).TableName, komorka, paramval, predval;
            EXECUTE IMMEDIATE sql_stmt2 INTO allrows USING arguments(3).TableName,arguments(3).TableName, komorka, paramval;
        ELSE
            EXECUTE IMMEDIATE sql_stmt INTO nrows USING arguments(3).TableName,colname, komorka, paramval, predval;
            EXECUTE IMMEDIATE sql_stmt2 INTO allrows USING arguments(3).TableName,colname, komorka, paramval;   
        END IF;

        IF nrows IS NULL OR allrows IS NULL THEN
            RETURN ODCIConst.Error;
        END IF;    

        IF stop = 0 AND relop='=' THEN
            IF paramval='pressure' THEN
                sel:=100-nrows/allrows;
            ELSE
                sel:=100-nrows/allrows*10;
            END IF;
        ELSIF strt = 1 AND relop='=' THEN
            IF paramval='pressure' THEN
                sel:=nrows/allrows;
            ELSE
                sel:=nrows/allrows*10;
            END IF;
        ELSIF stop = 0 AND relop!='=' THEN
            sel:=(1-nrows/allrows)*100;
        ELSIF strt = 1 AND relop!='=' THEN
            sel:=nrows/allrows*100;
        END IF;

        return ODCIConst.Success;
    END ODCIStatsSelectivity;

    static function ODCIStatsSelectivity(pi sys.ODCIPredInfo, sel OUT NUMBER, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, obiekt METEO_T,paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
    IS
        fname VARCHAR2(30);
        relop VARCHAR2(2);
        nrows1 INTEGER;
        nrows2 INTEGER;
        allrows INTEGER;
        colname VARCHAR2(30);
        statsexistence BOOLEAN:=FALSE;
        sql_stmt VARCHAR2(2000);
        sql_stmt2 VARCHAR2(2000);
    BEGIN
        /*check validity of arguments*/
        IF arguments(1).ArgType!=ODCIConst.ArgLit AND arguments(1).ArgType!=ODCIConst.ArgNull THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(2).ArgType!=ODCIConst.ArgLit AND arguments(1).ArgType!=ODCIConst.ArgNull THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(3).ArgType!=ODCIConst.ArgCol THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(4).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(5).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;        
        IF arguments(6).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(7).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;  

        IF (stop=0 AND bitand(pi.Flags, ODCIConst.PredIncludeStop)=0) THEN
            sel:=0;
            RETURN ODCIConst.Success;
        END IF;

        IF (strt=1 AND bitand(pi.Flags, ODCIConst.PredIncludeStart)=0) THEN
            sel:=0;
            RETURN ODCIConst.Success;
        END IF;

        IF (strt=0 AND bitand(pi.Flags, ODCIConst.PredExactMatch) = 0 AND bitand(pi.Flags, ODCIConst.PredIncludeStart)>0) THEN
            sel:=100;
            RETURN ODCIConst.Success;
        END IF;

        IF (stop=1 AND bitand(pi.Flags, ODCIConst.PredExactMatch) = 0 AND bitand(pi.Flags, ODCIConst.PredIncludeStop)>0) THEN
            sel:=100;
            RETURN ODCIConst.Success;
        END IF;        

        IF bitand(pi.Flags,ODCICOnst.PredObjectFunc)>0 THEN
            fname:=pi.ObjectName;
        ELSE
            fname:=pi.MethodName;
        END IF;

        IF fname LIKE UPPER('meteo_equals%') THEN
            relop:='=';
        ELSIF fname LIKE UPPER('meteo_lessthan%') THEN
            relop:='<';
        ELSIF fname LIKE UPPER('meteo_greaterthan%') THEN
            relop:='>';   
        ELSE
            RETURN ODCIConst.Error;
        END IF;

        colname:=rtrim(ltrim(arguments(3).colName,'"'),'"');
        sql_stmt:='SELECT max(ilosc_wystapien) from METEO_STATISTICS_TBL_OVERALL WHERE tabela = :tab_name AND kolumna = :col_name AND parametr = :predicate AND wartosc ' || relop || ' ROUND( :predicateval )';
        sql_stmt2:='SELECT all_rows from METEO_STATISTICS_TBL_OVERALL WHERE tabela = :tab_name AND kolumna = :col_name AND parametr = :predicate';        

        IF arguments(3).TableName LIKE '%_indx_tab' THEN
            EXECUTE IMMEDIATE sql_stmt INTO nrows1 USING arguments(3).TableName,arguments(3).TableName, paramval1, predval1;
            EXECUTE IMMEDIATE sql_stmt INTO nrows2 USING arguments(3).TableName,arguments(3).TableName, paramval2, predval2;            
            EXECUTE IMMEDIATE sql_stmt2 INTO allrows USING arguments(3).TableName,arguments(3).TableName, paramval1;
        ELSE
            EXECUTE IMMEDIATE sql_stmt INTO nrows1 USING arguments(3).TableName,colname, paramval1, predval1;
            EXECUTE IMMEDIATE sql_stmt INTO nrows2 USING arguments(3).TableName,colname, paramval2, predval2;            
            EXECUTE IMMEDIATE sql_stmt2 INTO allrows USING arguments(3).TableName,colname, paramval1;   
        END IF;

        IF nrows1 IS NULL OR nrows2 IS NULL OR allrows IS NULL THEN
            RETURN ODCIConst.Error;
        END IF;    

        IF stop = 0 AND relop='=' THEN
            IF paramval1='pressure' OR paramval2='pressure' THEN
                sel:=100-LEAST(nrows1,nrows2)/allrows*2;
            ELSE
                sel:=100-LEAST(nrows1,nrows2)/allrows*50;
            END IF;
        ELSIF strt = 1 AND relop='=' THEN
            IF paramval1='pressure' OR paramval2='pressure' THEN
                sel:=LEAST(nrows1,nrows2)/allrows*2;
            ELSE
                sel:=LEAST(nrows1,nrows2)/allrows*50;
            END IF;
        ELSIF stop = 0 AND relop!='=' THEN
            sel:=(1-LEAST(nrows1,nrows2)/allrows)*100;
        ELSIF strt = 1 AND relop!='=' THEN
            sel:=LEAST(nrows1,nrows2)/allrows*100;
        END IF;

        return ODCIConst.Success;
    END ODCIStatsSelectivity;   

    static function ODCIStatsSelectivity(pi sys.ODCIPredInfo, sel OUT NUMBER, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, obiekt METEO_T,x_cord NUMBER, y_cord NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
    IS
        fname VARCHAR2(30);
        relop VARCHAR2(2);
        nrows1 INTEGER;
        nrows2 INTEGER;
        allrows INTEGER;
        colname VARCHAR2(30);
        komorka INTEGER;
        statsexistence BOOLEAN:=FALSE;
        sql_stmt VARCHAR2(2000);
        sql_stmt2 VARCHAR2(2000);
    BEGIN
        /*check validity of arguments*/
        IF arguments(1).ArgType!=ODCIConst.ArgLit AND arguments(1).ArgType!=ODCIConst.ArgNull THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(2).ArgType!=ODCIConst.ArgLit AND arguments(1).ArgType!=ODCIConst.ArgNull THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(3).ArgType!=ODCIConst.ArgCol THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(4).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(5).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;        
        IF arguments(6).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(7).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;  
        IF arguments(8).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;
        IF arguments(9).ArgType!=ODCIConst.ArgLit THEN
            return ODCIConst.Error;
        END IF;  

        IF (stop=0 AND bitand(pi.Flags, ODCIConst.PredIncludeStop)=0) THEN
            sel:=0;
            RETURN ODCIConst.Success;
        END IF;

        IF (strt=1 AND bitand(pi.Flags, ODCIConst.PredIncludeStart)=0) THEN
            sel:=0;
            RETURN ODCIConst.Success;
        END IF;

        IF (strt=0 AND bitand(pi.Flags, ODCIConst.PredExactMatch) = 0 AND bitand(pi.Flags, ODCIConst.PredIncludeStart)>0) THEN
            sel:=100;
            RETURN ODCIConst.Success;
        END IF;

        IF (stop=1 AND bitand(pi.Flags, ODCIConst.PredExactMatch) = 0 AND bitand(pi.Flags, ODCIConst.PredIncludeStop)>0) THEN
            sel:=100;
            RETURN ODCIConst.Success;
        END IF;        

        IF bitand(pi.Flags,ODCICOnst.PredObjectFunc)>0 THEN
            fname:=pi.ObjectName;
        ELSE
            fname:=pi.MethodName;
        END IF;

        IF bitand(pi.Flags,ODCICOnst.PredObjectFunc)>0 THEN
            fname:=pi.ObjectName;
        ELSE
            fname:=pi.MethodName;
        END IF;

        komorka:=x_cord*10-(10-y_cord);
        colname:=rtrim(ltrim(arguments(3).colName,'"'),'"');
        sql_stmt:='SELECT sum(ilosc_wystapien) from METEO_STATISTICS_TBL_POSITIONAL WHERE tabela = :tab_name AND kolumna = :col_name AND pozycja = : position AND parametr = :predicate AND wartosc ' || relop || ' ROUND( :predicateval )';
        sql_stmt2:='SELECT DISTINCT all_rows from METEO_STATISTICS_TBL_POSITIONAL WHERE tabela = :tab_name AND kolumna = :col_name AND pozycja = : position AND parametr = :predicate';        

        IF arguments(3).TableName LIKE '%_indx_tab' THEN
            EXECUTE IMMEDIATE sql_stmt INTO nrows1 USING arguments(3).TableName,arguments(3).TableName, komorka, paramval1, predval1;
            EXECUTE IMMEDIATE sql_stmt INTO nrows2 USING arguments(3).TableName,arguments(3).TableName, komorka, paramval2, predval2;            
            EXECUTE IMMEDIATE sql_stmt2 INTO allrows USING arguments(3).TableName,arguments(3).TableName, komorka, paramval1;
        ELSE
            EXECUTE IMMEDIATE sql_stmt INTO nrows1 USING arguments(3).TableName,colname, komorka, paramval1, predval1;
            EXECUTE IMMEDIATE sql_stmt INTO nrows2 USING arguments(3).TableName,colname, komorka, paramval2, predval2;             
            EXECUTE IMMEDIATE sql_stmt2 INTO allrows USING arguments(3).TableName,colname, komorka, paramval1;   
        END IF;

        IF nrows1 IS NULL OR nrows2 IS NULL OR allrows IS NULL THEN
            RETURN ODCIConst.Error;
        END IF;            

        IF stop = 0 AND relop='=' THEN
            IF paramval1='pressure' OR paramval2='pressure' THEN
                sel:=100-LEAST(nrows1,nrows2)/allrows;
            ELSE
                sel:=100-LEAST(nrows1,nrows2)/allrows*10;
            END IF;
        ELSIF strt = 1 AND relop='=' THEN
            IF paramval1='pressure' OR paramval2='pressure' THEN
                sel:=LEAST(nrows1,nrows2)/allrows;
            ELSE
                sel:=LEAST(nrows1,nrows2)/allrows*10;
            END IF;
        ELSIF stop = 0 AND relop!='=' THEN
            sel:=(1-LEAST(nrows1,nrows2)/allrows)*100;
        ELSIF strt = 1 AND relop!='=' THEN
            sel:=LEAST(nrows1,nrows2)/allrows*100;
        END IF;

        return ODCIConst.Success;
    END ODCIStatsSelectivity;   

    static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo, sel NUMBER, koszt OUT sys.ODCICost, qi sys.ODCIQueryInfo, pi sys.ODCIPredInfo, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
    IS
        ixtab VARCHAR2(40);
        numblocks NUMBER:=NULL;
        CURSOR C1(tab_name VARCHAR2) IS SELECT * FROM user_tables where table_name=tab_name;
    BEGIN
        IF sel IS NULL THEN
            RETURN ODCIConst.Error;
        END IF;
        koszt:=sys.ODCICost(NULL,NULL,NULL,NULL);

        ixtab:=ia.IndexName || '_indx_tab';
        FOR get_tab IN c1(upper(ixtab)) LOOP
            numblocks:=get_tab.blocks;
            EXIT;
        END LOOP;

        IF numblocks IS NULL THEN
            RETURN ODCIConst.Error;
        END IF;

        koszt.CPUCost:=ceil(550*(sel/100)*numblocks);
        koszt.IOCost:=ceil(2*(sel/100)*numblocks);
        RETURN ODCIConst.Success; 
    END ODCIStatsIndexCost;

    static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo, sel NUMBER, koszt OUT sys.ODCICost, qi sys.ODCIQueryInfo, pi sys.ODCIPredInfo, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
    IS
    BEGIN
        RETURN ODCIStatsIndexCost(ia, sel, koszt , qi , pi , arguments , strt, stop, predval,paramval, env);
    END ODCIStatsIndexCost;    

    static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo, sel NUMBER, koszt OUT sys.ODCICost, qi sys.ODCIQueryInfo, pi sys.ODCIPredInfo, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
    IS
    BEGIN
        RETURN ODCIStatsIndexCost(ia, sel, koszt , qi , pi , arguments , strt, stop, predval1,paramval1, env);
    END ODCIStatsIndexCost;     

    static function ODCIStatsIndexCost(ia sys.ODCIIndexInfo, sel NUMBER, koszt OUT sys.ODCICost, qi sys.ODCIQueryInfo, pi sys.ODCIPredInfo, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
    IS
    BEGIN
        RETURN ODCIStatsIndexCost(ia, sel, koszt , qi , pi , arguments , strt, stop, predval1,paramval1, env);
    END ODCIStatsIndexCost;      

    static function ODCIStatsFunctionCost(funkcja sys.ODCIFuncInfo, koszt OUT sys.ODCICost, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
    IS
        fname VARCHAR2(30);
    BEGIN
        IF bitand(funkcja.Flags,ODCIConst.ObjectFunc)>0 THEN
            fname:=funkcja.ObjectName;
        ELSE
            fname:=funkcja.MethodName;
        END IF;        

        IF fname LIKE UPPER('meteo_equals%') THEN
            koszt.CPUCost:=10000;
            koszt.IOCost:=0;
        ELSIF fname LIKE UPPER('meteo_lessthan%') THEN
            koszt.CPUCost:=7500;
            koszt.IOCost:=0;
        ELSIF fname LIKE UPPER('meteo_greaterthan%') THEN
            koszt.CPUCost:=7500;
            koszt.IOCost:=0;
        ELSE
            RETURN ODCIConst.Error;
        END IF;
        RETURN ODCIConst.Success;
    END ODCIStatsFunctionCost;    

    static function ODCIStatsFunctionCost(funkcja sys.ODCIFuncInfo, koszt OUT sys.ODCICost, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, predval NUMBER, paramval VARCHAR2, env sys.ODCIEnv) return number
    IS
    BEGIN
        RETURN ODCIStatsFunctionCost(funkcja, koszt, arguments, strt, stop, predval, paramval, env);
    END ODCIStatsFunctionCost; 

    static function ODCIStatsFunctionCost(funkcja sys.ODCIFuncInfo, koszt OUT sys.ODCICost, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
    IS
    BEGIN
        RETURN ODCIStatsFunctionCost(funkcja, koszt, arguments, strt, stop, predval1, paramval1, env);
    END ODCIStatsFunctionCost;    

    static function ODCIStatsFunctionCost(funkcja sys.ODCIFuncInfo, koszt OUT sys.ODCICost, arguments sys.ODCIArgDescList, strt NUMBER, stop NUMBER, x_cord NUMBER, y_cord NUMBER, paramval1 VARCHAR2, predval1 NUMBER, paramval2 VARCHAR2, predval2 NUMBER, env sys.ODCIEnv) return number
    IS
    BEGIN
        RETURN ODCIStatsFunctionCost(funkcja, koszt, arguments, strt, stop, predval1, paramval1, env);
    END ODCIStatsFunctionCost;

END meteo_stats_im;

/
