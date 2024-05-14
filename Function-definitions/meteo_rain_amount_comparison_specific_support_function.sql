CREATE OR REPLACE NONEDITIONABLE FUNCTION "C##METEO"."METEO_RAIN_AMOUNT_COMPARISON_SPECIFIC" (odczyt NUMBER, wartosc NUMBER, relop VARCHAR2) return number
IS
    retval NUMBER;
BEGIN
    CASE relop
        WHEN '=' THEN
            IF odczyt=wartosc THEN
                retval:=1;
            ELSE
                retval:=0;
            END IF;
        WHEN '>' THEN
            IF odczyt>wartosc THEN
                retval:=1;
            ELSE
                retval:=0;
            END IF;
        WHEN '<' THEN
            IF odczyt<wartosc THEN
                retval:=1;
            ELSE
                retval:=0;
            END IF;
    END CASE;
    return retval;
END meteo_rain_amount_comparison_specific;

/
