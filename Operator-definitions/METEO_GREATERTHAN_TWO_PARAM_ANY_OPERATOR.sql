--------------------------------------------------------
--  File created - wtorek-maja-14-2024   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Operator METEO_GREATERTHAN_TWO_PARAM_ANY
--------------------------------------------------------

  CREATE OR REPLACE OPERATOR "C##METEO"."METEO_GREATERTHAN_TWO_PARAM_ANY" BINDING
	("C##METEO"."METEO_T", VARCHAR2, NUMBER, VARCHAR2, NUMBER, TIMESTAMP, TIMESTAMP) RETURN NUMBER
	   USING "METEO_GREATERTHAN_TWO_PARAMETERS_ANY_FUNC";
