CREATE OR REPLACE EDITIONABLE PACKAGE "C##METEO"."METEO_SUPPORT_TYPES_PACK" IS
    type meteo_index_insert_rowtype IS RECORD(r ROWID, readingtime TIMESTAMP,position NUMBER, temperature NUMBER(3,1)
                    ,rain_amount NUMBER(3,1),pressure NUMBER(6,2),avg_wind NUMBER(3,1));
    type meteo_index_insert_ntt IS TABLE OF meteo_index_insert_rowtype;
    type timestamp_v32767t IS VARRAY(32767) OF TIMESTAMP;
    type val_dur_rec IS RECORD(rand_value NUMBER,duration INTEGER NOT NULL:= 0);
    type val_dur_varr IS VARRAY(100) OF val_dur_rec;
    type meteo_stats_rec IS RECORD(temperature NUMBER(8,1),rain_amount NUMBER(8,1),pressure NUMBER(8,2),avg_wind NUMBER(8,1));
    type meteo_v100t IS VARRAY(100) OF meteo_stats_rec;
    type zone_values_rt IS RECORD(wartosc NUMBER, wystapienia INTEGER);
    type zone_values_aat IS TABLE OF zone_values_rt INDEX BY PLS_INTEGER;  
    type region_values_v100t_one_zone IS VARRAY(4) OF zone_values_aat;    
    type region_values_v100t_all_zones IS VARRAY(100) OF region_values_v100t_one_zone;
    type varchar2_v4t IS VARRAY(4) OF VARCHAR2(30);
    type parameters_aat IS TABLE OF VARCHAR2(250) INDEX BY VARCHAR2(30);
END;

/
