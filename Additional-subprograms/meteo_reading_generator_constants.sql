CREATE OR REPLACE EDITIONABLE PACKAGE "C##METEO"."METEO_READINGS_CONSTANTS" 
IS
    min_temp_jan CONSTANT NUMBER(3,1):=-20;
    min_temp_feb CONSTANT NUMBER(3,1):=-16;    
    min_temp_mar CONSTANT NUMBER(3,1):=-9;   
    min_temp_apr CONSTANT NUMBER(3,1):=-4;    
    min_temp_may CONSTANT NUMBER(3,1):=2;    
    min_temp_jun CONSTANT NUMBER(3,1):=8;    
    min_temp_jul CONSTANT NUMBER(3,1):=9;    
    min_temp_aug CONSTANT NUMBER(3,1):=10;    
    min_temp_sep CONSTANT NUMBER(3,1):=7;    
    min_temp_oct CONSTANT NUMBER(3,1):=3;    
    min_temp_nov CONSTANT NUMBER(3,1):=-4;    
    min_temp_dec CONSTANT NUMBER(3,1):=-14;    
    max_temp_jan CONSTANT NUMBER(3,1):=5;
    max_temp_feb CONSTANT NUMBER(3,1):=10;    
    max_temp_mar CONSTANT NUMBER(3,1):=15;   
    max_temp_apr CONSTANT NUMBER(3,1):=17;    
    max_temp_may CONSTANT NUMBER(3,1):=21;    
    max_temp_jun CONSTANT NUMBER(3,1):=25;    
    max_temp_jul CONSTANT NUMBER(3,1):=30;    
    max_temp_aug CONSTANT NUMBER(3,1):=26;    
    max_temp_sep CONSTANT NUMBER(3,1):=19;    
    max_temp_oct CONSTANT NUMBER(3,1):=14;    
    max_temp_nov CONSTANT NUMBER(3,1):=11;    
    max_temp_dec CONSTANT NUMBER(3,1):=4;   
    min_rain CONSTANT NUMBER(3,1):=0;
    max_rain_jan CONSTANT NUMBER(3,1):=4;
    max_rain_feb CONSTANT NUMBER(3,1):=5;    
    max_rain_mar CONSTANT NUMBER(3,1):=10;   
    max_rain_apr CONSTANT NUMBER(3,1):=18;    
    max_rain_may CONSTANT NUMBER(3,1):=26;    
    max_rain_jun CONSTANT NUMBER(3,1):=26;    
    max_rain_jul CONSTANT NUMBER(3,1):=17;    
    max_rain_aug CONSTANT NUMBER(3,1):=16;    
    max_rain_sep CONSTANT NUMBER(3,1):=21;    
    max_rain_oct CONSTANT NUMBER(3,1):=24;    
    max_rain_nov CONSTANT NUMBER(3,1):=20;    
    max_rain_dec CONSTANT NUMBER(3,1):=4;   
    min_pressure CONSTANT NUMBER(6,2):=966.7;
    max_pressure CONSTANT NUMBER(6,2):=1054;
    min_wind CONSTANT NUMBER(3,1):=4;
    max_wind CONSTANT NUMBER(3,1):=50;
END meteo_readings_constants;

/
