CREATE OR REPLACE EDITIONABLE FUNCTION "C##METEO"."SECONDBESTPRESS" (input METEO_T) return number AGGREGATE USING SECONDBESTPRESSIMPL;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "C##METEO"."SECONDBESTRAIN" (input METEO_T) return number AGGREGATE USING SecondBestRainImpl;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "C##METEO"."SECONDBESTTEMP" (input METEO_T) return number AGGREGATE USING SecondBestTempImpl;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "C##METEO"."SECONDBESTWIND" (input METEO_T) return number AGGREGATE USING SECONDBESTWINDIMPL;
/
