require('config')
 
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

TOPIC = "/sensors/bureau/bmp180/data"

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

tmr.alarm(2, 1000, 1, function()
    tmr.stop(2)
    print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
    m:connect(BROKER_IP, BROKER_PORT, 0, function(conn)
        print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
        TEMP = tonumber(string.format("%02.1f", readBMP().temp))
        PRES = tonumber(string.format("%02.1f", readBMP().pres))    

        -- Publish a first time the data
        DATA = '{"mac":"'..wifi.sta.getmac()..'", "ip":"'..wifi.sta.getip()..'",'
        DATA = DATA..'"temp":"'..TEMP..'","pres":"'..PRES..'"}'
        m:publish(TOPIC, DATA, 0, 0, function(conn)
            print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
        end)
                
        -- Check every 5s for values change
        tmr.alarm(1, REFRESH_RATE, 1, function()
            TMP_TEMP = tonumber(string.format("%02.1f", readBMP().temp))
            TMP_PRES = tonumber(string.format("%02.1f", readBMP().pres))
            if(TEMP ~= TMP_TEMP or PRES ~= TMP_PRES) then              
                DATA = '{"mac":"'..wifi.sta.getmac()..'", "ip":"'..wifi.sta.getip()..'",'
                DATA = DATA..'"temp":"'..TMP_TEMP..'","pres":"'..TMP_PRES..'"}'
                -- Publish a message (QoS = 0, retain = 0)
                m:publish(TOPIC, DATA, 0, 0, function(conn)
                    print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
                end)
            else
                print("No change in value, no data send to broker.")
            end
        end)
    end)
end)

m:close();
