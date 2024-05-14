CREATE OR REPLACE NONEDITIONABLE FUNCTION "C##METEO"."METEO_WORSE_CONDITION_DIFFZONES_SINGLEREADING_FUNC" (obiekt METEO_T, x_pos1 NUMBER, y_pos1 NUMBER, x_pos2 NUMBER, y_pos2 NUMBER) RETURN NUMBER
IS
    komorka1 NUMBER;
    komorka2 NUMBER;
    retval NUMBER;
BEGIN
    komorka1:=x_pos1*10-(10-y_pos1);
    komorka2:=x_pos2*10-(10-y_pos2);
    IF  obiekt.Zonereadings(komorka1).temperature >= obiekt.Zonereadings(komorka2).temperature AND
        obiekt.Zonereadings(komorka1).rain_amount <= obiekt.Zonereadings(komorka2).rain_amount AND 
        ABS(obiekt.Zonereadings(komorka1).pressure-1013.25) <= ABS(obiekt.Zonereadings(komorka2).pressure-1013.25) AND 
        obiekt.Zonereadings(komorka1).avg_wind <= obiekt.Zonereadings(komorka2).avg_wind THEN
            retval:=1;
    ELSE
        retval:=0;
    END IF;
    return retval;
END meteo_worse_condition_diffzones_singlereading_func;

/
