CREATE OR REPLACE EDITIONABLE PROCEDURE "C##METEO"."METEO_STATS_INITIALIZE_COLLECTIONS" (varr1 IN OUT NOCOPY  meteo_support_types_pack.meteo_v100t, 
                            varr2 IN OUT NOCOPY meteo_support_types_pack.region_values_v100t_one_zone
                            ,varr3 IN OUT NOCOPY meteo_support_types_pack.region_values_v100t_all_zones) ACCESSIBLE BY (type METEO_STATS_IM)
IS
BEGIN
    varr1.EXTEND(100);
    FOR indx IN 1..100 LOOP
        varr1(indx):=meteo_support_types_pack.meteo_stats_rec(0,0,0,0);
    END LOOP;
    varr2.EXTEND(4);
    varr3.EXTEND(100);
    FOR i IN 1..100 LOOP
        varr3(i):=meteo_support_types_pack.region_values_v100t_one_zone();
        varr3(i).EXTEND(4);
    END LOOP;   
END;

/
