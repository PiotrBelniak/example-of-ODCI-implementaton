CREATE OR REPLACE EDITIONABLE FUNCTION "C##METEO"."METEO_STATS_PREPARE_DYNAMIC_COLLECTION_STATEMENT" (limit_fetchu NUMBER) return VARCHAR2
IS
    sql_stmt VARCHAR2(32767);
    declaration_section VARCHAR2(1000);
    loop_skeleton_section VARCHAR2(1000);
    parameter_collection_section_template VARCHAR2(3000);
    parameter_collection_section VARCHAR2(3000);
BEGIN
    declaration_section:=   'DECLARE 
                            type num_ntt IS TABLE OF NUMBER;
                            type num_nt_v4t IS VARRAY(4) OF num_ntt;
                            existing_values_varrays num_nt_v4t:=num_nt_v4t();
                            readings_cur_var SYS_REFCURSOR:= :cur_var;    
                            nrows_varr meteo_support_types_pack.meteo_v100t:= :varray1;
                            allregional_varr meteo_support_types_pack.region_values_v100t_one_zone:= :varray2; 
                            regional_varr meteo_support_types_pack.region_values_v100t_all_zones := :big_varr;  
                            source_data_varr meteo_t_varr:=meteo_t_varr();';

    loop_skeleton_section:='LOOP    
                            FETCH readings_cur_var BULK COLLECT INTO source_data_varr LIMIT ' || limit_fetchu || ';
                            EXIT WHEN source_data_varr.COUNT=0;

                                FOR odczyt IN source_data_varr.FIRST..source_data_varr.LAST LOOP
                                    FOR i IN 1..4 LOOP existing_values_varrays(i).DELETE; END LOOP;
                                    FOR region IN 1..100 LOOP 

                                     statement1 
                                     statement2 
                                     statement3 
                                     statement4 

                                    END LOOP;
                                END LOOP;
                            END LOOP;';

    parameter_collection_section_template:='IF ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru) NOT MEMBER OF existing_values_varrays(numer_parametru) OR existing_values_varrays(numer_parametru).COUNT=0 THEN
                                                existing_values_varrays(numer_parametru).EXTEND;
                                                existing_values_varrays(numer_parametru)(existing_values_varrays(numer_parametru).LAST):=ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru);

                                                IF allregional_varr(numer_parametru).EXISTS(ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru)) THEN
                                                    allregional_varr(numer_parametru)(ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru)).wystapienia:=allregional_varr(numer_parametru)(ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru)).wystapienia+1;
                                                ELSE
                                                    allregional_varr(numer_parametru)(ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru)).wystapienia:=1;
                                                    allregional_varr(numer_parametru)(ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru)).wartosc:=ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru);
                                                END IF;
                                            END IF; 

                                            nrows_varr(region).nazwa_parametru:=NVL2(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru,nrows_varr(region).nazwa_parametru+1,nrows_varr(region).nazwa_parametru);

                                            IF regional_varr(region)(numer_parametru).EXISTS(ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru)) THEN
                                                regional_varr(region)(numer_parametru)(ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru)).wystapienia:=regional_varr(region)(numer_parametru)(ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru)).wystapienia+1;
                                            ELSE
                                                regional_varr(region)(numer_parametru)(ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru)).wystapienia:=1;
                                                regional_varr(region)(numer_parametru)(ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru)).wartosc:=ROUND(source_data_varr(odczyt).Zonereadings(region).nazwa_parametru);
                                            END IF;';

    sql_stmt:=  declaration_section || ' BEGIN existing_values_varrays.EXTEND(4);  FOR i IN 1..4 LOOP existing_values_varrays(i):=num_ntt(); END LOOP; ' || loop_skeleton_section || ' :varray1:=nrows_varr;
                :varray2:=allregional_varr;
                :big_varr:=regional_varr;
            END;';

    parameter_collection_section:=REPLACE(REPLACE(parameter_collection_section_template,'nazwa_parametru','temperature'),'numer_parametru',1);
    sql_stmt:=REPLACE(sql_stmt,'statement1',parameter_collection_section);

    parameter_collection_section:=REPLACE(REPLACE(parameter_collection_section_template,'nazwa_parametru','rain_amount'),'numer_parametru',2);
    sql_stmt:=REPLACE(sql_stmt,'statement2',parameter_collection_section);    

    parameter_collection_section:=REPLACE(REPLACE(parameter_collection_section_template,'nazwa_parametru','pressure'),'numer_parametru',3);
    sql_stmt:=REPLACE(sql_stmt,'statement3',parameter_collection_section);

    parameter_collection_section:=REPLACE(REPLACE(parameter_collection_section_template,'nazwa_parametru','avg_wind'),'numer_parametru',4);
    sql_stmt:=REPLACE(sql_stmt,'statement4',parameter_collection_section);

    return sql_stmt;
END meteo_stats_prepare_dynamic_collection_statement;

/
