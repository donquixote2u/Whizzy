-- Remote Wind Speed/Dir Sensor
--(send wind speed/dir, batt and pv voltage levels to webserver)
-- manifest: sensor,tsclient,readcompass,getadc,i2c,checkwifi
 -- Constants
SSID    = "SSID"
APPWD   = "password"
CMDFILE = "sensor.lua"   -- File that is executed after connection
-- INTERVAL = 1200000   -- delay before data send; 1200 millisecs=20 min
INTERVAL = 60000   -- temp delay 1 minute
THRESHOLD = 10000000
CALIBRATION = 10000000
-- Some control variables
wifiTrys     = 0      -- Counter of trys to connect to wifi
NUMWIFITRYS  = 20    -- Maximum number of WIFI Testings while waiting for connection
CONNECTED = false   -- wifi connect attempt status
tmr.alarm( 1 , 2500 , 0 , function() dofile(CMDFILE) end )  -- Call main control pgm after timeout
-- Drop through here to let NodeMcu run

