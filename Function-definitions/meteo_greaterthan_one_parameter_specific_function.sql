CREATE OR REPLACE NONEDITIONABLE FUNCTION "C##METEO"."METEO_GREATERTHAN_ONE_PARAMETER_SPECIFIC_FUNC" (obiekt METEO_T, x_pos NUMBER, y_pos NUMBER, wartosc NUMBER, parametr VARCHAR2, starttime TIMESTAMP DEFAULT NULL,endtime TIMESTAMP DEFAULT NULL) return number
IS
    retval NUMBER;
BEGIN
    CASE UPPER(parametr)
        WHEN 'TEMPERATURE' THEN
            retval:=meteo_temperature_comparison_specific(obiekt.Zonereadings(x_pos*10-(10-y_pos)).temperature,wartosc,'>');
        WHEN 'RAIN AMOUNT' THEN
            retval:=meteo_rain_amount_comparison_specific(obiekt.Zonereadings(x_pos*10-(10-y_pos)).rain_amount,wartosc,'>');
        WHEN 'PRESSURE' THEN
            retval:=meteo_pressure_comparison_specific(obiekt.Zonereadings(x_pos*10-(10-y_pos)).pressure,wartosc,'>');
        WHEN 'WIND' THEN
            retval:=meteo_avg_wind_comparison_specific(obiekt.Zonereadings(x_pos*10-(10-y_pos)).avg_wind,wartosc,'>');
        ELSE
            retval:=NULL;
        END CASE;
    return retval;
END meteo_greaterthan_one_parameter_specific_func;

/
