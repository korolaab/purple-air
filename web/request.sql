SELECT sensor_id, Timestamp, pressure, temp, _2_5pm, humidity, wind_speed, wind_deg
FROM (SELECT  sensor_id, Timestamp, value AS pressure FROM purple_air.sensors_telemetry WHERE (parameter_name='pressure' AND Timestamp >= toDateTime('TIME_from') AND Timestamp<= toDateTime('TIME_to')) ) AS pressure_telemtry
      ALL INNER JOIN (
      SELECT sensor_id,Timestamp,temp,_2_5pm,humidity,wind_speed,wind_deg
       FROM (SELECT sensor_id,Timestamp,value as temp From purple_air.sensors_telemetry WHERE (parameter_name='temp'AND Timestamp >= toDateTime('TIME_from') AND Timestamp<= toDateTime('TIME_to')))
          ALL INNER JOIN (
              SELECT sensor_id, Timestamp, _2_5pm, humidity, wind_speed,wind_deg
               FROM (SELECT sensor_id, Timestamp,value as _2_5pm From purple_air.sensors_telemetry WHERE (parameter_name='2.5pm' AND Timestamp >= toDateTime('TIME_from') AND Timestamp<= toDateTime('TIME_to')))
              ALL INNER JOIN (
                 SELECT  sensor_id,  Timestamp,  humidity,  wind_speed,wind_deg
                 FROM (SELECT sensor_id,Timestamp, value as humidity FROM purple_air.sensors_telemetry WHERE (parameter_name='humidity' AND Timestamp >= toDateTime('TIME_from') AND Timestamp<= toDateTime('TIME_to')) )
                  ALL INNER JOIN(
                      SELECT sensor_id,Timestamp,wind_speed,wind_deg
                      FROM(SELECT sensor_id,Timestamp,value as wind_speed FROM purple_air.sensors_telemetry WHERE (parameter_name='wind_speed' AND Timestamp >= toDateTime('TIME_from') AND Timestamp<= toDateTime('TIME_to')) )
                      ALL INNER JOIN(
                        SELECT sensor_id,Timestamp,wind_deg
                        FROM(SELECT sensor_id,Timestamp,value as wind_deg FROM purple_air.sensors_telemetry WHERE (parameter_name='wind_deg'AND Timestamp >= toDateTime('TIME_from') AND Timestamp<= toDateTime('TIME_to')) )
                     )As wind_speed_deg USING(sensor_id,Timestamp)
                  )AS wind_speed_telemetry USING(sensor_id,Timestamp)
                ) AS humidity_telemetry USING(sensor_id,Timestamp)
          ) AS _2_5pm_telemetry USING (sensor_id, Timestamp)
  ) AS temp_telemetry USING (sensor_id,Timestamp) FORMAT JSON
