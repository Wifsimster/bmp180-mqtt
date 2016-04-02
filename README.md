# Send temperature and pression 

This LUA script is for ESP8266 hardware.

## Description

Read BMP180 data (temperature and pression).

Web server waiting for request to send data.

## Principle

1. Connect to a wifi AP
2. Start a MQTT client and try to connect to a MQTT broker
3. If temperature or pression change value, publish data to broker

## Scheme

![scheme](https://github.com/Wifsimster/bmp180/blob/master/scheme.png)
