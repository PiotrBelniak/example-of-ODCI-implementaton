CREATE TABLE "C##METEO"."METEO_STATISTICS_TBL_OVERALL" 
   (	"TABELA" VARCHAR2(100 BYTE), 
	"KOLUMNA" VARCHAR2(100 BYTE), 
	"ALL_ROWS" NUMBER(10,0), 
	"PARAMETR" VARCHAR2(25 BYTE), 
	"WARTOSC" NUMBER(6,2), 
	"ILOSC_WYSTAPIEN" NUMBER(10,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 ROW STORE COMPRESS ADVANCED LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TRG_METEO_SYSTEM"  ENABLE ROW MOVEMENT ;
