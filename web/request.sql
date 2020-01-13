SELECT sensor_id, Timestamp, pressure, temp, _2_5pm, humidity, wind_speed, wind_deg
FROM (SELECT  sensor_id, Timestamp, value AS pressure FROM purple_air.sensors_telemetry WHERE parameter_name='pressure') AS pressure_telemtry
    ALL INNER JOIN (
    SELECT sensor_id,Timestamp,temp,_2_5pm,humidity,wind_speed,wind_deg
    FROM (SELECT sensor_id,Timestamp,value as temp From purple_air.sensors_telemetry WHERE parameter_name='temp')
        ALL INNER JOIN (
            SELECT sensor_id, Timestamp, _2_5pm, humidity, wind_speed,wind_deg
            FROM (SELECT sensor_id, Timestamp,value as _2_5pm From purple_air.sensors_telemetry WHERE parameter_name='2.5pm')
            ALL INNER JOIN (
                SELECT  sensor_id,  Timestamp,  humidity,  wind_speed,wind_deg
                FROM (SELECT sensor_id,Timestamp, value as humidity FROM purple_air.sensors_telemetry WHERE parameter_name='humidity')
                ALL INNER JOIN(
                    SELECT sensor_id,Timestamp,wind_speed,wind_deg
                    FROM(SELECT sensor_id,Timestamp,value as wind_speed FROM purple_air.sensors_telemetry WHERE parameter_name='wind_speed')
                    ALL INNER JOIN(
                      SELECT sensor_id,Timestamp,wind_deg
                      FROM(SELECT sensor_id,Timestamp,value as wind_deg FROM purple_air.sensors_telemetry WHERE parameter_name='wind_deg')
                    )As wind_speed_deg USING(sensor_id,Timestamp)
                )AS wind_speed_telemetry USING(sensor_id,Timestamp)
              ) AS humidity_telemetry USING(sensor_id,Timestamp)
        ) AS _2_5pm_telemetry USING (sensor_id, Timestamp)
) AS temp_telemetry USING (sensor_id,Timestamp)
