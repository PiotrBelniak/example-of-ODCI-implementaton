CREATE OR REPLACE OPERATOR "C##METEO"."METEO_LESSTHAN_ONE_PARAM_ANY" BINDING
	("C##METEO"."METEO_T", NUMBER, VARCHAR2, TIMESTAMP, TIMESTAMP) RETURN NUMBER
	   USING "METEO_LESSTHAN_ONE_PARAMETER_ANY_FUNC";
