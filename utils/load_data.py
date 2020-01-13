#!/usr/bin/env python3
import numpy as np
import time
from datetime import datetime
import json
import requests
import clickhouse_driver
folder = "/home/korolaab/purple_air/"
with open(folder+"configs/api_openweather.txt","r") as f:
    openweather_api_key = f.read()
openweather_api_key = openweather_api_key[:-1]
with open(folder+"configs/clickhouse_host.json") as f:
    host = json.loads(f.read())
client = clickhouse_driver.Client(host=host["ip"])
sensors_id=client.execute("SELECT sensor_id,latt,long FROM purple_air.sensors")
now = int(time.time())
def get_2pm_from_json(str):
    data = json.loads(str)
    return  data["results"][0]["pm2_5_cf_1"]

def get_weather_from_json(str):
    data = json.loads(str)
    return data

def get_data(id,latt,long):
    _2_5pm = float(get_2pm_from_json(requests.get("https://www.purpleair.com/json?show={}".format(id)).text))
    openweather_request = requests.get("https://api.openweathermap.org/data/2.5/weather?lat={}&lon={}&appid={}".format(latt,long,openweather_api_key)).text 
    weather = get_weather_from_json(openweather_request)
    data = {"2.5pm":_2_5pm,
	        'pressure':weather["main"]["pressure"],
		'humidity':weather["main"]["humidity"],
		'temp':weather["main"]["temp"],
		'wind_speed':weather["wind"]["speed"]}
    if("deg" in weather["wind"]): # sometimes openweather doesn't get any data about wind deg.
        data['wind_deg']=weather["wind"]["deg"]
    else:
        data['wind_deg']=0
    return data
parameters = ["2.5pm","pressure","humidity","temp","wind_speed","wind_deg"]
def load_data():
    cache  = {"update_time":datetime.utcfromtimestamp(now).strftime('%Y-%m-%d %H:%M:%S')}
    arr = []
    for i in sensors_id:
            time.sleep(0.4)
            data = get_data(i[0],i[1],i[2])
            data["sensor_id"] = i[0]
            arr.append(data)
            # print(i[0])
            for  name in parameters:
                # print(name)
                log=client.execute("INSERT INTO purple_air.sensors_telemetry VALUES ",
                            [{'sensor_id':i[0],
                              'Timestamp':now,
                              'value':data[name],
                             'parameter_name':name,
                             }])
    
    cache["telemetry"] = arr
    return cache
if "__main__":
    data = load_data()
    with open("/tmp/cached_pa_data.json","w") as outfile:
        json.dump(data,outfile)
