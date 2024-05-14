CREATE OR REPLACE EDITIONABLE PACKAGE "C##METEO"."METEO_READINGS_AUX_FUNCTIONS" IS
    function calculate_temperature(miesiac NUMBER,rand_result NUMBER DEFAULT NULL, poprzedni_odczyt NUMBER DEFAULT NULL) return NUMBER;
    function calculate_rain(rand_result NUMBER, miesiac NUMBER, poprzedni_odczyt NUMBER) return NUMBER;
    function calculate_pressure(rand_result NUMBER, poprzedni_odczyt NUMBER) return NUMBER;
    function calculate_wind(rand_result NUMBER, poprzedni_odczyt NUMBER) return NUMBER;
    function get_min_temp(miesiac NUMBER) return NUMBER;
    function get_max_temp_rain(parametr VARCHAR2,miesiac NUMBER) return NUMBER;
    function prepare_data_for_temperature_calc(godzina_odczytu NUMBER) return meteo_support_types_pack.val_dur_rec;
    function prepare_data_for_rain_calc(is_raining BOOLEAN) return meteo_support_types_pack.val_dur_rec;
    function prepare_data_for_pressure_wind_calc return meteo_support_types_pack.val_dur_rec;
END;
/

