CREATE OR REPLACE OPERATOR "C##METEO"."METEO_WORSE_CONDITION_DIFFZONES" BINDING
	("C##METEO"."METEO_T", NUMBER, NUMBER, NUMBER, NUMBER) RETURN NUMBER
	   USING "METEO_WORSE_CONDITION_DIFFZONES_SINGLEREADING_FUNC";
