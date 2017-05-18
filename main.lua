require('config')

TOPIC = "/sensors/bmp180/data"
 
alti=14 -- Set your altitude in meters
temp=0  -- Temperature
pres=0 	-- Pressure
oss=0   -- Over sampling setting

function readBMP()
    require('bmp180')
    result = {}
	bmp180 = require("bmp180")
	bmp180.init(SDA_PIN, SCL_PIN)
	bmp180.read(oss)
	result["temp"] = (bmp180.getTemperature()/10)-2
	result["pres"] = bmp180.getPressure()/100+alti/8.43
    -- Release bmp180 module
	bmp180 = nil
	package.loaded["bmp180"]=nil
    return result
end

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

ip = wifi.sta.getip()

m:lwt("/offline", '{"message":"'..CLIENT_ID..'", "topic":"'..TOPIC..'", "ip":"'..ip..'"}', 0, 0)

print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
    tmr.alarm(1, REFRESH_RATE, 1, function()
        TEMP = tonumber(string.format("%02.1f", readBMP().temp))
        PRES = tonumber(string.format("%02.1f", readBMP().pres))
        DATA = '{"mac":"'..wifi.sta.getmac()..'","ip":"'..ip..'",'
        DATA = DATA..'"temp":"'..TEMP..'","pres":"'..PRES..'"}'
        -- Publish a message (QoS = 0, retain = 0)       
        m:publish(TOPIC, DATA, 0, 0, function(conn)
            print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
        end)
    end)
end)
