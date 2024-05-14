CREATE OR REPLACE EDITIONABLE PROCEDURE "C##METEO"."METEO_SYSTEM_MAKE_READINGS" (ilosc_odczytow NUMBER, data_poczatkowa TIMESTAMP, glowny_region NUMBER, ilosc_stref_w_regionie NUMBER DEFAULT 100)
IS
    type insert_coll_ntt IS TABLE OF meteo_t;
    insert_coll insert_coll_ntt:=insert_coll_ntt();
    stan_odczytow meteo_regionreadings:=meteo_regionreadings();
    poprzednie_odczyty meteo_regionreadings;
    
    data_odczytu TIMESTAMP:=data_poczatkowa;
    is_raining BOOLEAN:=FALSE;
    temp_matrix meteo_support_types_pack.val_dur_varr:=meteo_support_types_pack.val_dur_varr();
    rain_matrix meteo_support_types_pack.val_dur_varr:=meteo_support_types_pack.val_dur_varr();
    press_matrix meteo_support_types_pack.val_dur_varr:=meteo_support_types_pack.val_dur_varr();
    wind_matrix meteo_support_types_pack.val_dur_varr:=meteo_support_types_pack.val_dur_varr();
    
    FUNCTION create_insert_row(odczyty IN meteo_regionreadings, data_odczytu IN DATE) RETURN meteo_t
    IS
        retval meteo_t:=meteo_t(NULL,NULL,NULL,NULL,NULL);
    BEGIN
        retval.Zonereadings:=odczyty;
        retval.SetAvgCondReg;
        retval.SetBestCondZone;
        retval.SetWorstCondZone;
        retval.ReadingTime:=data_odczytu;     
        return retval;
    END create_insert_row;
    
BEGIN
    insert_coll.Extend(ilosc_odczytow);
    stan_odczytow.EXTEND(LEAST(100,ilosc_stref_w_regionie));
    temp_matrix.EXTEND(LEAST(100,ilosc_stref_w_regionie));
    rain_matrix.EXTEND(LEAST(100,ilosc_stref_w_regionie));
    press_matrix.EXTEND(LEAST(100,ilosc_stref_w_regionie));
    wind_matrix.EXTEND(LEAST(100,ilosc_stref_w_regionie));
    
    /*calculating first reading*/
    FOR region IN 1..LEAST(100,ilosc_stref_w_regionie) LOOP
        stan_odczytow(region):= meteo_zonereading(meteo_readings_aux_functions.calculate_temperature(EXTRACT(MONTH FROM data_poczatkowa))
                                ,0
                                ,dbms_random.value(meteo_readings_constants.min_pressure+20,meteo_readings_constants.max_pressure-20)
                                ,dbms_random.value(meteo_readings_constants.min_wind+2,meteo_readings_constants.min_wind+11));
        temp_matrix(region):=meteo_support_types_pack.val_dur_rec(0,0);
        rain_matrix(region):=meteo_support_types_pack.val_dur_rec(0,0);
        press_matrix(region):=meteo_support_types_pack.val_dur_rec(0,0);
        wind_matrix(region):=meteo_support_types_pack.val_dur_rec(0,0);
    END LOOP;

    insert_coll(1):=create_insert_row(stan_odczytow, data_odczytu);
    
    data_odczytu:=data_odczytu + INTERVAL '1' HOUR;
    poprzednie_odczyty:=stan_odczytow;
 
    FOR odczyt IN 2..ilosc_odczytow LOOP
        FOR region IN 1..LEAST(100,ilosc_stref_w_regionie) LOOP
        
            /*calculate temperature*/
            IF temp_matrix(region).duration=0 THEN
                temp_matrix(region):=meteo_readings_aux_functions.prepare_data_for_temperature_calc(EXTRACT(HOUR FROM data_odczytu)); 
            END IF;
            
            stan_odczytow(region).temperature:=meteo_readings_aux_functions.calculate_temperature(EXTRACT(MONTH FROM data_odczytu),temp_matrix(region).rand_value,poprzednie_odczyty(region).temperature);
            temp_matrix(region).duration:=temp_matrix(region).duration-1;
            
            /*calculate rain*/
            IF (rain_matrix(region).rand_value>=0.33 AND rain_matrix(region).rand_value<0.67) OR rain_matrix(region).rand_value IS NULL THEN
                is_raining:=FALSE;
            ELSE
                is_raining:=TRUE;
            END IF;
            IF rain_matrix(region).duration=0 THEN 
                rain_matrix(region):=meteo_readings_aux_functions.prepare_data_for_rain_calc(is_raining); 
            END IF;
            stan_odczytow(region).rain_amount:=meteo_readings_aux_functions.calculate_rain(rain_matrix(region).rand_value,EXTRACT(MONTH FROM data_odczytu),poprzednie_odczyty(region).rain_amount);
            rain_matrix(region).duration:=rain_matrix(region).duration-1;
            
            /*calculate pressure*/
            IF press_matrix(region).duration = 0 THEN
                press_matrix(region):=meteo_readings_aux_functions.prepare_data_for_pressure_wind_calc(); 
            END IF;
            stan_odczytow(region).pressure:=meteo_readings_aux_functions.calculate_pressure(press_matrix(region).rand_value,poprzednie_odczyty(region).pressure);
            press_matrix(region).duration:=press_matrix(region).duration-1;
            
            /*calculate wind*/
            IF wind_matrix(region).duration = 0 THEN
                wind_matrix(region):=meteo_readings_aux_functions.prepare_data_for_pressure_wind_calc(); 
            END IF;
            stan_odczytow(region).avg_wind:=meteo_readings_aux_functions.calculate_wind(wind_matrix(region).rand_value,poprzednie_odczyty(region).avg_wind);
            wind_matrix(region).duration:=wind_matrix(region).duration-1;
        END LOOP;

        insert_coll(odczyt):=create_insert_row(stan_odczytow, data_odczytu);
        
        data_odczytu:=data_odczytu + INTERVAL '1' HOUR;
        poprzednie_odczyty:=stan_odczytow;

    END LOOP;

    FORALL indx IN insert_coll.FIRST..insert_coll.LAST
        INSERT INTO meteo_tbl VALUES (glowny_region,insert_coll(indx));

END meteo_system_make_readings;

/
