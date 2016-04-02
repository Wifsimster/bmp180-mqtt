require('config')

alti=14 -- Set your altitude in meters
sda=4	-- GPIO2 connect to SDA BMP180
scl=3	-- GPIO0 connect to SCL BMP180
temp=0  -- Temperature
pres=0 	-- Pressure
oss=0   -- Over sampling setting

function readBMP()
    result = {}
	bmp180 = require("bmp180")
	bmp180.init(sda, scl)
	bmp180.read(oss)
	result["temp"] = bmp180.getTemperature()/10
	result["pres"] = bmp180.getPressure()/100+alti/8.43   
    -- Release bmp180 module
	bmp180 = nil
	package.loaded["bmp180"]=nil
    return result
end

-- MQTT client
TOPIC = "/sensors/bureau/bmp180"

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

tmr.alarm(0, 1000, 1, function()
    print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
    tmr.stop(0)
    m:connect(BROKER_IP, BROKER_PORT, 0, function(conn)
        print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
        TEMP = tonumber(string.format("%02.1f", readBMP().temp))
        PRES = tonumber(string.format("%02.1f", readBMP().pres))
        -- Check every 5s for values change
        tmr.alarm(1, 5000, 1, function()
            TMP_TEMP = tonumber(string.format("%02.1f", readBMP().temp))
            TMP_PRES = tonumber(string.format("%02.1f", readBMP().pres))
            if(TEMP ~= TMP_TEMP or PRES ~= TMP_PRES) then
                DATA = '{"temp":"'..TMP_TEMP..'","pres":"'..TMP_PRES..'"}'
                -- Publish a message (QoS = 0, retain = 0)        
                m:publish(TOPIC, DATA, 0, 0, function(conn)
                    print("Sending data:"..DATA)
                end)
            else
                print("No change in values")    
            end
        end)
    end)
end)

m:close();