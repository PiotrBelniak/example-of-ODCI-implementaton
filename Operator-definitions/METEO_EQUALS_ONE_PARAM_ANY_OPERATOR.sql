CREATE OR REPLACE OPERATOR "C##METEO"."METEO_EQUALS_ONE_PARAM_ANY" BINDING
	("C##METEO"."METEO_T", NUMBER, VARCHAR2, TIMESTAMP, TIMESTAMP) RETURN NUMBER
	   USING "METEO_EQUALS_ONE_PARAMETER_ANY_FUNC";
