# Send temperature and pression 

This LUA script is for ESP8266 hardware.

## Description

Read BMP180 data (temperature and pression).

Web server waiting for request to send data.

##Files
* ``config.lua``: Configuration variables
* ``init.lua``: Connect to a wifi AP and then execute main.lua file
* ``main.lua``: Main file
* 
## Principle

1. Start a MQTT client then try to connect to a MQTT broker
2. If temperature or pression change value, publish data to broker

## Scheme

![scheme](https://github.com/Wifsimster/bmp180/blob/master/scheme.png)
