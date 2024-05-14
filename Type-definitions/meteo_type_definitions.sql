CREATE OR REPLACE NONEDITIONABLE TYPE "C##METEO"."METEO_REGIONREADINGS" IS VARRAY(100) OF meteo_zonereading;
/

CREATE OR REPLACE NONEDITIONABLE TYPE "C##METEO"."METEO_REGIONREADINGS_NTT" IS TABLE OF meteo_zonereading;
/

CREATE OR REPLACE NONEDITIONABLE TYPE "C##METEO"."METEO_ZONEREADING" IS OBJECT
(temperature NUMBER(3,1)
,rain_amount NUMBER(3,1)
,pressure NUMBER(6,2)
,avg_wind NUMBER(3,1));
/

CREATE OR REPLACE NONEDITIONABLE TYPE "C##METEO"."METEO_T" AS OBJECT (
    -- Average weather conditions for the reading
    AvgCondReg meteo_zonereading,
    -- Min/Max weather conditions for the reading
    BestCondZone meteo_zonereading,
    WorstCondZone meteo_zonereading,
    -- Meteo grid: 10X10 array represented as Varray(100)
    Zonereadings meteo_regionreadings,
    -- Date/time for power-demand samplings: Every hour,
    -- 100 meteo mini-stations transmit their meteo
    -- readings.
    ReadingTime TIMESTAMP,
    Member Procedure SetAvgCondReg,
    Member Procedure SetBestCondZone,
    Member Procedure SetWorstCondZone,
    member function show_zone_reading(numer INTEGER) return meteo_zonereading,
    member function show_best_worst_reading(rodzaj VARCHAR2) return meteo_zonereading
);
/
CREATE OR REPLACE NONEDITIONABLE TYPE BODY "C##METEO"."METEO_T" 
IS

    Member Procedure SetAvgCondReg
    IS
        temp_cond_temperature NUMBER:=0;
        temp_cond_rain_amount NUMBER:=0;
        temp_cond_pressure NUMBER:=0;
        temp_cond_avg_wind NUMBER:=0;
        not_null_zones_temperature NUMBER:=0;
        not_null_zones_rain_amount NUMBER:=0;
        not_null_zones_pressure NUMBER:=0;
        not_null_zones_avg_wind NUMBER:=0;
        indeks NUMBER;
    BEGIN
        indeks:=Zonereadings.FIRST;
        WHILE indeks IS NOT NULL LOOP
            temp_cond_temperature:=temp_cond_temperature+NVL(Zonereadings(indeks).temperature,0);
            temp_cond_rain_amount:=temp_cond_rain_amount+NVL(Zonereadings(indeks).rain_amount,0);
            temp_cond_pressure:=temp_cond_pressure+NVL(Zonereadings(indeks).pressure,0);
            temp_cond_avg_wind:=temp_cond_avg_wind+NVL(Zonereadings(indeks).avg_wind,0);
            not_null_zones_temperature:=not_null_zones_temperature+NVL2(Zonereadings(indeks).temperature,1,0);
            not_null_zones_rain_amount:=not_null_zones_rain_amount+NVL2(Zonereadings(indeks).rain_amount,1,0);
            not_null_zones_pressure:=not_null_zones_pressure+NVL2(Zonereadings(indeks).pressure,1,0);
            not_null_zones_avg_wind:=not_null_zones_avg_wind+NVL2(Zonereadings(indeks).avg_wind,1,0);    
            indeks:=Zonereadings.NEXT(indeks);
        END LOOP;
        AvgCondReg:=METEO_ZONEREADING(CASE WHEN not_null_zones_temperature=0 THEN 0 ELSE ROUND(temp_cond_temperature/not_null_zones_temperature,1) END
                                          ,CASE WHEN not_null_zones_rain_amount=0 THEN 0 ELSE ROUND(temp_cond_rain_amount/not_null_zones_rain_amount,1) END
                                          ,CASE WHEN not_null_zones_pressure=0 THEN 0 ELSE ROUND(temp_cond_pressure/not_null_zones_pressure,2) END
                                          ,CASE WHEN not_null_zones_avg_wind=0 THEN 0 ELSE ROUND(temp_cond_avg_wind/not_null_zones_avg_wind,1) END);
    END SetAvgCondReg;

    Member Procedure SetBestCondZone
    IS
        temp_cond METEO_ZONEREADING;
        indeks NUMBER;
    BEGIN
        indeks:=Zonereadings.FIRST;
        temp_cond:=Zonereadings(indeks);
        WHILE indeks IS NOT NULL LOOP
            IF temp_cond.temperature <= Zonereadings(indeks).temperature THEN
                IF (temp_cond.rain_amount >= Zonereadings(indeks).rain_amount AND ABS(temp_cond.pressure-1013.25) >= ABS(Zonereadings(indeks).pressure-1013.25)) OR
                   (temp_cond.rain_amount >= Zonereadings(indeks).rain_amount AND temp_cond.avg_wind >= Zonereadings(indeks).avg_wind) OR
                   (temp_cond.avg_wind >= Zonereadings(indeks).avg_wind AND ABS(temp_cond.pressure-1013.25) >= ABS(Zonereadings(indeks).pressure-1013.25)) THEN
                        temp_cond:=Zonereadings(indeks);
                END IF;
            END IF;
            indeks:=Zonereadings.NEXT(indeks);
        END LOOP;
        BestCondZone:=temp_cond;
    END SetBestCondZone;

    Member Procedure SetWorstCondZone
    IS
        temp_cond METEO_ZONEREADING;
        indeks NUMBER;
    BEGIN
        indeks:=Zonereadings.FIRST;
        temp_cond:=Zonereadings(indeks);
        WHILE indeks IS NOT NULL LOOP
            IF temp_cond.temperature >= Zonereadings(indeks).temperature THEN
                IF (temp_cond.rain_amount <= Zonereadings(indeks).rain_amount AND ABS(temp_cond.pressure-1013.25) <= ABS(Zonereadings(indeks).pressure-1013.25)) OR
                   (temp_cond.rain_amount <= Zonereadings(indeks).rain_amount AND temp_cond.avg_wind <= Zonereadings(indeks).avg_wind) OR
                   (temp_cond.avg_wind <= Zonereadings(indeks).avg_wind AND ABS(temp_cond.pressure-1013.25) <= ABS(Zonereadings(indeks).pressure-1013.25)) THEN
                        temp_cond:=Zonereadings(indeks);
                END IF;
            END IF;
            indeks:=Zonereadings.NEXT(indeks);
        END LOOP;
        WorstCondZone:=temp_cond;
    END SetWorstCondZone;

    Member Function show_zone_reading(numer INTEGER) return meteo_zonereading
    IS
        retval METEO_ZONEREADING;
    BEGIN   
        IF numer BETWEEN 1 AND 100 THEN
            retval:=Zonereadings(numer);
        ELSE
            retval:=NULL;
        END IF;
        return retval;
    END show_zone_reading;

    member function show_best_worst_reading(rodzaj VARCHAR2) return meteo_zonereading
    IS
        retval METEO_ZONEREADING;
    BEGIN   
        IF rodzaj='Best' THEN
            retval:=BestCondZone;
        ELSIF rodzaj='Worst' THEN
            retval:=WorstCondZone;
        ELSE
            retval:=NULL;
        END IF;
        return retval;
    END show_best_worst_reading;

END "C##METEO"."METEO_T" ;
/

CREATE OR REPLACE EDITIONABLE TYPE "C##METEO"."METEO_T_VARR" IS VARRAY(32767) OF METEO_T;
/






