CREATE OR REPLACE NONEDITIONABLE FUNCTION "C##METEO"."METEO_GREATERTHAN_TWO_PARAMETERS_SPECIFIC_FUNC" (obiekt METEO_T, x_pos NUMBER, y_pos NUMBER, parametr1 VARCHAR2 ,wartosc1 NUMBER, parametr2 VARCHAR2,wartosc2 NUMBER, starttime TIMESTAMP DEFAULT NULL,endtime TIMESTAMP DEFAULT NULL) return number
IS
    retval NUMBER;
BEGIN
    retval:=LEAST(meteo_greaterthan_one_parameter_specific_func(obiekt, x_pos, y_pos, wartosc1, parametr1),
                meteo_greaterthan_one_parameter_specific_func(obiekt, x_pos, y_pos, wartosc2, parametr2));
    return retval;
END meteo_greaterthan_two_parameters_specific_func;

/
