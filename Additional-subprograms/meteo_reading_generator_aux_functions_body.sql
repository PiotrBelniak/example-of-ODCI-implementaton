CREATE OR REPLACE EDITIONABLE PACKAGE BODY "C##METEO"."METEO_READINGS_AUX_FUNCTIONS" 
IS
    function calculate_temperature(miesiac NUMBER,rand_result NUMBER DEFAULT NULL, poprzedni_odczyt NUMBER DEFAULT NULL) return NUMBER
    IS
        retval NUMBER(3,1);
        min_temp NUMBER(3,1);
        max_temp NUMBER(3,1);
    BEGIN
        min_temp:=get_min_temp(miesiac);
        max_temp:=get_max_temp_rain('temperature',miesiac);
        If rand_result IS NULL AND poprzedni_odczyt IS NULL THEN
            retval:=ROUND(dbms_random.value(min_temp-0.04999999,max_temp+0.04999999),1);
        ELSIF rand_result>=0 AND rand_result <0.1 THEN
            retval:=ROUND(dbms_random.value(LEAST(max_temp-0.54999999,poprzedni_odczyt+0.95000001),LEAST(max_temp+0.049,poprzedni_odczyt+2.04999999)),1);
        ELSIF rand_result>=0.1 AND rand_result <0.25 THEN
            retval:=ROUND(dbms_random.value(LEAST(max_temp-0.54999999,poprzedni_odczyt+0.45000001),LEAST(max_temp+0.049,poprzedni_odczyt+1.14999999)),1);
        ELSIF rand_result>=0.25 AND rand_result <0.45 THEN
            retval:=ROUND(dbms_random.value(LEAST(max_temp-0.54999999,poprzedni_odczyt+0.05000001),LEAST(max_temp+0.049,poprzedni_odczyt+0.54999999)),1);            
        ELSIF rand_result>=0.45 AND rand_result <0.55 THEN
            retval:=ROUND(dbms_random.value(GREATEST(min_temp-0.04999999,poprzedni_odczyt-0.14999999),LEAST(max_temp+0.049,poprzedni_odczyt+0.14999999)),1);     
        ELSIF rand_result>=0.55 AND rand_result <0.75 THEN
            retval:=ROUND(dbms_random.value(GREATEST(min_temp-0.04999999,poprzedni_odczyt-0.54999999),GREATEST(min_temp+0.54999999,poprzedni_odczyt-0.05000001)),1);     
        ELSIF rand_result>=0.75 AND rand_result <0.9 THEN
            retval:=ROUND(dbms_random.value(GREATEST(min_temp-0.04999999,poprzedni_odczyt-1.14999999),GREATEST(min_temp+0.54999999,poprzedni_odczyt-0.45000001)),1);     
        ELSIF rand_result>=0.9 AND rand_result <=1 THEN
            retval:=ROUND(dbms_random.value(GREATEST(min_temp-0.04999999,poprzedni_odczyt-2.04999999),GREATEST(min_temp+0.54999999,poprzedni_odczyt-0.95000001)),1);     
        END IF;
        return retval;
    END calculate_temperature;

    function calculate_rain(rand_result NUMBER, miesiac NUMBER, poprzedni_odczyt NUMBER) return NUMBER
    IS
        retval NUMBER(3,1);
        min_rain NUMBER(3,1):=meteo_readings_constants.min_rain;
        max_rain NUMBER(3,1);
    BEGIN
        max_rain:=get_max_temp_rain('rain',miesiac);
        IF rand_result>=0.33 AND rand_result<0.67 THEN
            retval:=min_rain;
        ELSIF (rand_result>=0.2 AND rand_result<0.33) OR (rand_result>=0.67 AND rand_result<0.8) THEN
            IF poprzedni_odczyt=0 THEN
                retval:=ROUND(dbms_random.value(min_rain+0.15,max_rain/10+0.04999999),1);
            ELSE
                retval:=ROUND(dbms_random.value(GREATEST(min_rain+0.15,poprzedni_odczyt-0.25),LEAST(max_rain+0.049,poprzedni_odczyt+0.24999999)),1);
            END IF;
        ELSIF (rand_result>=0.1 AND rand_result<0.2) OR (rand_result>=0.8 AND rand_result<0.9) THEN
            IF poprzedni_odczyt=0 THEN
                retval:=ROUND(dbms_random.value(max_rain/10+0.05,max_rain/5+0.04999999),1);
            ELSE
                retval:=ROUND(dbms_random.value(GREATEST(min_rain+0.25,poprzedni_odczyt-0.45),LEAST(max_rain+0.049,poprzedni_odczyt+0.44999999)),1);
            END IF;   
        ELSIF (rand_result>=0.03 AND rand_result<0.1) OR (rand_result>=0.9 AND rand_result<0.97) THEN
            IF poprzedni_odczyt=0 THEN
                retval:=ROUND(dbms_random.value(max_rain/5+0.05,max_rain/2.5+0.04999999),1);
            ELSE
                retval:=ROUND(dbms_random.value(GREATEST(min_rain+0.55,poprzedni_odczyt-0.75),LEAST(max_rain+0.049,poprzedni_odczyt+0.74999999)),1);
            END IF;  
        ELSIF (rand_result>=0.97 AND rand_result<=1) OR (rand_result>=0 AND rand_result<=0.03) THEN
            IF poprzedni_odczyt=0 THEN
                retval:=ROUND(dbms_random.value(max_rain/2.5+0.05,max_rain+0.04999999),1);
            ELSE
                retval:=ROUND(dbms_random.value(GREATEST(min_rain+0.85,poprzedni_odczyt-1.05),LEAST(max_rain+0.049,poprzedni_odczyt+1.04999999)),1);
            END IF;  
        END IF;
        return retval;
    END calculate_rain;

    function calculate_pressure(rand_result NUMBER, poprzedni_odczyt NUMBER) return NUMBER
    IS
        retval NUMBER(6,2);
        min_pressure NUMBER(6,2):=meteo_readings_constants.min_pressure;
        max_pressure NUMBER(6,2):=meteo_readings_constants.max_pressure;
    BEGIN
        IF rand_result>=0 AND rand_result<0.33 THEN
            retval:=ROUND(dbms_random.value(GREATEST(min_pressure-0.005,poprzedni_odczyt-2.005),GREATEST(min_pressure+0.5049,poprzedni_odczyt-0.65500001)),2);
        ELSIF rand_result>=0.33 AND rand_result<0.67 THEN
            retval:=ROUND(dbms_random.value(GREATEST(min_pressure-0.005,poprzedni_odczyt-0.655),LEAST(max_pressure+0.0049,poprzedni_odczyt+0.65499999)),2);
        ELSIF rand_result>=0.67 AND rand_result<=1 THEN
            retval:=ROUND(dbms_random.value(LEAST(max_pressure-0.505,poprzedni_odczyt+0.655),LEAST(max_pressure+0.0049,poprzedni_odczyt+2.00499999)),2);
        END IF;
        return retval;
    END calculate_pressure;

    function calculate_wind(rand_result NUMBER, poprzedni_odczyt NUMBER) return NUMBER
    IS
        retval NUMBER(3,1);
        min_wind NUMBER(3,1):=meteo_readings_constants.min_wind;
        max_wind NUMBER(3,1):=meteo_readings_constants.max_wind;
    BEGIN
        IF rand_result>=0 AND rand_result<0.33 THEN
            retval:=ROUND(dbms_random.value(GREATEST(min_wind-0.005,poprzedni_odczyt-3.55),GREATEST(min_wind+0.5049,poprzedni_odczyt-1.2500001)),1);
        ELSIF rand_result>=0.33 AND rand_result<0.67 THEN
            retval:=ROUND(dbms_random.value(GREATEST(min_wind-0.005,poprzedni_odczyt-1.25),LEAST(max_wind+0.0049,poprzedni_odczyt+1.249)),1);
        ELSIF rand_result>=0.67 AND rand_result<=1 THEN
            retval:=ROUND(dbms_random.value(LEAST(max_wind-0.505,poprzedni_odczyt+1.25),LEAST(max_wind+0.0049,poprzedni_odczyt+3.549)),1);
        END IF;
        return retval;
    END calculate_wind;

    function get_min_temp(miesiac NUMBER) return NUMBER
    IS
        retval NUMBER(3,1);
    BEGIN
        CASE miesiac
            WHEN 1 THEN retval:=meteo_readings_constants.min_temp_jan;
            WHEN 2 THEN retval:=meteo_readings_constants.min_temp_feb;
            WHEN 3 THEN retval:=meteo_readings_constants.min_temp_mar;
            WHEN 4 THEN retval:=meteo_readings_constants.min_temp_apr;
            WHEN 5 THEN retval:=meteo_readings_constants.min_temp_may;
            WHEN 6 THEN retval:=meteo_readings_constants.min_temp_jun;
            WHEN 7 THEN retval:=meteo_readings_constants.min_temp_jul;
            WHEN 8 THEN retval:=meteo_readings_constants.min_temp_aug;
            WHEN 9 THEN retval:=meteo_readings_constants.min_temp_sep;
            WHEN 10 THEN retval:=meteo_readings_constants.min_temp_oct;
            WHEN 11 THEN retval:=meteo_readings_constants.min_temp_nov;
            WHEN 12 THEN retval:=meteo_readings_constants.min_temp_dec;
        END CASE;
        return retval;
    END get_min_temp;

    function get_max_temp_rain(parametr VARCHAR2,miesiac NUMBER) return NUMBER
    IS
        retval NUMBER(3,1);
    BEGIN
        IF parametr = 'temperature' THEN
            CASE miesiac
                WHEN 1 THEN retval:=meteo_readings_constants.max_temp_jan;
                WHEN 2 THEN retval:=meteo_readings_constants.max_temp_feb;
                WHEN 3 THEN retval:=meteo_readings_constants.max_temp_mar;
                WHEN 4 THEN retval:=meteo_readings_constants.max_temp_apr;
                WHEN 5 THEN retval:=meteo_readings_constants.max_temp_may;
                WHEN 6 THEN retval:=meteo_readings_constants.max_temp_jun;
                WHEN 7 THEN retval:=meteo_readings_constants.max_temp_jul;
                WHEN 8 THEN retval:=meteo_readings_constants.max_temp_aug;
                WHEN 9 THEN retval:=meteo_readings_constants.max_temp_sep;
                WHEN 10 THEN retval:=meteo_readings_constants.max_temp_oct;
                WHEN 11 THEN retval:=meteo_readings_constants.max_temp_nov;
                WHEN 12 THEN retval:=meteo_readings_constants.max_temp_dec;
            END CASE;
        ELSE
            CASE miesiac
                WHEN 1 THEN retval:=meteo_readings_constants.max_rain_jan;
                WHEN 2 THEN retval:=meteo_readings_constants.max_rain_feb;
                WHEN 3 THEN retval:=meteo_readings_constants.max_rain_mar;
                WHEN 4 THEN retval:=meteo_readings_constants.max_rain_apr;
                WHEN 5 THEN retval:=meteo_readings_constants.max_rain_may;
                WHEN 6 THEN retval:=meteo_readings_constants.max_rain_jun;
                WHEN 7 THEN retval:=meteo_readings_constants.max_rain_jul;
                WHEN 8 THEN retval:=meteo_readings_constants.max_rain_aug;
                WHEN 9 THEN retval:=meteo_readings_constants.max_rain_sep;
                WHEN 10 THEN retval:=meteo_readings_constants.max_rain_oct;
                WHEN 11 THEN retval:=meteo_readings_constants.max_rain_nov;
                WHEN 12 THEN retval:=meteo_readings_constants.max_rain_dec;
            END CASE;
        END IF;
        return retval;
    END get_max_temp_rain;
    
    function prepare_data_for_temperature_calc(godzina_odczytu NUMBER) return meteo_support_types_pack.val_dur_rec
    IS
        retval meteo_support_types_pack.val_dur_rec;
    BEGIN
        IF godzina_odczytu>=9 AND godzina_odczytu<17 THEN
            retval.rand_value:=dbms_random.value(0,0.6);
        ELSIF (godzina_odczytu>=17 AND godzina_odczytu<24) OR godzina_odczytu=0 THEN
            retval.rand_value:=dbms_random.value(0.4,1);
        ELSIF godzina_odczytu>=1 AND godzina_odczytu<9 THEN
            retval.rand_value:=dbms_random.value(0.25,0.75);
        END IF;
        IF (retval.rand_value>=0 AND retval.rand_value<0.1) OR (retval.rand_value>=0.9 AND retval.rand_value<=1) THEN
            retval.duration:=ROUND(dbms_random.value(0.5,2.4999));
        ELSIF (retval.rand_value>=0.1 AND retval.rand_value<0.25) OR (retval.rand_value>=0.75 AND retval.rand_value<0.9) THEN
            retval.duration:=ROUND(dbms_random.value(0.5,3.4999));
        ELSIF (retval.rand_value>=0.25 AND retval.rand_value<0.45) OR (retval.rand_value>=0.55 AND retval.rand_value<0.75) THEN
            retval.duration:=ROUND(dbms_random.value(1.5,5.4999));
        ELSIF retval.rand_value>=0.45 AND retval.rand_value<0.55 THEN
            retval.duration:=ROUND(dbms_random.value(1.5,7.4999));
        END IF;    
        return retval;
        
    END prepare_data_for_temperature_calc;
    
    function prepare_data_for_rain_calc(is_raining BOOLEAN) return meteo_support_types_pack.val_dur_rec
    IS
        retval meteo_support_types_pack.val_dur_rec;
    BEGIN
        IF is_raining THEN
            retval.rand_value:=dbms_random.value(0,0.58);
        ELSE
            retval.rand_value:=dbms_random.value(0,1);
        END IF;
        IF retval.rand_value>=0.33 AND retval.rand_value<0.67 THEN
            retval.duration:=ROUND(dbms_random.value(23.5,120.49999));
        ELSIF (retval.rand_value>=0.2 AND retval.rand_value<0.33) OR (retval.rand_value>=0.67 AND retval.rand_value<0.8) THEN
            retval.duration:=ROUND(dbms_random.value(2.5,24.49999));
        ELSIF (retval.rand_value>=0.1 AND retval.rand_value<0.2) OR (retval.rand_value>=0.8 AND retval.rand_value<0.9) THEN
            retval.duration:=ROUND(dbms_random.value(2.5,8.49999));
        ELSIF (retval.rand_value>=0.03 AND retval.rand_value<0.1) OR (retval.rand_value>=0.9 AND retval.rand_value<0.97)THEN
            retval.duration:=ROUND(dbms_random.value(1.5,4.49999));    
        ELSIF (retval.rand_value>=0 AND retval.rand_value<0.03) OR (retval.rand_value>=0.97 AND retval.rand_value<=1) THEN
            retval.duration:=ROUND(dbms_random.value(0.5,2.49999));
        END IF;    
        return retval;
        
    END prepare_data_for_rain_calc;
    
    function prepare_data_for_pressure_wind_calc return meteo_support_types_pack.val_dur_rec
    IS
        retval meteo_support_types_pack.val_dur_rec;
    BEGIN
        retval.rand_value:=dbms_random.value(0,1);
        
        IF (retval.rand_value>=0 AND retval.rand_value<0.33) OR (retval.rand_value>=0.67 AND retval.rand_value<=1) THEN
            retval.duration:=ROUND(dbms_random.value(0.5,5.49999));
        ELSIF retval.rand_value>=0.33 AND retval.rand_value<0.67 THEN
            retval.duration:=ROUND(dbms_random.value(3.5,12.49999));
        END IF;    
        return retval;
        
    END prepare_data_for_pressure_wind_calc;
        
END;

/
