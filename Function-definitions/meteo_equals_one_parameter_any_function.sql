CREATE OR REPLACE NONEDITIONABLE FUNCTION "C##METEO"."METEO_EQUALS_ONE_PARAMETER_ANY_FUNC" (obiekt METEO_T, wartosc NUMBER, parametr VARCHAR2, starttime TIMESTAMP DEFAULT NULL,endtime TIMESTAMP DEFAULT NULL) return number
IS
    retval NUMBER:=0;
    indeks NUMBER;
BEGIN
    indeks :=obiekt.Zonereadings.FIRST;
    WHILE indeks<=obiekt.Zonereadings.LAST AND retval !=1 LOOP
        CASE UPPER(parametr)
            WHEN 'TEMPERATURE' THEN
                retval:=meteo_temperature_comparison_specific(obiekt.Zonereadings(indeks).temperature,wartosc,'=');
            WHEN 'RAIN AMOUNT' THEN
                retval:=meteo_rain_amount_comparison_specific(obiekt.Zonereadings(indeks).rain_amount,wartosc,'=');
            WHEN 'PRESSURE' THEN
                retval:=meteo_pressure_comparison_specific(obiekt.Zonereadings(indeks).pressure,wartosc,'=');
            WHEN 'WIND' THEN
                retval:=meteo_avg_wind_comparison_specific(obiekt.Zonereadings(indeks).avg_wind,wartosc,'=');
            ELSE
                retval:=NULL;
            END CASE;
        indeks :=obiekt.Zonereadings.NEXT(indeks); 
    END LOOP;        
    return retval;
END meteo_equals_one_parameter_any_func;

/
