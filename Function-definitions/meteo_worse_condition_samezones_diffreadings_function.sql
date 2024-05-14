CREATE OR REPLACE NONEDITIONABLE FUNCTION "C##METEO"."METEO_WORSE_CONDITION_SAMEZONES_DIFFREADINGS_FUNC" (obiekt1 METEO_T, obiekt2 METEO_T,x_pos NUMBER, y_pos NUMBER) RETURN NUMBER
IS
    komorka NUMBER;
    retval NUMBER;
BEGIN
    komorka:=x_pos*10-(10-y_pos);
    IF  obiekt1.Zonereadings(komorka).temperature >= obiekt2.Zonereadings(komorka).temperature AND
        obiekt1.Zonereadings(komorka).rain_amount <= obiekt2.Zonereadings(komorka).rain_amount AND 
        ABS(obiekt1.Zonereadings(komorka).pressure-1013.25) <= ABS(obiekt2.Zonereadings(komorka).pressure-1013.25) AND 
        obiekt1.Zonereadings(komorka).avg_wind <= obiekt2.Zonereadings(komorka).avg_wind THEN
            retval:=1;
    ELSE
        retval:=0;
    END IF;
    return retval;
END meteo_worse_condition_samezones_diffreadings_func;

/
