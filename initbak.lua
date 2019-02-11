-- Remote Wind Speed/Dir Sensor
--(send wind speed/dir, batt and pv voltage levels to webserver)
-- manifest: sensor,tsclient,readcompass,getadc,i2c,checkwifi,wificredentials
-- updated to Nodemcu 2.2   26/7/18
 -- Constants
require("wificredentials")
CMDFILE = "sensor.lua"   -- File that is executed after connection
INTERVAL = 120000   -- delay before data send; 1.2 million millisecs=20 min
THRESHOLD = 10000000
CALIBRATION = 10000000
-- Some control variables
wifiTries     = 0      -- Counter of trys to connect to wifi
NUMWIFITRIES  = 20    -- Maximum number of WIFI Testings while waiting for connection
CONNECTED = false   -- wifi connect attempt status
local delayed_call=tmr.create()
delayed_call:register(2500 , tmr.ALARM_SINGLE, function() dofile(CMDFILE) end ) -- Call main control pgm after timeout
delayed_call:start()
-- Drop through here to let NodeMcu run

